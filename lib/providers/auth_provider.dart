// lib/providers/auth_provider.dart - ОБНОВЛЕННАЯ ВЕРСИЯ ДЛЯ РАБОТЫ С API
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/sms_service.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _lastError;

  final SMSService _smsService = SMSService();
  final LocalStorageService _storage = LocalStorageService.instance;
  final ApiService _apiService = ApiService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  /// Инициализация провайдера
  Future<void> init() async {
    await _storage.init();
    await checkAuthStatus();
  }

  /// Проверяет статус авторизации при запуске приложения
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      // Проверяем автологин
      final autoLoginPhone = await _storage.getAutoLoginPhone();
      if (autoLoginPhone != null) {
        final user = await _storage.getUserByPhone(autoLoginPhone);
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;

          // Восстанавливаем токен
          final token = await _storage.getAuthToken();
          if (token != null) {
            _apiService.setAuthToken(token);
          }

          if (kDebugMode) {
            print('Автологин успешен для: $autoLoginPhone');
          }
        } else {
          await _storage.removeAutoLoginInfo();
        }
      }

      // Если автологин не сработал, проверяем токен
      if (!_isAuthenticated) {
        final token = await _storage.getAuthToken();
        if (token != null) {
          _apiService.setAuthToken(token);

          // Проверяем токен на сервере
          final profileResult = await _apiService.getProfile();
          if (profileResult['success']) {
            final userData = profileResult['user'];
            _currentUser = User.fromJson(userData);
            _isAuthenticated = true;
            await _storage.saveUser(_currentUser!);
          } else {
            await _storage.removeAuthToken();
            _apiService.clearAuthToken();
          }
        }
      }
    } catch (e) {
      _lastError = 'Ошибка при проверке авторизации: $e';
      if (kDebugMode) {
        print('Auth check error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Отправляет SMS с кодом подтверждения
  Future<bool> sendSMSCode(String phone) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final formattedPhone = _smsService.formatPhoneNumber(phone);

      if (!_smsService.isValidPhoneNumber(formattedPhone)) {
        _lastError = 'Неверный формат номера телефона';
        return false;
      }

      print('Отправляем SMS код на: $formattedPhone');

      // Проверяем подключение к серверу
      final isConnected = await _apiService.checkConnection();
      if (!isConnected) {
        _lastError =
            'Нет подключения к серверу. Проверьте интернет соединение.';
        return false;
      }

      // Отправляем SMS
      final success = await _smsService.sendVerificationCode(formattedPhone);

      if (!success) {
        _lastError = 'Не удалось отправить SMS. Попробуйте позже';
      }

      return success;
    } catch (e) {
      _lastError = 'Ошибка при отправке SMS: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Проверяет SMS код и авторизует пользователя через API
  Future<bool> verifySMSAndLogin(String phone, String code,
      {bool rememberMe = false}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final formattedPhone = _smsService.formatPhoneNumber(phone);

      // Проверяем код локально
      final isCodeValid = _smsService.verifyCode(formattedPhone, code);

      if (!isCodeValid) {
        _lastError = 'Неверный код подтверждения';
        return false;
      }

      // Авторизуемся через API
      final loginResult = await _apiService.login(
        phone: formattedPhone,
        smsCode: code,
      );

      if (loginResult['success']) {
        final userData = loginResult['user'];
        final token = loginResult['token'];

        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;

        // Сохраняем токен
        if (token != null) {
          await _storage.saveAuthToken(token);
          _apiService.setAuthToken(token);
        }

        // Сохраняем пользователя локально
        await _storage.saveUser(_currentUser!);

        // Автологин
        if (rememberMe) {
          await _storage.saveAutoLoginInfo(formattedPhone, daysValid: 30);
        }

        if (kDebugMode) {
          print('Успешная авторизация через API: ${_currentUser!.fullName}');
        }

        return true;
      } else {
        _lastError = loginResult['error'] ?? 'Ошибка авторизации';
        return false;
      }
    } catch (e) {
      _lastError = 'Ошибка при входе: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Регистрирует нового пользователя через API
  Future<bool> register(String phone, String firstName, String password,
      {String? lastName}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final formattedPhone = _smsService.formatPhoneNumber(phone);

      if (!_smsService.isValidPhoneNumber(formattedPhone)) {
        _lastError = 'Неверный формат номера телефона';
        return false;
      }

      // Регистрируемся через API
      final registerResult = await _apiService.register(
        phone: formattedPhone,
        firstName: firstName.trim(),
        lastName: lastName?.trim(),
      );

      if (registerResult['success']) {
        final userData = registerResult['user'];
        final token = registerResult['token'];

        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;

        // Сохраняем токен
        if (token != null) {
          await _storage.saveAuthToken(token);
          _apiService.setAuthToken(token);
        }

        // Сохраняем пользователя локально
        await _storage.saveUser(_currentUser!);

        if (kDebugMode) {
          print(
              'Пользователь зарегистрирован через API: ${_currentUser!.fullName}');
        }

        return true;
      } else {
        _lastError = registerResult['error'] ?? 'Ошибка регистрации';
        return false;
      }
    } catch (e) {
      _lastError = 'Ошибка при регистрации: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.removeAuthToken();
      await _storage.removeAutoLoginInfo();
      _apiService.clearAuthToken();

      _currentUser = null;
      _isAuthenticated = false;
      _lastError = null;

      if (kDebugMode) {
        print('Пользователь вышел из системы');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при выходе: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновляет данные пользователя
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: firstName ?? _currentUser!.name,
        lastName: lastName ?? _currentUser!.lastName,
        email: email ?? _currentUser!.email,
        updatedAt: DateTime.now(),
      );

      await _storage.saveUser(updatedUser);
      _currentUser = updatedUser;

      return true;
    } catch (e) {
      _lastError = 'Ошибка при обновлении профиля: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очищает ошибку
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Проверяет автологин
  Future<bool> canAutoLogin(String phone) async {
    final formattedPhone = _smsService.formatPhoneNumber(phone);
    final autoLoginPhone = await _storage.getAutoLoginPhone();
    return autoLoginPhone == formattedPhone;
  }
}

// ========================================
// 1. lib/providers/auth_provider.dart
// ========================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/sms_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _lastError;

  static const String _pendingSmsVerificationKey = 'pending_sms_verification';
  final SMSService _smsService = SMSService();
  final ApiService _apiService = ApiService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  // Ключи для SharedPreferences
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _autoLoginPhoneKey = 'auto_login_phone';

  /// Инициализация провайдера
  Future<void> init() async {
    await checkAuthStatus();
  }

  /// Проверяет статус авторизации при запуске приложения
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // ПЕРВЫМ ДЕЛОМ проверяем флаг ожидания верификации
      final pendingVerification =
          prefs.getBool(_pendingSmsVerificationKey) ?? false;
      if (pendingVerification) {
        if (kDebugMode) {
          print('⏳ Ожидается верификация SMS, пропускаем автологин');
        }
        _currentUser = null;
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Теперь проверяем сохраненного пользователя
      final userJson = prefs.getString(_userDataKey);
      final token = prefs.getString(_authTokenKey);

      if (userJson != null && token != null) {
        try {
          // Устанавливаем токен для проверки
          _apiService.setAuthToken(token);

          // Проверяем, существует ли пользователь на сервере
          final checkResult = await _apiService.getProfile();

          if (checkResult['success'] == true && checkResult['user'] != null) {
            // Пользователь существует, используем свежие данные с сервера
            _currentUser = User.fromJson(checkResult['user']);
            _isAuthenticated = true;

            // Обновляем локальные данные свежими с сервера
            await _saveUserToPrefs(_currentUser!);

            if (kDebugMode) {
              print(
                  '✅ Пользователь подтвержден сервером: ${_currentUser?.fullName}');
            }
          } else {
            // Пользователь не найден на сервере, очищаем локальные данные
            if (kDebugMode) {
              print('❌ Пользователь не найден на сервере, очищаем данные');
            }
            await prefs.remove(_userDataKey);
            await prefs.remove(_authTokenKey);
            await prefs.remove(_pendingSmsVerificationKey);
            _apiService.clearAuthToken();
            _currentUser = null;
            _isAuthenticated = false;
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Ошибка проверки пользователя на сервере: $e');
          }
          // Очищаем данные при ошибке
          await prefs.remove(_userDataKey);
          await prefs.remove(_authTokenKey);
          await prefs.remove(_pendingSmsVerificationKey);
          _apiService.clearAuthToken();
          _currentUser = null;
          _isAuthenticated = false;
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ Пользователь не найден в локальном хранилище');
        }
      }
    } catch (e) {
      _lastError = 'Ошибка при проверке авторизации: $e';
      if (kDebugMode) {
        print('❌ Auth check error: $e');
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

      if (kDebugMode) {
        print('📱 Отправляем SMS код на: $formattedPhone');
      }

      // Проверяем подключение к серверу
      final healthResult = await _apiService.healthCheck();
      final isConnected = healthResult['success'] == true;

      // Отправляем SMS
      final success = await _smsService.sendVerificationCode(formattedPhone);

      if (!success) {
        _lastError = 'Не удалось отправить SMS. Попробуйте позже';
      }

      return success;
    } catch (e) {
      _lastError = 'Ошибка при отправке SMS: $e';
      if (kDebugMode) {
        print('❌ Ошибка отправки SMS: $e');
      }
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

      if (kDebugMode) {
        print('🔐 Начинаем верификацию для: $formattedPhone');
      }

      // Проверяем код локально
      final isCodeValid = _smsService.verifyCode(formattedPhone, code);

      if (!isCodeValid) {
        _lastError = 'Неверный код подтверждения';
        return false;
      }

      if (kDebugMode) {
        print('✅ SMS код валиден, отправляем запрос на сервер');
      }

      // Авторизуемся через API
      final loginResult = await _apiService.login(
        phone: formattedPhone,
        smsCode: code,
      );

      if (kDebugMode) {
        print('📡 Ответ от сервера: ${loginResult['success']}');
      }

      if (loginResult['success'] == true) {
        final userData = loginResult['user'];
        final token = loginResult['token'];

        if (userData != null) {
          try {
            if (kDebugMode) {
              print('🔧 Создаем пользователя из данных сервера...');
            }

// Убираем флаг ожидания верификации
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(_pendingSmsVerificationKey);
            _currentUser = User.fromJson(userData);
            _isAuthenticated = true;

            if (kDebugMode) {
              print('✅ Пользователь создан: ${_currentUser?.fullName}');
            }

            // Сохраняем токен
            if (token != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_authTokenKey, token);
              _apiService.setAuthToken(token);

              if (kDebugMode) {
                print('✅ Токен сохранен');
              }
            }

            // Сохраняем пользователя локально
            await _saveUserToPrefs(_currentUser!);

            // Автологин
            if (rememberMe) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_autoLoginPhoneKey, formattedPhone);

              if (kDebugMode) {
                print('✅ Автологин настроен');
              }
            }

            if (kDebugMode) {
              print(
                  '🎉 Успешная авторизация завершена: ${_currentUser?.fullName}');
            }

            return true;
          } catch (e) {
            if (kDebugMode) {
              print('❌ Ошибка при обработке пользователя: $e');
              print('📊 UserData: $userData');
            }
            _lastError = 'Ошибка обработки данных пользователя: $e';
            return false;
          }
        } else {
          _lastError = 'Некорректные данные от сервера';
          return false;
        }
      } else {
        _lastError = loginResult['error'] ?? 'Ошибка авторизации';
        return false;
      }
    } catch (e) {
      _lastError = 'Ошибка при входе: $e';
      if (kDebugMode) {
        print('❌ Критическая ошибка verifySMSAndLogin: $e');
      }
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

      if (kDebugMode) {
        print('📝 Регистрация пользователя: $formattedPhone');
      }

      // Регистрируемся через API
      final registerResult = await _apiService.register(
        phone: formattedPhone,
        firstName: firstName.trim(),
        lastName: lastName?.trim(),
      );

      if (kDebugMode) {
        print('📡 Ответ регистрации: ${registerResult['success']}');
      }

      if (registerResult['success'] == true) {
        final userData = registerResult['user'];
        final token = registerResult['token'];

        if (userData != null) {
          try {
            _currentUser = User.fromJson(userData);

            // Сохраняем флаг, что ожидается верификация
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_pendingSmsVerificationKey, true);

            // Очищаем токен из ApiService
            _apiService.clearAuthToken();

            // // Можно сохранить токен и данные для будущего использования
            // if (token != null) {
            //   await prefs.setString(_authTokenKey, token);
            //   _apiService.setAuthToken(token);
            // }
            // await _saveUserToPrefs(_currentUser!);

            // _isAuthenticated = true;

            // // Сохраняем токен
            // if (token != null) {
            //   final prefs = await SharedPreferences.getInstance();
            //   await prefs.setString(_authTokenKey, token);
            //   _apiService.setAuthToken(token);
            // }

            // // Сохраняем пользователя локально
            // await _saveUserToPrefs(_currentUser!);

            if (kDebugMode) {
              print(
                  '✅ Пользователь зарегистрирован: ${_currentUser?.fullName}');
            }

            return true;
          } catch (e) {
            if (kDebugMode) {
              print('❌ Ошибка при создании пользователя после регистрации: $e');
            }
            _lastError = 'Ошибка обработки данных пользователя';
            return false;
          }
        } else {
          _lastError = 'Некорректные данные от сервера';
          return false;
        }
      } else {
        _lastError = registerResult['error'] ?? 'Ошибка регистрации';
        return false;
      }
    } catch (e) {
      _lastError = 'Ошибка при регистрации: $e';
      if (kDebugMode) {
        print('❌ Ошибка register: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Сохраняет пользователя в SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userDataKey, userJson);

      if (kDebugMode) {
        print('✅ Пользователь сохранен в локальное хранилище');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка сохранения пользователя: $e');
      }
      // Не критичная ошибка, не прерываем процесс авторизации
    }
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Удаляем все данные
      await prefs.remove(_authTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_autoLoginPhoneKey);

      _apiService.clearAuthToken();

      _currentUser = null;
      _isAuthenticated = false;
      _lastError = null;

      if (kDebugMode) {
        print('✅ Пользователь вышел из системы');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка при выходе: $e');
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

      await _saveUserToPrefs(updatedUser);
      _currentUser = updatedUser;

      if (kDebugMode) {
        print('✅ Профиль обновлен: ${_currentUser?.fullName}');
      }

      return true;
    } catch (e) {
      _lastError = 'Ошибка при обновлении профиля: $e';
      if (kDebugMode) {
        print('❌ Ошибка updateUserProfile: $e');
      }
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
    try {
      final formattedPhone = _smsService.formatPhoneNumber(phone);
      final prefs = await SharedPreferences.getInstance();
      final autoLoginPhone = prefs.getString(_autoLoginPhoneKey);
      return autoLoginPhone == formattedPhone;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка проверки автологина: $e');
      }
      return false;
    }
  }

  /// Обновляет пользователя принудительно
  void forceUpdate() {
    notifyListeners();
  }
}

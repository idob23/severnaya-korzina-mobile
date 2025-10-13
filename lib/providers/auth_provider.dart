// ========================================
// 1. lib/providers/auth_provider.dart
// ========================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/sms_service.dart';
import '../services/api_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

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

  /// Получить текущий токен авторизации
  String? get token => _apiService.getToken();

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
      // Для веб-версии добавляем специальную обработку
      if (kIsWeb) {
        print('🌐 Web platform detected, checking saved auth...');

        // Пробуем несколько раз получить SharedPreferences
        SharedPreferences? prefs;
        int attempts = 0;

        while (prefs == null && attempts < 3) {
          try {
            prefs = await SharedPreferences.getInstance();
          } catch (e) {
            print(
                'Attempt ${attempts + 1} to get SharedPreferences failed: $e');
            attempts++;
            if (attempts < 3) {
              await Future.delayed(Duration(milliseconds: 300));
            }
          }
        }

        if (prefs == null) {
          print('❌ Failed to initialize SharedPreferences on web');
          _currentUser = null;
          _isAuthenticated = false;
          _isLoading = false;
          notifyListeners();
          return;
        }

        // Проверяем сохраненные данные
        final userJson = prefs.getString(_userDataKey);
        final token = prefs.getString(_authTokenKey);

        print(
            '🔍 Web auth check - has user: ${userJson != null}, has token: ${token != null}');

        if (userJson != null && token != null) {
          try {
            // Восстанавливаем пользователя из сохраненных данных
            final userMap = jsonDecode(userJson);
            _currentUser = User.fromJson(userMap);
            _apiService.setAuthToken(token);

            // ============= ДОБАВИТЬ ЭТИ СТРОКИ =============
            // Восстанавливаем номер телефона для проверки режима обслуживания
            if (_currentUser?.phone != null) {
              await prefs.setString('user_phone', _currentUser!.phone);
              print(
                  '📱 Восстановлен номер телефона из User: ${_currentUser!.phone}');
            }
            // ============= КОНЕЦ ДОБАВЛЕНИЯ =============

            // Проверяем токен на сервере
            try {
              final checkResult =
                  await _apiService.getProfile().timeout(Duration(seconds: 5));

              if (checkResult['success'] == true &&
                  checkResult['user'] != null) {
                // Обновляем данные пользователя свежими с сервера
                _currentUser = User.fromJson(checkResult['user']);
                _isAuthenticated = true;
                await _saveUserToPrefs(_currentUser!);

                // Между ними вставить:
                if (_currentUser?.phone != null) {
                  await prefs.setString('user_phone', _currentUser!.phone);
                  print('📱 [WEB] Сохранен номер: ${_currentUser!.phone}');
                }

                print('✅ Web user authenticated from saved session');
              } else {
                throw Exception('Invalid token');
              }
            } catch (e) {
              print('⚠️ Token validation failed, using cached data');
              // Если сервер недоступен, используем кешированные данные
              _isAuthenticated = true;
            }
          } catch (e) {
            print('❌ Failed to restore web session: $e');
            await _clearLocalAuth();
          }
        } else {
          print('📝 No saved session on web');
          _currentUser = null;
          _isAuthenticated = false;
        }

        _isLoading = false;
        notifyListeners();
        return;
      }

      // Для мобильных платформ - стандартная логика
      final prefs = await SharedPreferences.getInstance();

      // Проверяем флаг ожидания верификации
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

      // Проверяем сохраненного пользователя
      final userJson = prefs.getString(_userDataKey);
      final token = prefs.getString(_authTokenKey);

      if (userJson != null && token != null) {
        try {
          _apiService.setAuthToken(token);
          final checkResult = await _apiService.getProfile();

          if (checkResult['success'] == true && checkResult['user'] != null) {
            _currentUser = User.fromJson(checkResult['user']);
            _isAuthenticated = true;

            // ============= ДОБАВИТЬ ЭТИ СТРОКИ =============
            // Восстанавливаем номер телефона для проверки режима обслуживания
            if (_currentUser?.phone != null) {
              await prefs.setString('user_phone', _currentUser!.phone);
              print(
                  '📱 Восстановлен номер телефона из User: ${_currentUser!.phone}');
            }
            // ============= КОНЕЦ ДОБАВЛЕНИЯ =============

            await _saveUserToPrefs(_currentUser!);

            if (kDebugMode) {
              print('✅ Пользователь авторизован из локального хранилища');
            }
          } else {
            await _clearLocalAuth();
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Ошибка проверки токена: $e');
          }
          await _clearLocalAuth();
        }
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Критическая ошибка checkAuthStatus: $e');
      }
      _currentUser = null;
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Добавьте вспомогательный метод если его нет
  Future<void> _clearLocalAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_autoLoginPhoneKey);
      _apiService.clearAuthToken();
    } catch (e) {
      print('Error clearing auth: $e');
    }
    _currentUser = null;
    _isAuthenticated = false;
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

      // Используем асинхронную проверку кода через backend
      final isCodeValid =
          await _smsService.verifyCodeAsync(formattedPhone, code);

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

            _currentUser = User.fromJson(userData);
            _isAuthenticated = true;

            // ============= ИЗМЕНЕНИЕ НАЧАЛО =============
            // ПЕРЕНЕСТИ ЭТИ 3 СТРОКИ СЮДА (до разделения на kIsWeb):
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_phone', formattedPhone);
            print(
                '📱 Номер телефона сохранен ДЛЯ ВСЕХ ПЛАТФОРМ: $formattedPhone');
            // ============= ИЗМЕНЕНИЕ КОНЕЦ =============

            // Сохраняем токен
            if (token != null) {
              // Для веб-версии делаем несколько попыток сохранения
              if (kIsWeb) {
                bool saved = false;
                for (int i = 0; i < 3 && !saved; i++) {
                  try {
                    // final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(_authTokenKey, token);

                    await prefs.remove(_pendingSmsVerificationKey);
                    saved = true;
                    print('✅ Token saved to web storage (attempt ${i + 1})');
                  } catch (e) {
                    print('⚠️ Failed to save token (attempt ${i + 1}): $e');
                    await Future.delayed(Duration(milliseconds: 200));
                  }
                }
              } else {
                await prefs.setString(_authTokenKey, token);

                await prefs.remove(_pendingSmsVerificationKey);
              }

              _apiService.setAuthToken(token);
            }

            // Сохраняем пользователя локально
            await _saveUserToPrefs(_currentUser!);

            // Автологин
            if (rememberMe) {
              await prefs.setString(_autoLoginPhoneKey, formattedPhone);
            }

            if (kDebugMode) {
              print('🎉 Успешная авторизация: ${_currentUser?.fullName}');
              // Добавить проверку что номер действительно сохранен
            }

            return true;
          } catch (e) {
            if (kDebugMode) {
              print('❌ Ошибка при обработке пользователя: $e');
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
      {String? lastName, String? email, bool acceptedTerms = false}) async {
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
        email: email?.trim(),
        acceptedTerms: acceptedTerms,
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
      final userJson = jsonEncode(user.toJson());

      if (kIsWeb) {
        // Для веб делаем несколько попыток
        bool saved = false;
        for (int i = 0; i < 3 && !saved; i++) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_userDataKey, userJson);
            saved = true;
            print('✅ User saved to web storage (attempt ${i + 1})');
          } catch (e) {
            print('⚠️ Failed to save user (attempt ${i + 1}): $e');
            await Future.delayed(Duration(milliseconds: 200));
          }
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, userJson);
      }

      if (kDebugMode) {
        print('✅ Пользователь сохранен в локальное хранилище');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка сохранения пользователя: $e');
      }
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

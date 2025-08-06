// lib/services/sms_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SMSService {
  // SMS AERO API настройки
  static const String _baseUrl = 'https://gate.smsaero.ru/v2';
  static const String _login = 'idob230491@gmail.com'; // Email от SMS Aero
  static const String _apiKey =
      'J1WD5J__f3ztsHpi5sBWrVef5jlVRo9J'; // API ключ из личного кабинета

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  ));

  // Хранилище кодов для верификации
  final Map<String, String> _tempCodes = {};

  SMSService() {
    // Настройка Basic Auth для SMS Aero
    final credentials = base64Encode(utf8.encode('$_login:$_apiKey'));

    _dio.options.headers['Authorization'] = 'Basic $credentials';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    // Логирование запросов
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('SMS AERO API: $obj'),
    ));
  }

  /// Отправляет SMS с кодом подтверждения через SMS Aero
  Future<bool> sendVerificationCode(String phone) async {
    try {
      final code = _generateCode();

      // Форматируем номер для SMS Aero (только цифры, начинается с 7)
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      // Убираем префикс 8 или +7, оставляем только номер с 7
      if (cleanPhone.startsWith('8') && cleanPhone.length == 11) {
        cleanPhone = '7' + cleanPhone.substring(1);
      } else if (cleanPhone.startsWith('+7')) {
        cleanPhone = cleanPhone.substring(1);
      } else if (!cleanPhone.startsWith('7')) {
        // Если номер не начинается с 7, добавляем
        cleanPhone = '7' + cleanPhone;
      }

      print('=== ОТПРАВКА SMS ===');
      print('📱 Оригинальный номер: $phone');
      print('📱 Форматированный номер: $cleanPhone');
      print('🔑 Сгенерированный код: $code');

      // Сначала проверим баланс
      final balanceCheck = await checkBalance();
      if (balanceCheck['success'] == true) {
        print('💰 Баланс: ${balanceCheck['balance']} руб');
        if ((balanceCheck['balance'] as num) < 2) {
          print('❌ Недостаточно средств на балансе SMS Aero');
          return false;
        }
      }

      // Отправляем SMS через SMS Aero - используем правильный формат
      // Текст с указанием сервиса для прохождения фильтров МТС
      final response = await _dio.post(
        '$_baseUrl/sms/send',
        data: {
          'number': cleanPhone,
          'text':
              'Северная Корзина: Ваш код авторизации $code для входа в приложение',
          'sign': 'SMS Aero', // Обязательный параметр!
          'channel': 'DIRECT' // Используем прямой канал
        },
      );

      print('HTTP Status: ${response.statusCode}');
      print('Ответ от SMS Aero: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['success'] == true) {
          // Сохраняем код для проверки (для обоих форматов номера)
          _tempCodes[phone] = code;
          _tempCodes[cleanPhone] = code;
          _tempCodes['+$cleanPhone'] = code;

          final smsId = data['data']?['id'];
          print('✅ SMS успешно отправлено!');
          print('📨 ID сообщения: $smsId');
          print('💾 Код сохранен для верификации');

          // Проверяем статус доставки через 2 секунды
          Future.delayed(Duration(seconds: 2), () async {
            if (smsId != null) {
              await checkSmsStatus(smsId.toString());
            }
          });

          return true;
        } else {
          // Ошибка от SMS Aero API
          final errorMessage = data['message'] ?? 'Неизвестная ошибка';
          print('❌ Ошибка SMS Aero: $errorMessage');

          // Если ошибка связана с форматом номера, пробуем альтернативный формат
          if (errorMessage.toString().toLowerCase().contains('number') ||
              errorMessage.toString().toLowerCase().contains('формат')) {
            return await _sendWithAlternativeFormat(phone, code);
          }

          return false;
        }
      }

      print('❌ Неожиданный HTTP статус: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Критическая ошибка отправки SMS: $e');

      // Если ошибка сети, пробуем альтернативный метод
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        print('🔄 Пробуем альтернативный метод отправки...');
        return await _sendViaGet(phone);
      }

      return false;
    }
  }

  /// Альтернативный метод отправки через GET запрос
  Future<bool> _sendViaGet(String phone) async {
    try {
      final code = _generateCode();
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanPhone.startsWith('8') && cleanPhone.length == 11) {
        cleanPhone = '7' + cleanPhone.substring(1);
      }

      print('🔄 Используем GET метод для отправки SMS');

      final response = await _dio.get(
        '$_baseUrl/sms/send',
        queryParameters: {
          'number': cleanPhone,
          'text': 'Северная Корзина: код $code',
          'sign': 'SMS Aero', // Обязательный параметр
          'channel': 'DIRECT'
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _tempCodes[phone] = code;
        _tempCodes[cleanPhone] = code;
        print('✅ SMS отправлено через GET метод!');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Ошибка GET метода: $e');
      return false;
    }
  }

  /// Пробует отправить с альтернативным форматом номера
  Future<bool> _sendWithAlternativeFormat(
      String originalPhone, String code) async {
    try {
      print('🔄 Пробуем альтернативный формат номера...');

      // Пробуем с префиксом +7
      String altPhone = originalPhone.replaceAll(RegExp(r'[^\d]'), '');
      if (!altPhone.startsWith('7')) {
        altPhone = '7' + altPhone;
      }
      altPhone = '+' + altPhone;

      final response = await _dio.post(
        '$_baseUrl/sms/send',
        data: {
          'number': altPhone,
          'text': 'Северная Корзина: код авторизации $code',
          'sign': 'SMS Aero', // Обязательный параметр
          'channel': 'INTERNATIONAL' // Пробуем международный канал
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _tempCodes[originalPhone] = code;
        _tempCodes[altPhone] = code;
        print('✅ SMS отправлено с альтернативным форматом!');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Ошибка альтернативного формата: $e');
      return false;
    }
  }

  /// Проверяет правильность введенного кода
  bool verifyCode(String phone, String code) {
    print('=== ПРОВЕРКА SMS КОДА ===');
    print('Номер телефона: $phone');
    print('Введенный код: $code');

    // Форматируем номер так же как при отправке
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('8') && cleanPhone.length == 11) {
      cleanPhone = '7' + cleanPhone.substring(1);
    }

    print('Проверяем коды для форматов: $phone, $cleanPhone, +$cleanPhone');
    print('Сохраненные коды: $_tempCodes');

    // Проверяем для всех возможных форматов номера
    final savedCode = _tempCodes[phone] ??
        _tempCodes[cleanPhone] ??
        _tempCodes['+$cleanPhone'];

    if (savedCode != null && savedCode == code) {
      // Удаляем код для всех форматов
      _tempCodes.remove(phone);
      _tempCodes.remove(cleanPhone);
      _tempCodes.remove('+$cleanPhone');
      print('✅ Код подтвержден успешно!');
      return true;
    }

    print('❌ Неверный код. Ожидался: $savedCode, получен: $code');
    return false;
  }

  /// Генерирует случайный 4-значный код
  String _generateCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Проверяет баланс SMS Aero
  Future<Map<String, dynamic>> checkBalance() async {
    try {
      print('💰 Проверяем баланс SMS Aero...');

      final response = await _dio.get('$_baseUrl/balance');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final balance = response.data['data']['balance'];
        print('💰 Баланс SMS Aero: $balance руб');

        return {
          'success': true,
          'balance': balance,
          'currency': 'RUB',
        };
      }

      return {'success': false, 'error': 'Не удалось получить баланс'};
    } catch (e) {
      print('❌ Ошибка получения баланса: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Проверяет статус отправленного SMS
  Future<Map<String, dynamic>> checkSmsStatus(String smsId) async {
    try {
      print('📊 Проверяем статус SMS: $smsId');

      final response = await _dio
          .get('$_baseUrl/sms/status', queryParameters: {'id': smsId});

      if (response.statusCode == 200) {
        print('📊 Статус SMS: ${response.data}');
        return response.data;
      }

      return {'success': false};
    } catch (e) {
      print('❌ Ошибка проверки статуса: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Проверяет валидность российского номера
  bool isValidPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return (cleanPhone.startsWith('7') || cleanPhone.startsWith('8')) &&
        cleanPhone.length == 11;
  }

  /// Форматирует номер в стандартный вид +7XXXXXXXXXX
  String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('8') && cleanPhone.length == 11) {
      return '+7${cleanPhone.substring(1)}';
    }
    if (cleanPhone.startsWith('7') && cleanPhone.length == 11) {
      return '+$cleanPhone';
    }

    return phone;
  }

  /// Получает сохраненный код для номера (для отладки)
  String? getLastCodeForPhone(String phone) {
    return _tempCodes[phone];
  }

  /// Очищает все коды
  void clearAllCodes() {
    _tempCodes.clear();
  }
}

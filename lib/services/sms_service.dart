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

      // print('=== SMS ОТПРАВКА (ТЕСТОВЫЙ РЕЖИМ) ===');
      // print('Телефон: $phone');
      // print('Сгенерированный код: $code');
      // print('🧪 ТЕСТОВЫЙ РЕЖИМ: Используйте код 1234 для входа');

      // // В тестовом режиме всегда сохраняем код и возвращаем success
      // _tempCodes[phone] = code;

      // // Имитируем задержку отправки SMS
      // await Future.delayed(Duration(seconds: 1));

      // print('✅ SMS "отправлено" (тестовый режим)');
      // print('💡 Для входа используйте код: 1234');

      // return true;

      // РАСКОММЕНТИРУЙТЕ ДЛЯ РЕАЛЬНОЙ ОТПРАВКИ SMS ЧЕРЕЗ SMS AERO:

      // Очищаем номер телефона (только цифры)
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      print('Очищенный номер: $cleanPhone');

      // Отправляем POST запрос к SMS Aero API
      final response = await _dio.post(
        '$_baseUrl/sms/send',
        data: {
          'number': cleanPhone,
          'text': 'Код подтверждения: $code',
          'sign': 'SMS Aero',
        },
      );

      print('HTTP Status: ${response.statusCode}');
      print('Ответ от SMS Aero: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['success'] == true) {
          // SMS отправлено успешно
          _tempCodes[phone] = code;
          final smsId = data['data']?['id'];
          print('✅ SMS успешно отправлено через SMS Aero!');
          print('ID сообщения: $smsId');
          print('Код $code сохранен для номера $phone');
          return true;
        } else {
          // Ошибка от SMS Aero API
          final errorMessage = data['message'] ?? 'Неизвестная ошибка';
          print('❌ Ошибка SMS Aero: $errorMessage');

          // Если проблема с подписью, пробуем без неё
          if (errorMessage.toString().toLowerCase().contains('sign')) {
            return await _sendWithoutSign(cleanPhone, code);
          }

          return false;
        }
      }

      print('❌ Неожиданный HTTP статус: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Ошибка отправки SMS: $e');

      return false;
    }
  }

  /// Пробует отправить SMS без подписи при ошибке
  Future<bool> _sendWithoutSign(String cleanPhone, String code) async {
    try {
      print('📱 Пробуем отправить без подписи...');

      final response = await _dio.post(
        '$_baseUrl/sms/send',
        data: {
          'number': cleanPhone,
          'text': 'Код: $code',
        },
      );

      print('Ответ без подписи: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        _tempCodes[cleanPhone] = code;
        print('✅ SMS отправлено без подписи!');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Ошибка отправки без подписи: $e');
      return false;
    }
  }

  /// Проверяет правильность введенного кода
  bool verifyCode(String phone, String code) {
    print('=== ПРОВЕРКА SMS КОДА ===');
    print('Номер телефона: $phone');
    print('Введенный код: $code');

    // // Тестовый код для разработки
    // if (code == '1234') {
    //   print('✅ Использован тестовый код 1234 - вход разрешен!');
    //   return true;
    // }

    print('Сохраненные коды: $_tempCodes');

    final savedCode = _tempCodes[phone];
    if (savedCode != null && savedCode == code) {
      _tempCodes.remove(phone);
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
      print('Проверяем баланс SMS Aero...');

      final response = await _dio.get('$_baseUrl/balance');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final balance = response.data['data']['balance'];
        print('Баланс SMS Aero: $balance руб');

        return {
          'success': true,
          'balance': balance,
          'currency': 'RUB',
        };
      }

      return {'success': false, 'error': 'Не удалось получить баланс'};
    } catch (e) {
      print('Ошибка получения баланса SMS Aero: $e');
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

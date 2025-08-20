// lib/services/sms_service.dart - ОБНОВЛЕННАЯ ВЕРСИЯ ДЛЯ РАБОТЫ ЧЕРЕЗ BACKEND
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SMSService {
  // Используем наш backend как прокси для SMS
  static const String _baseUrl = 'http://84.201.149.245:3000/api';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  ));

  // Хранилище кодов для верификации (локальное, для fallback)
  final Map<String, String> _tempCodes = {};

  SMSService() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    // Логирование запросов
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('SMS API: $obj'),
    ));
  }

  /// Отправляет SMS через наш backend (который использует SMS Aero)
  Future<bool> sendVerificationCode(String phone) async {
    try {
      String cleanPhone = _formatPhoneNumber(phone);

      print('=== ОТПРАВКА SMS ===');
      print('📱 Оригинальный номер: $phone');
      print('📱 Форматированный номер: $cleanPhone');

      // Отправляем SMS через наш backend
      print('📤 Отправляем SMS через backend...');

      final response = await _dio.post(
        '$_baseUrl/sms/send',
        data: {
          'phone': cleanPhone,
        },
      );

      print('📥 Ответ backend: ${response.statusCode} ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ SMS отправлено через backend!');

        // Сохраняем информацию о том, что SMS отправлено
        final now = DateTime.now();
        _tempCodes['${cleanPhone}_sent'] = now.toIso8601String();

        return true;
      } else {
        print('❌ Backend вернул ошибку: ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Ошибка отправки SMS через backend: $e');

      // Если backend не доступен, пробуем fallback только для мобильных
      if (!kIsWeb) {
        return await _sendViaDirect(phone);
      }

      return false;
    }
  }

  /// Fallback метод - прямая отправка (только для мобильных приложений)
  Future<bool> _sendViaDirect(String phone) async {
    try {
      print('🔄 Используем fallback метод для мобильного приложения...');

      // Веб-версия не поддерживает прямую отправку из-за CORS
      if (kIsWeb) {
        print('❌ Веб-версия не поддерживает прямую отправку из-за CORS');
        return false;
      }

      final code = _generateCode();
      String cleanPhone = _formatPhoneNumber(phone);

      // Сохраняем код локально для fallback
      _tempCodes[phone] = code;
      _tempCodes[cleanPhone] = code;

      print('🔑 Fallback код: $code');

      // Для мобильных приложений пробуем прямой вызов
      final credentials = base64Encode(
          utf8.encode('idob230491@gmail.com:J1WD5J__f3ztsHpi5sBWrVef5jlVRo9J'));

      final response = await Dio().post(
        'https://gate.smsaero.ru/v2/sms/send',
        data: {
          'number': cleanPhone,
          'text': 'Северная Корзина: код авторизации $code',
          'sign': 'SMS Aero',
          'channel': 'DIRECT'
        },
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ SMS отправлено через fallback метод!');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Ошибка fallback метода: $e');
      return false;
    }
  }

  /// Проверяет правильность введенного кода через backend
  Future<bool> verifyCodeViaBackend(String phone, String code) async {
    try {
      print('🔍 Проверяем код через backend...');

      final response = await _dio.post(
        '$_baseUrl/sms/verify',
        data: {
          'phone': phone,
          'code': code,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Код подтвержден через backend!');
        return true;
      } else {
        print('❌ Backend отклонил код: ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Ошибка проверки через backend: $e');
      return false;
    }
  }

  /// Проверяет правильность введенного кода (синхронно для совместимости)
  bool verifyCode(String phone, String code) {
    print('=== ПРОВЕРКА SMS КОДА ===');
    print('Номер телефона: $phone');
    print('Введенный код: $code');

    // Форматируем номер так же как при отправке
    String cleanPhone = _formatPhoneNumber(phone);

    // Проверяем локально сохраненные коды (для fallback)
    final savedCode = _tempCodes[phone] ?? _tempCodes[cleanPhone];

    if (savedCode != null && savedCode == code) {
      print('✅ Код верный (локальная проверка)');

      // Удаляем использованный код
      _tempCodes.remove(phone);
      _tempCodes.remove(cleanPhone);

      return true;
    }

    print('ℹ️ Код не найден локально, будет проверен асинхронно через backend');
    return false;
  }

  /// Асинхронная проверка кода (основной метод для использования в UI)
  Future<bool> verifyCodeAsync(String phone, String code) async {
    // Сначала проверяем локально (для fallback случаев)
    if (verifyCode(phone, code)) {
      return true;
    }

    // Основная проверка через backend
    return await verifyCodeViaBackend(phone, code);
  }

  /// Проверяет статус SMS сервиса
  Future<Map<String, dynamic>> checkServiceStatus() async {
    try {
      final response = await _dio.get('$_baseUrl/sms/status');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }

      return {
        'success': false,
        'error': 'Неверный статус код: ${response.statusCode}'
      };
    } catch (e) {
      return {'success': false, 'error': 'Ошибка проверки статуса: $e'};
    }
  }

  /// Проверяет баланс SMS сервиса
  Future<Map<String, dynamic>> checkBalance() async {
    try {
      final response = await _dio.get('$_baseUrl/sms/status');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'balance': response.data['balance'],
          'service': response.data['service']
        };
      }

      return {'success': false, 'error': 'Не удалось получить баланс'};
    } catch (e) {
      return {'success': false, 'error': 'Ошибка проверки баланса: $e'};
    }
  }

  /// Форматирует номер телефона в нужный формат
  String _formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('8') && cleanPhone.length == 11) {
      cleanPhone = '7' + cleanPhone.substring(1);
    } else if (!cleanPhone.startsWith('7')) {
      cleanPhone = '7' + cleanPhone;
    }

    return cleanPhone;
  }

  /// Публичный метод для форматирования номера
  String formatPhoneNumber(String phone) {
    return _formatPhoneNumber(phone);
  }

  /// Проверяет валидность номера телефона
  bool isValidPhoneNumber(String phone) {
    final cleanPhone = _formatPhoneNumber(phone);

    // Российский номер должен быть 11 цифр, начинающихся с 7
    return cleanPhone.length == 11 && cleanPhone.startsWith('7');
  }

  /// Генерирует 4-значный код
  String _generateCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Очищает сохраненные коды
  void clearCodes() {
    _tempCodes.clear();
    print('🧹 Коды очищены');
  }

  /// Получает информацию о сохраненных кодах (для отладки)
  Map<String, String> getStoredCodes() {
    return Map.from(_tempCodes);
  }

  /// Получает последний отправленный код для телефона (для отладки)
  String? getLastCodeForPhone(String phone) {
    final cleanPhone = _formatPhoneNumber(phone);
    return _tempCodes[phone] ?? _tempCodes[cleanPhone];
  }
}

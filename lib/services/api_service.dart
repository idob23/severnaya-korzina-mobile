// lib/services/api_service.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL сервера - исправлено для всех платформ
  static String get baseUrl {
    if (kDebugMode) {
      // Для Android эмулятора используем 10.0.2.2 вместо localhost
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
      // Для iOS симулятора и других платформ
      return 'http://localhost:3000/api';
    }
    // Для продакшена
    return 'https://your-cloud-server.com/api';
  }

  // Singleton паттерн
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP клиент с настройками
  final http.Client _client = http.Client();
  String? _authToken;

  // Заголовки по умолчанию
  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Устанавливает токен авторизации
  void setAuthToken(String? token) {
    _authToken = token;
    if (kDebugMode) {
      print('API: Токен установлен: ${token?.substring(0, 10)}...');
    }
  }

  /// Очищает токен авторизации
  void clearAuthToken() {
    _authToken = null;
    if (kDebugMode) {
      print('API: Токен очищен');
    }
  }

  /// Универсальный метод для выполнения HTTP запросов
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      if (kDebugMode) {
        print('API: $method $baseUrl$endpoint');
        if (queryParams != null) {
          print('API: Query params - $queryParams');
        }
        if (body != null) {
          print('API: Request body - $body');
        }
      }

      // Создаем URI с query параметрами
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      late http.Response response;

      // Выполняем запрос в зависимости от метода
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(uri, headers: _defaultHeaders)
              .timeout(Duration(seconds: 30));
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: _defaultHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(Duration(seconds: 30));
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: _defaultHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _defaultHeaders)
              .timeout(Duration(seconds: 30));
          break;
        default:
          throw Exception('Неподдерживаемый HTTP метод: $method');
      }

      if (kDebugMode) {
        print('API: Ответ - ${response.statusCode}');
        print('API: Тело ответа - ${response.body}');
      }

      // Обрабатываем ответ
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': true,
            ...data,
          };
        } catch (e) {
          if (kDebugMode) {
            print('API: Ошибка парсинга JSON - $e');
          }
          return {
            'success': false,
            'error': 'Ошибка обработки ответа сервера',
          };
        }
      } else {
        // Обрабатываем ошибки сервера
        String errorMessage = 'Ошибка сервера (${response.statusCode})';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['error']?.toString() ?? errorMessage;
        } catch (e) {
          // Если не удалось распарсить ошибку, используем стандартное сообщение
        }

        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('API: SocketException - $e');
      }
      return {
        'success': false,
        'error': 'Нет подключения к интернету. Проверьте соединение.',
      };
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('API: HttpException - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка HTTP соединения',
      };
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('API: FormatException - $e');
      }
      return {
        'success': false,
        'error': 'Неверный формат данных от сервера',
      };
    } catch (e) {
      if (kDebugMode) {
        print('API: Неожиданная ошибка - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу: ${e.toString()}',
      };
    }
  }

  // === МЕТОДЫ ДЛЯ АВТОРИЗАЦИИ ===

  /// Регистрация пользователя
  Future<Map<String, dynamic>> register({
    required String phone,
    required String firstName,
    String? lastName,
    String? email,
  }) async {
    final body = <String, dynamic>{
      'phone': phone,
      'firstName': firstName,
    };

    if (lastName != null && lastName.isNotEmpty) {
      body['lastName'] = lastName;
    }
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }

    final result = await _makeRequest('POST', '/auth/register', body: body);

    if (result['success'] && result['token'] != null) {
      setAuthToken(result['token']);
    }

    return result;
  }

  /// Вход пользователя по SMS коду
  Future<Map<String, dynamic>> login({
    required String phone,
    required String smsCode,
  }) async {
    final result = await _makeRequest('POST', '/auth/login', body: {
      'phone': phone,
      'smsCode': smsCode,
    });

    if (result['success'] && result['token'] != null) {
      setAuthToken(result['token']);
    }

    return result;
  }

  /// Получить профиль пользователя
  Future<Map<String, dynamic>> getProfile() async {
    return await _makeRequest('GET', '/auth/profile');
  }

  // === МЕТОДЫ ДЛЯ ТОВАРОВ ===

  /// Получить все товары
  Future<Map<String, dynamic>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (categoryId != null) {
      queryParams['categoryId'] = categoryId.toString();
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    return await _makeRequest('GET', '/products', queryParams: queryParams);
  }

  /// Получить товар по ID
  Future<Map<String, dynamic>> getProduct(int productId) async {
    return await _makeRequest('GET', '/products/$productId');
  }

  /// Получить все категории
  Future<Map<String, dynamic>> getCategories() async {
    return await _makeRequest('GET', '/products/categories/all');
  }

  // === МЕТОДЫ ДЛЯ АДРЕСОВ ===

  /// Получить все адреса пользователя
  Future<Map<String, dynamic>> getAddresses() async {
    return await _makeRequest('GET', '/addresses');
  }

  /// Добавить новый адрес
  Future<Map<String, dynamic>> addAddress({
    required String title,
    required String address,
    bool isDefault = false,
  }) async {
    return await _makeRequest('POST', '/addresses', body: {
      'title': title,
      'address': address,
      'isDefault': isDefault,
    });
  }

  // === МЕТОДЫ ДЛЯ ЗАКАЗОВ ===

  /// Получить заказы пользователя
  Future<Map<String, dynamic>> getOrders({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) {
      queryParams['status'] = status;
    }

    return await _makeRequest('GET', '/orders', queryParams: queryParams);
  }

  /// Создать новый заказ
  Future<Map<String, dynamic>> createOrder({
    required int addressId,
    int? batchId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    return await _makeRequest('POST', '/orders', body: {
      'addressId': addressId,
      'batchId': batchId,
      'items': items,
      'notes': notes,
    });
  }

  // === МЕТОДЫ ДЛЯ ЗАКУПОК ===

  /// Получить активные закупки
  Future<Map<String, dynamic>> getBatches({
    String status = 'active',
    int page = 1,
    int limit = 10,
  }) async {
    return await _makeRequest('GET', '/batches', queryParams: {
      'status': status,
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  /// Получить закупку по ID
  Future<Map<String, dynamic>> getBatch(int batchId) async {
    return await _makeRequest('GET', '/batches/$batchId');
  }

  /// Присоединиться к закупке
  Future<Map<String, dynamic>> joinBatch({
    required int batchId,
    required List<Map<String, dynamic>> items,
  }) async {
    return await _makeRequest('POST', '/batches/$batchId/join', body: {
      'items': items,
    });
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  /// Проверка здоровья сервера
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final uri = Uri.parse('${baseUrl.replaceAll('/api', '')}/health');
      final response = await _client.get(uri).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Сервер работает',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Сервер недоступен (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Не удалось подключиться к серверу: $e',
      };
    }
  }

  /// Закрытие клиента
  void dispose() {
    _client.close();
  }
}

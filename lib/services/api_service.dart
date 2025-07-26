// lib/services/api_service.dart - ОБНОВЛЕННАЯ ВЕРСИЯ
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL сервера - используем наш готовый backend
  static const String baseUrl = kDebugMode
      ? 'http://localhost:3000/api' // Локальный сервер для разработки
      : 'https://your-cloud-server.com/api'; // Облачный сервер для продакшена

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

  // === МЕТОДЫ ДЛЯ АВТОРИЗАЦИИ ===

  /// Регистрация пользователя
  Future<Map<String, dynamic>> register({
    required String phone,
    required String firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      if (kDebugMode) {
        print('API: Регистрация пользователя $phone');
      }

      final body = <String, dynamic>{
        'phone': phone,
        'firstName': firstName,
      };

      // Добавляем только непустые поля
      if (lastName != null && lastName.isNotEmpty) {
        body['lastName'] = lastName;
      }
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('API: Ответ регистрации - ${response.statusCode}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Сохраняем токен
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }

        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'message': data['message'] ?? 'Регистрация успешна',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Ошибка регистрации',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка регистрации - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу: $e',
      };
    }
  }

  /// Вход пользователя по SMS коду
  Future<Map<String, dynamic>> login({
    required String phone,
    required String smsCode,
  }) async {
    try {
      if (kDebugMode) {
        print('API: Вход пользователя $phone с кодом $smsCode');
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'phone': phone,
          'smsCode': smsCode,
        }),
      );

      if (kDebugMode) {
        print('API: Ответ входа - ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Сохраняем токен
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }

        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Ошибка входа',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка входа - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Получить профиль пользователя
  Future<Map<String, dynamic>> getProfile() async {
    try {
      if (kDebugMode) {
        print('API: Получение профиля пользователя');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': 'Не удалось получить профиль',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения профиля - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  // === МЕТОДЫ ДЛЯ ТОВАРОВ ===

  /// Получить все товары
  Future<Map<String, dynamic>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (kDebugMode) {
        print('API: Получение товаров');
      }

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

      final uri =
          Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _defaultHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'products': data['products'],
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'error': 'Не удалось загрузить товары',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения товаров - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Получить товар по ID
  Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'product': data['product'],
        };
      } else {
        return {
          'success': false,
          'error': 'Товар не найден',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения товара - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Получить все категории
  Future<Map<String, dynamic>> getCategories() async {
    try {
      if (kDebugMode) {
        print('API: Получение категорий');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/products/categories/all'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'categories': data['categories'],
        };
      } else {
        return {
          'success': false,
          'error': 'Не удалось загрузить категории',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения категорий - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  // === МЕТОДЫ ДЛЯ АДРЕСОВ ===

  /// Получить все адреса пользователя
  Future<Map<String, dynamic>> getAddresses() async {
    try {
      if (kDebugMode) {
        print('API: Получение адресов');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/addresses'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'addresses': data['addresses'],
        };
      } else {
        return {
          'success': false,
          'error': 'Не удалось загрузить адреса',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения адресов - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Добавить новый адрес
  Future<Map<String, dynamic>> addAddress({
    required String title,
    required String address,
    bool isDefault = false,
  }) async {
    try {
      if (kDebugMode) {
        print('API: Добавление адреса');
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/addresses'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'title': title,
          'address': address,
          'isDefault': isDefault,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'address': data['address'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Ошибка добавления адреса',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка добавления адреса - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  // === МЕТОДЫ ДЛЯ ЗАКАЗОВ ===

  /// Получить заказы пользователя
  Future<Map<String, dynamic>> getOrders({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (kDebugMode) {
        print('API: Получение заказов');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final uri =
          Uri.parse('$baseUrl/orders').replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _defaultHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'orders': data['orders'],
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'error': 'Не удалось загрузить заказы',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения заказов - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Создать новый заказ
  Future<Map<String, dynamic>> createOrder({
    required int addressId,
    int? batchId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      if (kDebugMode) {
        print('API: Создание заказа');
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/orders'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'addressId': addressId,
          'batchId': batchId,
          'items': items,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'order': data['order'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Ошибка создания заказа',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка создания заказа - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  // === МЕТОДЫ ДЛЯ ЗАКУПОК ===

  /// Получить активные закупки
  Future<Map<String, dynamic>> getBatches({String status = 'active'}) async {
    try {
      if (kDebugMode) {
        print('API: Получение закупок со статусом $status');
      }

      final uri = Uri.parse('$baseUrl/batches').replace(queryParameters: {
        'status': status,
      });

      final response = await _client.get(uri, headers: _defaultHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'batches': data['batches'],
        };
      } else {
        return {
          'success': false,
          'error': 'Не удалось загрузить закупки',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения закупок - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Получить закупку по ID
  Future<Map<String, dynamic>> getBatch(int batchId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/batches/$batchId'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'batch': data['batch'],
        };
      } else {
        return {
          'success': false,
          'error': 'Закупка не найдена',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка получения закупки - $e');
      }
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Проверка подключения к серверу
  Future<bool> checkConnection() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${baseUrl.replaceAll('/api', '')}/health'),
            headers: _defaultHeaders,
          )
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('API: Ошибка подключения - $e');
      }
      return false;
    }
  }

  /// Закрытие HTTP клиента
  void dispose() {
    _client.close();
  }
}

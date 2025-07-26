import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL сервера - в продакшене будет облачный сервер
  static const String baseUrl = kDebugMode
      ? 'http://192.168.88.229:3000/api' // Локальный сервер для разработки
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
    print('API: Токен установлен: ${token?.substring(0, 10)}...');
  }

  /// Очищает токен авторизации
  void clearAuthToken() {
    _authToken = null;
    print('API: Токен очищен');
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
      print('API: Регистрация пользователя $phone');

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

      print('API: Ответ регистрации - ${response.statusCode}');
      print('API: Тело ответа - ${response.body}');

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
      print('API: Ошибка регистрации - $e');
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
      print('API: Вход пользователя $phone с кодом $smsCode');

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'phone': phone,
          'smsCode': smsCode,
        }),
      );

      print('API: Ответ входа - ${response.statusCode}');

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
      print('API: Ошибка входа - $e');
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Получить профиль пользователя
  Future<Map<String, dynamic>> getProfile() async {
    try {
      print('API: Получение профиля пользователя');

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
      print('API: Ошибка получения профиля - $e');
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
      print('API: Получение товаров (page: $page, limit: $limit)');

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
        if (categoryId != null) 'categoryId': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'limit': limit.toString(),
      });

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
      print('API: Ошибка получения товаров - $e');
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
      print('API: Ошибка получения товара - $e');
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Получить все категории
  Future<Map<String, dynamic>> getCategories() async {
    try {
      print('API: Получение категорий');

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
      print('API: Ошибка получения категорий - $e');
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  // === МЕТОДЫ ДЛЯ ЗАКАЗОВ ===

  /// Получить заказы пользователя
  Future<Map<String, dynamic>> getOrders({
    int? userId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('API: Получение заказов');

      final uri = Uri.parse('$baseUrl/orders').replace(queryParameters: {
        if (userId != null) 'userId': userId.toString(),
        if (status != null) 'status': status,
        'page': page.toString(),
        'limit': limit.toString(),
      });

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
      print('API: Ошибка получения заказов - $e');
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    }
  }

  /// Создать новый заказ
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int addressId,
    int? batchId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      print('API: Создание заказа для пользователя $userId');

      final response = await _client.post(
        Uri.parse('$baseUrl/orders'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'userId': userId,
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
      print('API: Ошибка создания заказа - $e');
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
      print('API: Получение закупок со статусом $status');

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
      print('API: Ошибка получения закупок - $e');
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
      print('API: Ошибка получения закупки - $e');
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
      print('API: Ошибка подключения - $e');
      return false;
    }
  }

  /// Закрытие HTTP клиента
  void dispose() {
    _client.close();
  }
}

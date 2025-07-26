import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    // Заглушка - пока всегда неавторизован
    await Future.delayed(Duration(seconds: 1));
    _isAuthenticated = false;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    // Заглушка для логина - имитируем запрос к серверу
    await Future.delayed(Duration(seconds: 2));

    // Для демо всегда успешно
    _isAuthenticated = true;
    _currentUser = User(
      id: 1,
      phone: phone,
      name: 'Тестовый пользователь',
      createdAt: DateTime.now(),
      isActive: true,
    );

    _isLoading = false;
    notifyListeners();

    return true;
  }

  Future<bool> register(String phone, String firstName, String password,
      {String? lastName}) async {
    _isLoading = true;
    notifyListeners();

    // Заглушка для регистрации - имитируем запрос к серверу
    await Future.delayed(Duration(seconds: 2));

    // Для демо всегда успешно
    _isAuthenticated = true;
    _currentUser = User(
      id: 1,
      phone: phone,
      name: firstName,
      createdAt: DateTime.now(),
      isActive: true,
    );

    _isLoading = false;
    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}

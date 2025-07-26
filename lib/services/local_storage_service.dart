// lib/services/local_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  LocalStorageService._();

  // Безопасное хранилище для токенов и чувствительных данных
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Database? _database;
  SharedPreferences? _prefs;

  // Инициализация хранилища
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initDatabase();
  }

  // Инициализация базы данных
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'severnaya_korzina.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Таблица пользователей
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone TEXT UNIQUE NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT,
            email TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            is_active INTEGER DEFAULT 1
          )
        ''');

        // Таблица адресов
        await db.execute('''
          CREATE TABLE user_addresses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            address TEXT NOT NULL,
            is_default INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Таблица настроек
        await db.execute('''
          CREATE TABLE user_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            key TEXT NOT NULL,
            value TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, key)
          )
        ''');
      },
    );
  }

  // === РАБОТА С ПОЛЬЗОВАТЕЛЯМИ ===

  /// Сохраняет пользователя в локальную БД
  Future<int> saveUser(User user) async {
    final db = _database!;

    final userMap = {
      'phone': user.phone,
      'first_name': user.name,
      'last_name': user.lastName,
      'email': user.email,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': user.isActive ? 1 : 0,
    };

    try {
      // Пытаемся вставить нового пользователя
      return await db.insert('users', userMap);
    } catch (e) {
      // Если пользователь уже существует, обновляем его
      await db.update(
        'users',
        userMap,
        where: 'phone = ?',
        whereArgs: [user.phone],
      );

      // Возвращаем ID существующего пользователя
      final existingUsers = await db.query(
        'users',
        where: 'phone = ?',
        whereArgs: [user.phone],
        limit: 1,
      );

      return existingUsers.first['id'] as int;
    }
  }

  /// Получает пользователя по номеру телефона
  Future<User?> getUserByPhone(String phone) async {
    final db = _database!;

    final users = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );

    if (users.isEmpty) return null;

    final userData = users.first;
    return User(
      id: userData['id'] as int,
      phone: userData['phone'] as String,
      name: userData['first_name'] as String,
      lastName: userData['last_name'] as String?,
      email: userData['email'] as String?,
      createdAt: DateTime.parse(userData['created_at'] as String),
      isActive: (userData['is_active'] as int) == 1,
    );
  }

  /// Получает всех пользователей
  Future<List<User>> getAllUsers() async {
    final db = _database!;
    final users = await db.query('users', orderBy: 'created_at DESC');

    return users
        .map((userData) => User(
              id: userData['id'] as int,
              phone: userData['phone'] as String,
              name: userData['first_name'] as String,
              lastName: userData['last_name'] as String?,
              email: userData['email'] as String?,
              createdAt: DateTime.parse(userData['created_at'] as String),
              isActive: (userData['is_active'] as int) == 1,
            ))
        .toList();
  }

  /// Удаляет пользователя
  Future<void> deleteUser(String phone) async {
    final db = _database!;
    await db.delete('users', where: 'phone = ?', whereArgs: [phone]);
  }

  // === РАБОТА С АДРЕСАМИ ===

  /// Сохраняет адрес пользователя
  Future<void> saveUserAddress(int userId, String title, String address,
      {bool isDefault = false}) async {
    final db = _database!;

    // Если этот адрес должен быть по умолчанию, убираем флаг у других
    if (isDefault) {
      await db.update(
        'user_addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    await db.insert('user_addresses', {
      'user_id': userId,
      'title': title,
      'address': address,
      'is_default': isDefault ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Получает адреса пользователя
  Future<List<Map<String, dynamic>>> getUserAddresses(int userId) async {
    final db = _database!;
    return await db.query(
      'user_addresses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_default DESC, created_at DESC',
    );
  }

  // === РАБОТА С ТОКЕНАМИ И БЕЗОПАСНЫМИ ДАННЫМИ ===

  /// Сохраняет токен авторизации
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  /// Получает токен авторизации
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  /// Удаляет токен авторизации
  Future<void> removeAuthToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  /// Сохраняет информацию об автологине
  Future<void> saveAutoLoginInfo(String phone, {int daysValid = 30}) async {
    final expiryDate = DateTime.now().add(Duration(days: daysValid));
    await _secureStorage.write(
      key: 'auto_login_phone',
      value: phone,
    );
    await _secureStorage.write(
      key: 'auto_login_expiry',
      value: expiryDate.toIso8601String(),
    );
  }

  /// Проверяет, доступен ли автологин
  Future<String?> getAutoLoginPhone() async {
    final phone = await _secureStorage.read(key: 'auto_login_phone');
    final expiryStr = await _secureStorage.read(key: 'auto_login_expiry');

    if (phone == null || expiryStr == null) return null;

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      // Автологин истек
      await removeAutoLoginInfo();
      return null;
    }

    return phone;
  }

  /// Удаляет информацию об автологине
  Future<void> removeAutoLoginInfo() async {
    await _secureStorage.delete(key: 'auto_login_phone');
    await _secureStorage.delete(key: 'auto_login_expiry');
  }

  // === РАБОТА С НАСТРОЙКАМИ ===

  /// Сохраняет настройку пользователя
  Future<void> saveUserSetting(int userId, String key, String value) async {
    final db = _database!;

    await db.insert(
      'user_settings',
      {
        'user_id': userId,
        'key': key,
        'value': value,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получает настройку пользователя
  Future<String?> getUserSetting(int userId, String key) async {
    final db = _database!;

    final settings = await db.query(
      'user_settings',
      where: 'user_id = ? AND key = ?',
      whereArgs: [userId, key],
      limit: 1,
    );

    if (settings.isEmpty) return null;
    return settings.first['value'] as String?;
  }

  // === ОБЩИЕ НАСТРОЙКИ ПРИЛОЖЕНИЯ ===

  /// Сохраняет настройку приложения
  Future<void> saveAppSetting(String key, dynamic value) async {
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else {
      await _prefs!.setString(key, jsonEncode(value));
    }
  }

  /// Получает настройку приложения
  T? getAppSetting<T>(String key) {
    if (T == String) {
      return _prefs!.getString(key) as T?;
    } else if (T == int) {
      return _prefs!.getInt(key) as T?;
    } else if (T == bool) {
      return _prefs!.getBool(key) as T?;
    } else if (T == double) {
      return _prefs!.getDouble(key) as T?;
    } else {
      final stringValue = _prefs!.getString(key);
      if (stringValue == null) return null;
      return jsonDecode(stringValue) as T;
    }
  }

  /// Очищает все данные (для выхода из аккаунта)
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    await _prefs!.clear();
    await _database!.delete('users');
    await _database!.delete('user_addresses');
    await _database!.delete('user_settings');
  }
}

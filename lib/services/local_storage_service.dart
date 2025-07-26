// lib/services/local_storage_service.dart - ОБНОВЛЕННАЯ ВЕРСИЯ
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

  // Ключи для хранения
  static const String _authTokenKey = 'auth_token';
  static const String _autoLoginPhoneKey = 'auto_login_phone';
  static const String _autoLoginExpiryKey = 'auto_login_expiry';
  static const String _userDataKey = 'user_data';

  /// Инициализация хранилища
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initDatabase();
  }

  /// Инициализация базы данных
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'severnaya_korzina.db');

    _database = await openDatabase(
      path,
      version: 2, // Увеличили версию для обновления схемы
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Создание базы данных
  Future<void> _createDatabase(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        phone TEXT UNIQUE NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT,
        email TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_active INTEGER DEFAULT 1,
        avatar_url TEXT
      )
    ''');

    // Таблица адресов
    await db.execute('''
      CREATE TABLE user_addresses (
        id INTEGER PRIMARY KEY,
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

    // Таблица корзины (локальное хранение)
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        added_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, product_id)
      )
    ''');
  }

  /// Обновление базы данных
  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Добавляем новые поля и таблицы для версии 2
      try {
        await db.execute('ALTER TABLE users ADD COLUMN avatar_url TEXT');
      } catch (e) {
        // Поле уже существует
      }

      try {
        await db.execute('''
          CREATE TABLE cart_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            added_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, product_id)
          )
        ''');
      } catch (e) {
        // Таблица уже существует
      }
    }
  }

  // === РАБОТА С ТОКЕНАМИ ===

  /// Сохраняет токен авторизации
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  /// Получает токен авторизации
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  /// Удаляет токен авторизации
  Future<void> removeAuthToken() async {
    await _secureStorage.delete(key: _authTokenKey);
  }

  // === РАБОТА С АВТОЛОГИНОМ ===

  /// Сохраняет информацию для автологина
  Future<void> saveAutoLoginInfo(String phone, {int daysValid = 30}) async {
    final expiryDate = DateTime.now().add(Duration(days: daysValid));

    await _secureStorage.write(key: _autoLoginPhoneKey, value: phone);
    await _secureStorage.write(
      key: _autoLoginExpiryKey,
      value: expiryDate.toIso8601String(),
    );
  }

  /// Получает телефон для автологина
  Future<String?> getAutoLoginPhone() async {
    final phone = await _secureStorage.read(key: _autoLoginPhoneKey);
    final expiryStr = await _secureStorage.read(key: _autoLoginExpiryKey);

    if (phone == null || expiryStr == null) return null;

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      await removeAutoLoginInfo();
      return null;
    }

    return phone;
  }

  /// Удаляет информацию автологина
  Future<void> removeAutoLoginInfo() async {
    await _secureStorage.delete(key: _autoLoginPhoneKey);
    await _secureStorage.delete(key: _autoLoginExpiryKey);
  }

  // === РАБОТА С ПОЛЬЗОВАТЕЛЯМИ ===

  /// Сохраняет пользователя в локальную БД
  Future<int> saveUser(User user) async {
    final db = _database!;

    final userMap = {
      'id': user.id,
      'phone': user.phone,
      'first_name': user.name,
      'last_name': user.lastName,
      'email': user.email,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': user.isActive ? 1 : 0,
      'avatar_url': user.avatarUrl,
    };

    try {
      // Используем insert or replace для обновления/вставки
      return await db.insert(
        'users',
        userMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Ошибка сохранения пользователя: $e');
      rethrow;
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
      updatedAt: userData['updated_at'] != null
          ? DateTime.parse(userData['updated_at'] as String)
          : null,
      isActive: (userData['is_active'] as int) == 1,
      avatarUrl: userData['avatar_url'] as String?,
    );
  }

  /// Получает пользователя по ID
  Future<User?> getUserById(int userId) async {
    final db = _database!;

    final users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
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
      updatedAt: userData['updated_at'] != null
          ? DateTime.parse(userData['updated_at'] as String)
          : null,
      isActive: (userData['is_active'] as int) == 1,
      avatarUrl: userData['avatar_url'] as String?,
    );
  }

  /// Удаляет пользователя
  Future<void> deleteUser(String phone) async {
    final db = _database!;
    await db.delete('users', where: 'phone = ?', whereArgs: [phone]);
  }

  // === РАБОТА С АДРЕСАМИ ===

  /// Сохраняет адрес пользователя
  Future<int> saveUserAddress(int userId, String title, String address,
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

    return await db.insert('user_addresses', {
      'user_id': userId,
      'title': title,
      'address': address,
      'is_default': isDefault ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Получает адреса пользователя
  Future<List<UserAddress>> getUserAddresses(int userId) async {
    final db = _database!;

    final addresses = await db.query(
      'user_addresses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_default DESC, created_at DESC',
    );

    return addresses
        .map((addr) => UserAddress(
              id: addr['id'] as int,
              title: addr['title'] as String,
              address: addr['address'] as String,
              isDefault: (addr['is_default'] as int) == 1,
              createdAt: DateTime.parse(addr['created_at'] as String),
            ))
        .toList();
  }

  // === РАБОТА С КОРЗИНОЙ (локальное хранение) ===

  /// Добавляет товар в корзину
  Future<void> addToCart(
      int userId, int productId, int quantity, double price) async {
    final db = _database!;

    await db.insert(
      'cart_items',
      {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
        'price': price,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получает товары из корзины
  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    final db = _database!;

    return await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'added_at DESC',
    );
  }

  /// Обновляет количество товара в корзине
  Future<void> updateCartItemQuantity(
      int userId, int productId, int quantity) async {
    final db = _database!;

    if (quantity <= 0) {
      await removeFromCart(userId, productId);
    } else {
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    }
  }

  /// Удаляет товар из корзины
  Future<void> removeFromCart(int userId, int productId) async {
    final db = _database!;

    await db.delete(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  /// Очищает корзину
  Future<void> clearCart(int userId) async {
    final db = _database!;

    await db.delete(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // === РАБОТА С НАСТРОЙКАМИ ===

  /// Сохраняет строковое значение
  Future<void> setString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  /// Получает строковое значение
  String? getString(String key) {
    return _prefs!.getString(key);
  }

  /// Сохраняет булево значение
  Future<void> setBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  /// Получает булево значение
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs!.getBool(key) ?? defaultValue;
  }

  /// Сохраняет числовое значение
  Future<void> setInt(String key, int value) async {
    await _prefs!.setInt(key, value);
  }

  /// Получает числовое значение
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs!.getInt(key) ?? defaultValue;
  }

  /// Удаляет значение по ключу
  Future<void> remove(String key) async {
    await _prefs!.remove(key);
  }

  /// Очищает все данные
  Future<void> clear() async {
    await _prefs!.clear();
    await _secureStorage.deleteAll();

    // Очищаем базу данных
    final db = _database!;
    await db.delete('users');
    await db.delete('user_addresses');
    await db.delete('user_settings');
    await db.delete('cart_items');
  }

  /// Закрывает базу данных
  Future<void> dispose() async {
    await _database?.close();
  }
}

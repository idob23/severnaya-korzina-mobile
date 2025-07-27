// lib/models/user.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/foundation.dart';
part 'user.g.dart'; // Для генерации кода

class User {
  final int id;
  final String phone;
  final String name; // firstName в API
  final String? lastName;
  final String? email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? avatarUrl;

  // Дополнительные поля для локального хранения
  final List<UserAddress>? addresses;
  final Map<String, dynamic>? settings;

  User({
    required this.id,
    required this.phone,
    required this.name,
    this.lastName,
    this.email,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.avatarUrl,
    this.addresses,
    this.settings,
  });

  /// Создает пользователя из JSON ответа API
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        print('🔧 Создание User из JSON: $json');
      }

      // Обрабатываем адреса, если они есть
      List<UserAddress>? addresses;
      try {
        if (json['addresses'] != null && json['addresses'] is List) {
          addresses = (json['addresses'] as List)
              .map((addr) => UserAddress.fromJson(addr))
              .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка обработки адресов: $e');
        }
        addresses = [];
      }

      // Безопасная обработка даты
      DateTime createdAt;
      try {
        if (json['createdAt'] != null) {
          createdAt = DateTime.parse(json['createdAt'].toString());
        } else if (json['created_at'] != null) {
          createdAt = DateTime.parse(json['created_at'].toString());
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка парсинга даты createdAt: $e');
        }
        createdAt = DateTime.now();
      }

      // Безопасная обработка даты обновления
      DateTime? updatedAt;
      try {
        if (json['updatedAt'] != null) {
          updatedAt = DateTime.parse(json['updatedAt'].toString());
        } else if (json['updated_at'] != null) {
          updatedAt = DateTime.parse(json['updated_at'].toString());
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка парсинга даты updatedAt: $e');
        }
        updatedAt = null;
      }

      final user = User(
        id: json['id'] ?? 0,
        phone: json['phone']?.toString() ?? '',
        // ИСПРАВЛЕНО: Приоритет полю 'name', затем 'firstName'
        name: json['name']?.toString() ??
            json['firstName']?.toString() ??
            json['first_name']?.toString() ??
            '',
        lastName: json['lastName']?.toString() ?? json['last_name']?.toString(),
        email: json['email']?.toString(),
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: json['isActive'] ?? json['is_active'] ?? true,
        avatarUrl:
            json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
        addresses: addresses,
      );

      if (kDebugMode) {
        print('✅ User создан успешно: ${user.fullName}');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка при создании User из JSON: $e');
        print('JSON data: $json');
      }

      // Возвращаем пользователя с минимальными данными
      return User(
        id: json['id'] ?? 0,
        phone: json['phone']?.toString() ?? '',
        name: json['name']?.toString() ??
            json['firstName']?.toString() ??
            'Пользователь',
        createdAt: DateTime.now(),
        isActive: true,
      );
    }
  }

  /// Преобразует пользователя в JSON для отправки на API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'firstName': name,
      'lastName': lastName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'avatarUrl': avatarUrl,
    };
  }

  /// Создает копию пользователя с измененными полями
  User copyWith({
    int? id,
    String? phone,
    String? name,
    String? lastName,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? avatarUrl,
    List<UserAddress>? addresses,
    Map<String, dynamic>? settings,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addresses: addresses ?? this.addresses,
      settings: settings ?? this.settings,
    );
  }

  /// Возвращает полное имя пользователя
  String get fullName {
    try {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$name $lastName';
      }
      return name;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении fullName: $e');
      }
      return name.isNotEmpty ? name : 'Пользователь';
    }
  }

  /// Возвращает инициалы для аватара
  String get initials {
    try {
      final nameWords = fullName.split(' ');
      if (nameWords.length >= 2) {
        return '${nameWords[0][0]}${nameWords[1][0]}'.toUpperCase();
      } else if (nameWords.isNotEmpty && nameWords[0].isNotEmpty) {
        return nameWords[0][0].toUpperCase();
      }
      return 'U';
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении initials: $e');
      }
      return 'U';
    }
  }

  /// Проверяет, заполнен ли профиль полностью
  bool get isProfileComplete {
    try {
      return name.isNotEmpty &&
          phone.isNotEmpty &&
          (addresses?.isNotEmpty ?? false);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при проверке isProfileComplete: $e');
      }
      return false;
    }
  }

  /// Возвращает основной адрес пользователя
  UserAddress? get defaultAddress {
    try {
      if (addresses == null || addresses!.isEmpty) return null;

      try {
        return addresses!.firstWhere((addr) => addr.isDefault);
      } catch (e) {
        return addresses!.first; // Если нет основного, возвращаем первый
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении defaultAddress: $e');
      }
      return null;
    }
  }

  @override
  String toString() {
    return 'User(id: $id, phone: $phone, name: $name, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.phone == phone;
  }

  @override
  int get hashCode {
    return id.hashCode ^ phone.hashCode;
  }
}

/// Модель адреса пользователя
class UserAddress {
  final int? id;
  final String title;
  final String address;
  final bool isDefault;
  final DateTime? createdAt;

  UserAddress({
    this.id,
    required this.title,
    required this.address,
    this.isDefault = false,
    this.createdAt,
  });

  /// Создает адрес из JSON ответа API
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        print('🔧 Создание UserAddress из JSON: $json');
      }

      // Безопасная обработка даты
      DateTime? createdAt;
      try {
        if (json['createdAt'] != null) {
          createdAt = DateTime.parse(json['createdAt'].toString());
        } else if (json['created_at'] != null) {
          createdAt = DateTime.parse(json['created_at'].toString());
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка парсинга даты в UserAddress: $e');
        }
        createdAt = null;
      }

      final address = UserAddress(
        id: json['id'],
        title: json['title']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        isDefault: json['isDefault'] ?? json['is_default'] ?? false,
        createdAt: createdAt,
      );

      if (kDebugMode) {
        print('✅ UserAddress создан успешно: ${address.title}');
      }

      return address;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка при создании UserAddress из JSON: $e');
        print('JSON data: $json');
      }
      // Возвращаем адрес с минимальными данными
      return UserAddress(
        title: 'Адрес',
        address: '',
      );
    }
  }

  /// Преобразует адрес в JSON для отправки на API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'isDefault': isDefault,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Создает копию адреса с измененными полями
  UserAddress copyWith({
    int? id,
    String? title,
    String? address,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return UserAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserAddress(id: $id, title: $title, address: $address, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAddress &&
        other.id == id &&
        other.title == title &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ address.hashCode;
  }
}

/// Модель пользователя для админ панели
class AdminUser {
  final String id;
  final String phone;
  final String name;
  final String? lastName;
  final bool isActive;
  final bool isVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final int totalOrders;
  final double totalSpent;

  AdminUser({
    required this.id,
    required this.phone,
    required this.name,
    this.lastName,
    required this.isActive,
    required this.isVerified,
    this.lastLoginAt,
    required this.createdAt,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    try {
      return AdminUser(
        id: json['id']?.toString() ?? '',
        phone: json['phone'] ?? '',
        name: json['name'] ?? json['firstName'] ?? '',
        lastName: json['last_name'] ?? json['lastName'],
        isActive: json['is_active'] ?? json['isActive'] ?? true,
        isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
        lastLoginAt: json['last_login_at'] != null
            ? DateTime.parse(json['last_login_at'])
            : (json['lastLoginAt'] != null
                ? DateTime.parse(json['lastLoginAt'])
                : null),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now()),
        totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
        totalSpent:
            (json['total_spent'] ?? json['totalSpent'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при создании AdminUser из JSON: $e');
        print('JSON data: $json');
      }
      // Возвращаем пользователя с минимальными данными
      return AdminUser(
        id: json['id']?.toString() ?? '',
        phone: json['phone'] ?? '',
        name: json['name'] ?? json['firstName'] ?? 'Пользователь',
        isActive: true,
        isVerified: false,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'last_name': lastName,
      'is_active': isActive,
      'is_verified': isVerified,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'total_orders': totalOrders,
      'total_spent': totalSpent,
    };
  }

  String get fullName {
    try {
      return lastName != null && lastName!.isNotEmpty
          ? '$name $lastName'
          : name;
    } catch (e) {
      return name.isNotEmpty ? name : 'Пользователь';
    }
  }

  String get status => isActive ? 'Активен' : 'Заблокирован';
}

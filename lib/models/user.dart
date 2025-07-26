// lib/models/user.dart - ОБНОВЛЕННАЯ ВЕРСИЯ ДЛЯ РАБОТЫ С API
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
    // Обрабатываем адреса, если они есть
    List<UserAddress>? addresses;
    if (json['addresses'] != null) {
      addresses = (json['addresses'] as List)
          .map((addr) => UserAddress.fromJson(addr))
          .toList();
    }

    return User(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      name: json['firstName'] ?? json['name'] ?? '',
      lastName: json['lastName'],
      email: json['email'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      addresses: addresses,
    );
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
    if (lastName != null && lastName!.isNotEmpty) {
      return '$name $lastName';
    }
    return name;
  }

  /// Возвращает инициалы для аватара
  String get initials {
    final nameWords = fullName.split(' ');
    if (nameWords.length >= 2) {
      return '${nameWords[0][0]}${nameWords[1][0]}'.toUpperCase();
    } else if (nameWords.isNotEmpty) {
      return nameWords[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Проверяет, заполнен ли профиль полностью
  bool get isProfileComplete {
    return name.isNotEmpty &&
        phone.isNotEmpty &&
        (addresses?.isNotEmpty ?? false);
  }

  /// Возвращает основной адрес пользователя
  UserAddress? get defaultAddress {
    if (addresses == null || addresses!.isEmpty) return null;

    try {
      return addresses!.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return addresses!.first; // Если нет основного, возвращаем первый
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
    return UserAddress(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null),
    );
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

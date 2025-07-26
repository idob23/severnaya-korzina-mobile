// lib/models/user.dart - ОБНОВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/foundation.dart';

part 'user.g.dart'; // Для генерации кода

class User {
  final int id;
  final String phone;
  final String name;
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      name: json['name'] ?? json['firstName'] ?? '',
      lastName: json['lastName'],
      email: json['email'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'first_name': name, // для совместимости
      'last_name': lastName,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'avatar_url': avatarUrl,
    };
  }

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

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      isDefault: json['is_default'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }

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
    return 'UserAddress(title: $title, address: $address, isDefault: $isDefault)';
  }
}

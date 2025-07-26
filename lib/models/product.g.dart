// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      approximatePrice: (json['approximatePrice'] as num).toDouble(),
      lastPurchasePrice: (json['lastPurchasePrice'] as num?)?.toDouble(),
      lastPurchaseDate: json['lastPurchaseDate'] == null
          ? null
          : DateTime.parse(json['lastPurchaseDate'] as String),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'approximatePrice': instance.approximatePrice,
      'lastPurchasePrice': instance.lastPurchasePrice,
      'lastPurchaseDate': instance.lastPurchaseDate?.toIso8601String(),
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
    };

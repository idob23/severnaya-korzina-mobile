import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String category;
  final double approximatePrice;
  final double? lastPurchasePrice;
  final DateTime? lastPurchaseDate;
  final String description;
  final String? imageUrl;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.approximatePrice,
    this.lastPurchasePrice,
    this.lastPurchaseDate,
    required this.description,
    this.imageUrl,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
// Generated file test

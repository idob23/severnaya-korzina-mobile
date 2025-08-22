// lib/models/order.dart - ОБНОВЛЕННАЯ ВЕРСИЯ С ПРАВИЛЬНЫМИ СТАТУСАМИ
import '../constants/order_status.dart';

/// Модель заказа для API
class Order {
  final int id;
  final int userId;
  final int addressId;
  final int? batchId;
  final String status;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Связанные данные
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? batch;
  final List<OrderItem>? orderItems;

  Order({
    required this.id,
    required this.userId,
    required this.addressId,
    this.batchId,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.address,
    this.batch,
    this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      addressId: json['addressId'] ?? 0,
      batchId: json['batchId'],
      status: json['status'] ?? 'pending',
      totalAmount:
          double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      user: json['user'],
      address: json['address'],
      batch: json['batch'],
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'addressId': addressId,
      'batchId': batchId,
      'status': status,
      'totalAmount': totalAmount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Форматированная сумма
  String get formattedAmount {
    return '${totalAmount.toStringAsFixed(0)} ₽';
  }

  /// Количество товаров в заказе
  int get itemsCount {
    return orderItems?.length ?? 0;
  }

  /// Общее количество единиц товара
  int get totalItems {
    if (orderItems == null) return 0;
    return orderItems!.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Статус на русском - ИСПОЛЬЗУЕТ КОНСТАНТЫ
  String get statusText {
    return statusTexts[status] ?? status;
  }

  /// Цвет статуса - ИСПОЛЬЗУЕТ КОНСТАНТЫ
  String get statusColor {
    return statusColors[status] ?? 'grey';
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $status, amount: $formattedAmount)';
  }
}

/// Модель позиции заказа
class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final Map<String, dynamic>? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  /// Общая стоимость позиции
  double get totalPrice {
    return price * quantity;
  }

  /// Форматированная общая стоимость
  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(0)} ₽';
  }

  /// Название товара
  String get productName {
    return product?['name'] ?? 'Товар #$productId';
  }

  /// Единица измерения
  String get unit {
    return product?['unit'] ?? 'шт';
  }
}

import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'order.g.dart';

enum OrderStatus { pending, paid, processing, ready, completed, cancelled }

@JsonSerializable()
class Order {
  final int id;
  final int userId;
  final OrderStatus status;
  final double totalApproximate;
  final double? totalActual;
  final double prepaymentAmount;
  final bool prepaymentPaid;
  final DateTime createdAt;
  final DateTime? deliveryDate;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalApproximate,
    this.totalActual,
    required this.prepaymentAmount,
    required this.prepaymentPaid,
    required this.createdAt,
    this.deliveryDate,
    required this.items,
  });

  double get finalPayment =>
      (totalActual ?? totalApproximate) - prepaymentAmount;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderItem {
  final int id;
  final int productId;
  final Product product;
  final int quantity;
  final double approximatePrice;
  final double? actualPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.approximatePrice,
    this.actualPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
// Generated file test

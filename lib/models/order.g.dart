// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      totalApproximate: (json['totalApproximate'] as num).toDouble(),
      totalActual: (json['totalActual'] as num?)?.toDouble(),
      prepaymentAmount: (json['prepaymentAmount'] as num).toDouble(),
      prepaymentPaid: json['prepaymentPaid'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveryDate: json['deliveryDate'] == null
          ? null
          : DateTime.parse(json['deliveryDate'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'totalApproximate': instance.totalApproximate,
      'totalActual': instance.totalActual,
      'prepaymentAmount': instance.prepaymentAmount,
      'prepaymentPaid': instance.prepaymentPaid,
      'createdAt': instance.createdAt.toIso8601String(),
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'items': instance.items,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.paid: 'paid',
  OrderStatus.processing: 'processing',
  OrderStatus.ready: 'ready',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      approximatePrice: (json['approximatePrice'] as num).toDouble(),
      actualPrice: (json['actualPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'product': instance.product,
      'quantity': instance.quantity,
      'approximatePrice': instance.approximatePrice,
      'actualPrice': instance.actualPrice,
    };

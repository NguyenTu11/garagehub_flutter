import 'OrderItemModel.dart';
import 'UserModel.dart';

class OrderModel {
  String? id;
  String? orderId;
  String? userId;
  UserModel? user;
  List<OrderItemModel> items;
  double totalAmount;
  String status; // Pending, Processing, Completed, Cancelled
  ShippingAddress? shippingAddress;
  String? paymentMethod;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  OrderModel({
    this.id,
    this.orderId,
    this.userId,
    this.user,
    required this.items,
    this.totalAmount = 0.0,
    this.status = 'Pending',
    this.shippingAddress,
    this.paymentMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'],
      orderId: json['orderId'],
      userId: json['userId'] is String
          ? json['userId']
          : json['userId']?['_id'] ?? json['userId']?['id'],
      user: json['userId'] is Map ? UserModel.fromJson(json['userId']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e))
              .toList()
          : [],
      totalAmount: json['totalAmount'] == null
          ? 0.0
          : double.parse(json['totalAmount'].toString()),
      status: json['status'] ?? 'Pending',
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromJson(json['shippingAddress'])
          : null,
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'shippingAddress': shippingAddress?.toJson(),
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }
}

class ShippingAddress {
  String? street;
  String? city;
  String? state;
  String? zipCode;

  ShippingAddress({
    this.street,
    this.city,
    this.state,
    this.zipCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}


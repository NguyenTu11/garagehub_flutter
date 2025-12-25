import 'OrderItemModel.dart';
import 'UserModel.dart';

class RepairOrderModel {
  String? id;
  String? orderId;
  String? customerId;
  UserModel? customer;
  String? employeeId;
  UserModel? employee;
  List<OrderItemModel> items;
  double totalAmount;
  String status; // Pending, Processing, Completed, Cancelled
  String? paymentMethod;
  String? notes;
  double repairCosts;
  DateTime? createdAt;
  DateTime? updatedAt;

  RepairOrderModel({
    this.id,
    this.orderId,
    this.customerId,
    this.customer,
    this.employeeId,
    this.employee,
    required this.items,
    this.totalAmount = 0.0,
    this.status = 'Pending',
    this.paymentMethod,
    this.notes,
    this.repairCosts = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory RepairOrderModel.fromJson(Map<String, dynamic> json) {
    return RepairOrderModel(
      id: json['_id'] ?? json['id'],
      orderId: json['orderId'],
      customerId: json['customerId'] is String
          ? json['customerId']
          : json['customerId']?['_id'] ?? json['customerId']?['id'],
      customer: json['customerId'] is Map
          ? UserModel.fromJson(json['customerId'])
          : null,
      employeeId: json['employeeId'] is String
          ? json['employeeId']
          : json['employeeId']?['_id'] ?? json['employeeId']?['id'],
      employee: json['employeeId'] is Map
          ? UserModel.fromJson(json['employeeId'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e))
              .toList()
          : [],
      totalAmount: json['totalAmount'] == null
          ? 0.0
          : double.parse(json['totalAmount'].toString()),
      status: json['status'] ?? 'Pending',
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      repairCosts: json['repairCosts'] == null
          ? 0.0
          : double.parse(json['repairCosts'].toString()),
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
      'customerId': customerId,
      'employeeId': employeeId,
      'items': items.map((e) => e.toJson()).toList(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'repairCosts': repairCosts,
    };
  }
}


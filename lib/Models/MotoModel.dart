import 'BrandModel.dart';
import 'UserModel.dart';

class MotoModel {
  String? id;
  String licensePlate;
  String? brandId;
  BrandModel? brand;
  String model;
  String? color;
  String? userId;
  UserModel? user;
  DateTime? createdAt;
  DateTime? updatedAt;

  MotoModel({
    this.id,
    required this.licensePlate,
    this.brandId,
    this.brand,
    required this.model,
    this.color,
    this.userId,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory MotoModel.fromJson(Map<String, dynamic> json) {
    return MotoModel(
      id: json['_id'] ?? json['id'],
      licensePlate: json['licensePlate'] ?? '',
      brandId: json['brandId'] is String
          ? json['brandId']
          : json['brandId']?['_id'] ?? json['brandId']?['id'],
      brand: json['brandId'] is Map
          ? BrandModel.fromJson(json['brandId'])
          : null,
      model: json['model'] ?? '',
      color: json['color'],
      userId: json['userId'] is String
          ? json['userId']
          : json['userId']?['_id'] ?? json['userId']?['id'],
      user: json['userId'] is Map ? UserModel.fromJson(json['userId']) : null,
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
      'licensePlate': licensePlate,
      'brandId': brandId,
      'model': model,
      'color': color,
      'userId': userId,
    };
  }
}


import 'BrandModel.dart';

class PartModel {
  String? id;
  String name;
  int quantity;
  double price;
  double buyPrice;
  double empPrice;
  String unit;
  int limitStock;
  String? brandId;
  BrandModel? brand;
  String image;

  PartModel({
    this.id,
    required this.name,
    this.quantity = 0,
    required this.price,
    required this.buyPrice,
    required this.empPrice,
    required this.unit,
    this.limitStock = 0,
    this.brandId,
    this.brand,
    this.image = '',
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] == null
          ? 0.0
          : double.parse(json['price'].toString()),
      buyPrice: json['buyPrice'] == null
          ? 0.0
          : double.parse(json['buyPrice'].toString()),
      empPrice: json['empPrice'] == null
          ? 0.0
          : double.parse(json['empPrice'].toString()),
      unit: json['unit'] ?? '',
      limitStock: json['limitStock'] ?? 0,
      brandId: json['brandId'] is String
          ? json['brandId']
          : json['brandId']?['_id'] ?? json['brandId']?['id'],
      brand: json['brandId'] is Map
          ? BrandModel.fromJson(json['brandId'])
          : null,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'buyPrice': buyPrice,
      'empPrice': empPrice,
      'unit': unit,
      'limitStock': limitStock,
      'brandId': brandId,
      'image': image,
    };
  }
}


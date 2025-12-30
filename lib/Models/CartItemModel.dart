import 'PartModel.dart';

class CartItemModel {
  String id;
  PartModel part;
  int quantity;

  CartItemModel({required this.id, required this.part, required this.quantity});

  double get subtotal => part.price * quantity;

  Map<String, dynamic> toJson() {
    return {'id': id, 'part': part.toJson(), 'quantity': quantity};
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      part: PartModel.fromJson(json['part']),
      quantity: json['quantity'],
    );
  }
}

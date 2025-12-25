class OrderItemModel {
  String? partId;
  String? name;
  double? price;
  int quantity;
  String? image;
  double? subtotal;

  OrderItemModel({
    this.partId,
    this.name,
    this.price,
    required this.quantity,
    this.image,
    this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      partId: json['partId'] is String
          ? json['partId']
          : json['partId']?['_id'] ?? json['partId']?['id'],
      name: json['name'],
      price: json['price'] == null
          ? null
          : double.parse(json['price'].toString()),
      quantity: json['quantity'] ?? 0,
      image: json['image'],
      subtotal: json['subtotal'] == null
          ? null
          : double.parse(json['subtotal'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partId': partId,
      'quantity': quantity,
    };
  }
}


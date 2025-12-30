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
    final partData = json['partId'];
    String? partId;
    String? name;
    double? price;

    if (partData is String) {
      partId = partData;
    } else if (partData is Map) {
      partId = partData['_id'] ?? partData['id'];
      name = partData['name'];
      price = partData['price'] == null
          ? null
          : double.parse(partData['price'].toString());
    }

    return OrderItemModel(
      partId: partId,
      name: json['name'] ?? name,
      price: json['price'] == null
          ? price
          : double.parse(json['price'].toString()),
      quantity: json['quantity'] ?? 0,
      image: json['image'],
      subtotal: json['subtotal'] == null
          ? null
          : double.parse(json['subtotal'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'partId': partId, 'quantity': quantity};
  }
}

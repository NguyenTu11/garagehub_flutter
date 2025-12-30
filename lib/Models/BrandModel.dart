class BrandModel {
  String? id;
  String name;
  String image;

  BrandModel({this.id, required this.name, this.image = ''});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image};
  }
}

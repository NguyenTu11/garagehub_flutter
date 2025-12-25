class UserModel {
  String? userId;
  String fullName;
  DateTime? dateOfBirth;
  String? phoneNumber;
  String? address;
  String email;
  String? password;
  bool isVerified;
  List<String> roles;

  UserModel({
    this.userId,
    required this.fullName,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
    required this.email,
    this.password,
    this.isVerified = false,
    this.roles = const ['user'],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['_id'] ?? json['userId'],
      fullName: json['fullName'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : ['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
      'email': email,
      'password': password,
    };
  }
}


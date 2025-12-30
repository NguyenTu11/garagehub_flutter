class AppointmentModel {
  String? id;
  String? customerName;
  String? phone;
  String? email;
  DateTime? date;
  String? time;
  String? vehicleType;
  List<String> services;
  String? note;
  String status;
  DateTime? createdAt;
  DateTime? updatedAt;

  AppointmentModel({
    this.id,
    this.customerName,
    this.phone,
    this.email,
    this.date,
    this.time,
    this.vehicleType,
    this.services = const [],
    this.note,
    this.status = 'Chờ xác nhận',
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id'] ?? json['id'],
      customerName: json['customerName'],
      phone: json['phone'],
      email: json['email'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'],
      vehicleType: json['vehicleType'],
      services: json['services'] != null
          ? List<String>.from(json['services'])
          : [],
      note: json['note'],
      status: json['status'] ?? 'Chờ xác nhận',
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
      'customerName': customerName,
      'phone': phone,
      'email': email,
      'date': date?.toIso8601String().split('T')[0],
      'time': time,
      'vehicleType': vehicleType,
      'services': services,
      'note': note,
    };
  }
}

class TimeSlot {
  String time;
  int count;
  bool available;
  int maxSlots;

  TimeSlot({
    required this.time,
    this.count = 0,
    this.available = true,
    this.maxSlots = 3,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'],
      count: json['count'] ?? 0,
      available: json['available'] ?? true,
      maxSlots: json['maxSlots'] ?? 3,
    );
  }
}

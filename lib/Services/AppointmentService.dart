import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/AppointmentModel.dart';
import '../Utils.dart';

class AppointmentService {
  Future<Map<String, dynamic>> createAppointment(
    AppointmentModel appointment,
  ) async {
    final response = await http.post(
      Uri.parse('${Utils.baseUrl}/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(appointment.toJson()),
    );

    final data = json.decode(response.body);
    return {
      'success': response.statusCode == 201,
      'message': data['message'] ?? '',
      'data': data['data'],
    };
  }

  Future<List<TimeSlot>> getAvailableSlots(String date) async {
    final response = await http.get(
      Uri.parse('${Utils.baseUrl}/appointments/slots/available?date=$date'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List).map((e) => TimeSlot.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<List<AppointmentModel>> getAppointmentsByPhone(String phone) async {
    final response = await http.get(
      Uri.parse('${Utils.baseUrl}/appointments/phone/$phone'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => AppointmentModel.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> cancelAppointment(
    String id,
    String phone,
  ) async {
    final response = await http.post(
      Uri.parse('${Utils.baseUrl}/appointments/$id/cancel'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone}),
    );

    final data = json.decode(response.body);
    return {
      'success': data['success'] ?? (response.statusCode == 200),
      'message': data['message'] ?? '',
    };
  }
}

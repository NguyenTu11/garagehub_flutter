import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/MotoModel.dart';
import '../Repository/BaseResponse.dart';
import '../Repository/ApiResponse.dart';
import '../Utils.dart';

class MotoRepository extends BaseResponse {
  MotoRepository();

  Future<ApiResponse<MotoModel>> getAllMotos() async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.motoGetAll}'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final apiResponse = ApiResponse<MotoModel>.fromJson(
        jsonData,
        (e) => MotoModel.fromJson(e),
      );
      return apiResponse;
    }
    super.ErrorHandle(response.statusCode);
    return ApiResponse<MotoModel>(status: false, message: "", data: []);
  }

  Future<MotoModel> getMotoById(String licensePlate) async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.motoGetById}/$licensePlate'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return MotoModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to get moto');
  }

  Future<MotoModel> createMoto(MotoModel moto) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.motoCreate}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Utils.token}',
      },
      body: json.encode(moto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return MotoModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to create moto');
  }

  Future<MotoModel> updateMoto(String licensePlate, MotoModel moto) async {
    var response = await http.put(
      Uri.parse('${Utils.baseUrl}${Utils.motoUpdate}/$licensePlate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Utils.token}',
      },
      body: json.encode(moto.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return MotoModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to update moto');
  }

  Future<void> deleteMoto(String licensePlate) async {
    var response = await http.delete(
      Uri.parse('${Utils.baseUrl}${Utils.motoDelete}/$licensePlate'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      return;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to delete moto');
  }
}


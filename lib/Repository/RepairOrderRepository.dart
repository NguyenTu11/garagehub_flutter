import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/RepairOrderModel.dart';
import '../Repository/BaseResponse.dart';
import '../Repository/ApiResponse.dart';
import '../Utils.dart';

class RepairOrderRepository extends BaseResponse {
  RepairOrderRepository();

  Future<ApiResponse<RepairOrderModel>> getAllRepairOrders() async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.repairOrderGetAll}'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final apiResponse = ApiResponse<RepairOrderModel>.fromJson(
        jsonData,
        (e) => RepairOrderModel.fromJson(e),
      );
      return apiResponse;
    }
    super.ErrorHandle(response.statusCode);
    return ApiResponse<RepairOrderModel>(status: false, message: "", data: []);
  }

  Future<RepairOrderModel> getRepairOrderById(String id) async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.repairOrderGetById}/$id'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return RepairOrderModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to get repair order');
  }

  Future<RepairOrderModel> createRepairOrder(RepairOrderModel order) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.repairOrderCreate}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Utils.token}',
      },
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return RepairOrderModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to create repair order');
  }

  Future<RepairOrderModel> updateRepairOrder(
    String id,
    RepairOrderModel order,
  ) async {
    var response = await http.put(
      Uri.parse('${Utils.baseUrl}${Utils.repairOrderUpdate}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Utils.token}',
      },
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return RepairOrderModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to update repair order');
  }

  Future<void> deleteRepairOrder(String id) async {
    var response = await http.delete(
      Uri.parse('${Utils.baseUrl}${Utils.repairOrderDelete}/$id'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      return;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to delete repair order');
  }
}

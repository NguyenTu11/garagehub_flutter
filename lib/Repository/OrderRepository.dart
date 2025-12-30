import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/OrderModel.dart';
import '../Repository/BaseResponse.dart';
import '../Repository/ApiResponse.dart';
import '../Utils.dart';

class OrderRepository extends BaseResponse {
  OrderRepository();

  Future<ApiResponse<OrderModel>> getAllOrders() async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.orderGetAll}'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final apiResponse = ApiResponse<OrderModel>.fromJson(
        jsonData,
        (e) => OrderModel.fromJson(e),
      );
      return apiResponse;
    }
    super.ErrorHandle(response.statusCode);
    return ApiResponse<OrderModel>(status: false, message: "", data: []);
  }

  Future<ApiResponse<OrderModel>> getOrdersByUser() async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.orderGetByUser}/${Utils.userId}'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<OrderModel> orders = [];
      if (jsonData is List) {
        orders = jsonData.map((e) => OrderModel.fromJson(e)).toList();
      } else if (jsonData is Map && jsonData['data'] != null) {
        orders = (jsonData['data'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }

      return ApiResponse<OrderModel>(
        status: true,
        message: "Success",
        data: orders,
      );
    }
    super.ErrorHandle(response.statusCode);
    return ApiResponse<OrderModel>(status: false, message: "", data: []);
  }

  Future<OrderModel> getOrderById(String id) async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.orderGetById}/$id'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return OrderModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to get order');
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.orderCreate}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Utils.token}',
      },
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return OrderModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to create order');
  }

  Future<OrderModel> updateOrder(String id, OrderModel order) async {
    var response = await http.put(
      Uri.parse('${Utils.baseUrl}${Utils.orderUpdate}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Utils.token}',
      },
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return OrderModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to update order');
  }
}

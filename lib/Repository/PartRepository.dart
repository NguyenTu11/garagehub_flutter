import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/PartModel.dart';
import '../Repository/BaseResponse.dart';
import '../Repository/ApiResponse.dart';
import '../Utils.dart';

class PartRepository extends BaseResponse {
  PartRepository();

  Future<ApiResponse<PartModel>> getAllParts() async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.partGetAll}'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<PartModel> parts = [];
      if (jsonData is List) {
        parts = jsonData.map((e) => PartModel.fromJson(e)).toList();
      } else if (jsonData is Map && jsonData['data'] != null) {
        final data = jsonData['data'];
        if (data is List) {
          parts = data.map((e) => PartModel.fromJson(e)).toList();
        }
      }
      return ApiResponse<PartModel>(
        status: true,
        message: "Success",
        data: parts,
      );
    }
    super.ErrorHandle(response.statusCode);
    return ApiResponse<PartModel>(status: false, message: "", data: []);
  }

  Future<PartModel> getPartById(String id) async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.partGetById}/$id'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PartModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to get part');
  }

  Future<PartModel> createPart(PartModel part, String? imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Utils.baseUrl}${Utils.partCreate}'),
    );
    request.headers['Authorization'] = 'Bearer ${Utils.token}';
    request.fields['name'] = part.name;
    request.fields['quantity'] = part.quantity.toString();
    request.fields['price'] = part.price.toString();
    request.fields['buyPrice'] = part.buyPrice.toString();
    request.fields['empPrice'] = part.empPrice.toString();
    request.fields['unit'] = part.unit;
    request.fields['limitStock'] = part.limitStock.toString();
    request.fields['brandId'] = part.brandId ?? '';
    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return PartModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to create part');
  }

  Future<PartModel> updatePart(
    String id,
    PartModel part,
    String? imagePath,
  ) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${Utils.baseUrl}${Utils.partUpdate}/$id'),
    );
    request.headers['Authorization'] = 'Bearer ${Utils.token}';
    request.fields['name'] = part.name;
    request.fields['quantity'] = part.quantity.toString();
    request.fields['price'] = part.price.toString();
    request.fields['buyPrice'] = part.buyPrice.toString();
    request.fields['empPrice'] = part.empPrice.toString();
    request.fields['unit'] = part.unit;
    request.fields['limitStock'] = part.limitStock.toString();
    request.fields['brandId'] = part.brandId ?? '';
    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PartModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to update part');
  }

  Future<void> deletePart(String id) async {
    var response = await http.delete(
      Uri.parse('${Utils.baseUrl}${Utils.partDelete}/$id'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      return;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to delete part');
  }
}

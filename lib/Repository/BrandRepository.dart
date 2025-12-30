import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/BrandModel.dart';
import '../Repository/BaseResponse.dart';
import '../Repository/ApiResponse.dart';
import '../Utils.dart';

class BrandRepository extends BaseResponse {
  BrandRepository();

  Future<ApiResponse<BrandModel>> getAllBrands() async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.brandGetAll}'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<BrandModel> brands = [];
      if (jsonData is List) {
        brands = jsonData.map((e) => BrandModel.fromJson(e)).toList();
      } else if (jsonData is Map && jsonData['data'] != null) {
        final data = jsonData['data'];
        if (data is List) {
          brands = data.map((e) => BrandModel.fromJson(e)).toList();
        }
      }
      return ApiResponse<BrandModel>(
        status: true,
        message: "Success",
        data: brands,
      );
    }
    super.ErrorHandle(response.statusCode);
    return ApiResponse<BrandModel>(status: false, message: "", data: []);
  }

  Future<BrandModel> getBrandById(String id) async {
    var response = await http.get(
      Uri.parse('${Utils.baseUrl}${Utils.brandGetById}/$id'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return BrandModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to get brand');
  }

  Future<BrandModel> createBrand(BrandModel brand, String? imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Utils.baseUrl}${Utils.brandCreate}'),
    );
    request.headers['Authorization'] = 'Bearer ${Utils.token}';
    request.fields['name'] = brand.name;
    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return BrandModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to create brand');
  }

  Future<BrandModel> updateBrand(
    String id,
    BrandModel brand,
    String? imagePath,
  ) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${Utils.baseUrl}${Utils.brandUpdate}/$id'),
    );
    request.headers['Authorization'] = 'Bearer ${Utils.token}';
    request.fields['name'] = brand.name;
    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return BrandModel.fromJson(jsonData['data'] ?? jsonData);
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to update brand');
  }

  Future<void> deleteBrand(String id) async {
    var response = await http.delete(
      Uri.parse('${Utils.baseUrl}${Utils.brandDelete}/$id'),
      headers: {'Authorization': 'Bearer ${Utils.token}'},
    );

    if (response.statusCode == 200) {
      return;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Failed to delete brand');
  }
}

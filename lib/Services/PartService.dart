import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Repository/PartRepository.dart';
import '../Repository/ApiResponse.dart';
import '../Models/PartModel.dart';
import '../Models/ReviewModel.dart';
import '../Utils.dart';

class PartService {
  late PartRepository partRepository;

  PartService() {
    this.partRepository = PartRepository();
  }

  Future<ApiResponse<PartModel>> getAllParts() async {
    return await partRepository.getAllParts();
  }

  Future<PartModel> getPartById(String id) async {
    return await partRepository.getPartById(id);
  }

  Future<PartModel> createPart(PartModel part, String? imagePath) async {
    return await partRepository.createPart(part, imagePath);
  }

  Future<PartModel> updatePart(
    String id,
    PartModel part,
    String? imagePath,
  ) async {
    return await partRepository.updatePart(id, part, imagePath);
  }

  Future<void> deletePart(String id) async {
    return await partRepository.deletePart(id);
  }

  // Review methods
  Future<ReviewsResponse> getPartReviews(String partId) async {
    try {
      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/parts/$partId/reviews'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReviewsResponse.fromJson(data);
      }
      return ReviewsResponse(
        success: false,
        reviewCount: 0,
        averageRating: 0,
        reviews: [],
      );
    } catch (e) {
      return ReviewsResponse(
        success: false,
        reviewCount: 0,
        averageRating: 0,
        reviews: [],
      );
    }
  }

  Future<Map<String, dynamic>> createReview(
    String partId,
    int rating,
    String comment,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Utils.baseUrl}/parts/$partId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Utils.token}',
        },
        body: json.encode({'rating': rating, 'comment': comment}),
      );

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

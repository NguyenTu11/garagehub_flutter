class ReviewModel {
  final String? id;
  final String partId;
  final String? userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  ReviewModel({
    this.id,
    required this.partId,
    this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'],
      partId: json['partId'] ?? '',
      userId: json['userId'],
      userName: json['userName'] ?? 'Ẩn danh',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'partId': partId, 'rating': rating, 'comment': comment};
  }
}

class ReviewsResponse {
  final bool success;
  final int reviewCount;
  final double averageRating;
  final List<ReviewModel> reviews;

  ReviewsResponse({
    required this.success,
    required this.reviewCount,
    required this.averageRating,
    required this.reviews,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      success: json['success'] ?? false,
      reviewCount: json['reviewCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
                .map((e) => ReviewModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

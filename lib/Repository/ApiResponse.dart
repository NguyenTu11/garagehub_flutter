class ApiResponse<T> {
  final bool status;
  final String message;
  final List<T> data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'];
    List<T> parsedData = [];

    if (rawData is List) {
      parsedData = rawData
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      parsedData = [fromJsonT(rawData)];
    }

    return ApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: parsedData,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{status: $status, message: $message, data: $data}';
  }
}


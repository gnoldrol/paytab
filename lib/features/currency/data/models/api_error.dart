class ApiError {
  final int code;
  final String type;

  ApiError({
    required this.code,
    required this.type,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    print('Parsing API Error: $json'); // Debug print
    return ApiError(
      code: json['code'] ?? 0, // Ensure code is an int
      type: json['type'] ?? '',
    );
  }

  String get message {
    switch (code) {
      case 105:
        return 'Base Currency Access Restricted, Please Upgrade your subscription';
      default:
        return "Fixer API Error: $type";
    }
  }
} 
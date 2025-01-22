class ApiError {
  final int code;
  final String type;
  final String info;

  ApiError({
    required this.code,
    required this.type,
    required this.info,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      type: json['type'],
      info: json['info'],
    );
  }

  String get message {
    switch (code) {
      case 105:
        return 'Base Currency Access Restricted, Please Upgrade your subscription';
      default:
        return info;
    }
  }
} 
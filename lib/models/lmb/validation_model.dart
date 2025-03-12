class ValidationModel {
  final int? code;
  final String? message;

  ValidationModel({required this.code, required this.message});

  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'ValidationModel(code: $code, message: $message)';
  }
}

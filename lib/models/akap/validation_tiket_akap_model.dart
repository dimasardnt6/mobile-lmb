class ValidationTiketAkapModel {
  int? code;
  String? message;

  ValidationTiketAkapModel({this.code, this.message});

  factory ValidationTiketAkapModel.fromJson(Map<String, dynamic> json) {
    return ValidationTiketAkapModel(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'ValidationTiketAkapModel(code: $code, message: $message)';
  }
}

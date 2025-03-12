class ValidationTiketAp2Model {
  final int? code;
  final String? message;

  ValidationTiketAp2Model({required this.code, required this.message});

  factory ValidationTiketAp2Model.fromJson(Map<String, dynamic> json) {
    return ValidationTiketAp2Model(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'ValidationTiketAp2Model(code: $code, message: $message)';
  }
}

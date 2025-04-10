class PutLmbRitaseModel {
  final int code;
  final String message;

  PutLmbRitaseModel({required this.code, required this.message});

  factory PutLmbRitaseModel.fromJson(Map<String, dynamic> json) {
    return PutLmbRitaseModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'PutLmbRitaseModel(code: $code, message: $message)';
  }
}

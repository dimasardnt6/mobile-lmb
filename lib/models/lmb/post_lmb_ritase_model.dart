class PostLmbRitaseModel {
  final int code;
  final String message;

  PostLmbRitaseModel({required this.code, required this.message});

  factory PostLmbRitaseModel.fromJson(Map<String, dynamic> json) {
    return PostLmbRitaseModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'PostLmbRitaseModel(code: $code, message: $message)';
  }
}

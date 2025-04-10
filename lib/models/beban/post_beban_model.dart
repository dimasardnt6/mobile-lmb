class PostBebanModel {
  final int code;
  final String message;

  PostBebanModel({required this.code, required this.message});

  factory PostBebanModel.fromJson(Map<String, dynamic> json) {
    return PostBebanModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'PostBebanModel(code: $code, message: $message)';
  }
}

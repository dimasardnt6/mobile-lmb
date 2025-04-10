class DeleteBebanModel {
  final int code;
  final String message;

  DeleteBebanModel({required this.code, required this.message});

  factory DeleteBebanModel.fromJson(Map<String, dynamic> json) {
    return DeleteBebanModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'DeleteBebanModel(code: $code, message: $message)';
  }
}

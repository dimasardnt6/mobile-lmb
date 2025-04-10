class DeleteLmbRitaseModel {
  final int code;
  final String message;

  DeleteLmbRitaseModel({required this.code, required this.message});

  factory DeleteLmbRitaseModel.fromJson(Map<String, dynamic> json) {
    return DeleteLmbRitaseModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'DeleteLmbRitaseModel(code: $code, message: $message)';
  }
}

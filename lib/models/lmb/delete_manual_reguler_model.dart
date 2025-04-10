class DeleteManualRegulerModel {
  final int code;
  final String message;

  DeleteManualRegulerModel({required this.code, required this.message});

  factory DeleteManualRegulerModel.fromJson(Map<String, dynamic> json) {
    return DeleteManualRegulerModel(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'DeleteManualRegulerModel(code: $code, message: $message)';
  }
}

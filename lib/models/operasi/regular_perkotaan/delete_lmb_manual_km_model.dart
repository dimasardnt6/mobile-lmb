// Tipe LMB 3
class DeleteLmbManualKmModel {
  int? code;
  String? message;

  DeleteLmbManualKmModel({this.code, this.message});

  factory DeleteLmbManualKmModel.fromJson(Map<String, dynamic> json) {
    return DeleteLmbManualKmModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'DeleteLmbManualKmModel(code: $code, message: $message)';
  }
}

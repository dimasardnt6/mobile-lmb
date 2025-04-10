// Tipe LMB 2
class DeleteRegulerModel {
  int? code;
  String? message;

  DeleteRegulerModel({this.code, this.message});

  factory DeleteRegulerModel.fromJson(Map<String, dynamic> json) {
    return DeleteRegulerModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'DeleteRegulerModel(code: $code, message: $message)';
  }
}

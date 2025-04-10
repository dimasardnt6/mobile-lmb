// TIPE LMB 3
class PostRegulerModel {
  int? code;
  String? message;

  PostRegulerModel({this.code, this.message});

  factory PostRegulerModel.fromJson(Map<String, dynamic> json) {
    return PostRegulerModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'PostRegulerModel(code: $code, message: $message)';
  }
}

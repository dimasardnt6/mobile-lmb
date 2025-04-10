// TIPE LMB 3
class PostLmbManualKmModel {
  int? code;
  String? message;

  PostLmbManualKmModel({this.code, this.message});

  factory PostLmbManualKmModel.fromJson(Map<String, dynamic> json) {
    return PostLmbManualKmModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'PostLmbManualKmModel(code: $code, message: $message)';
  }
}

class PostLmbManualModel {
  int? code;
  String? message;

  PostLmbManualModel({this.code, this.message});

  factory PostLmbManualModel.fromJson(Map<String, dynamic> json) {
    return PostLmbManualModel(code: json['code'], message: json['message']);
  }
}

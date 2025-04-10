class PostManifestModel {
  int? code;
  String? message;

  PostManifestModel({this.code, this.message});

  factory PostManifestModel.fromJson(Map<String, dynamic> json) {
    return PostManifestModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'PostManifestModel(code: $code, message: $message)';
  }
}

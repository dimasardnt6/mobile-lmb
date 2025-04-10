class DeleteManifestModel {
  int? code;
  String? message;

  DeleteManifestModel({this.code, this.message});

  factory DeleteManifestModel.fromJson(Map<String, dynamic> json) {
    return DeleteManifestModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'DeleteManifestModel(code: $code, message: $message)';
  }
}

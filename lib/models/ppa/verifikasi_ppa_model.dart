class VerifikasiPpaModel {
  int? code;
  String? message;

  VerifikasiPpaModel({this.code, this.message});

  factory VerifikasiPpaModel.fromJson(Map<String, dynamic> json) {
    return VerifikasiPpaModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'VerifikasiPpaModel{code: $code, message: $message}';
  }
}

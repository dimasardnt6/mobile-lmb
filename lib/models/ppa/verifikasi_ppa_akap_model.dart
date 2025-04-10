class VerifikasiPpaAkapModel {
  int? code;
  String? message;

  VerifikasiPpaAkapModel({this.code, this.message});

  factory VerifikasiPpaAkapModel.fromJson(Map<String, dynamic> json) {
    return VerifikasiPpaAkapModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'VerifikasiPpaAkapModel{code: $code, message: $message}';
  }
}

class PutArmadaByIdModel {
  String? message;
  int? code;

  PutArmadaByIdModel({this.message, this.code});

  factory PutArmadaByIdModel.fromJson(Map<String, dynamic> json) {
    return PutArmadaByIdModel(message: json['message'], code: json['code']);
  }

  @override
  String toString() {
    return 'PutArmadaByIdModel(message: $message, code: $code)';
  }
}

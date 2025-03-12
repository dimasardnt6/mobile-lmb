class ArmadaByIdModel {
  String? message;
  int? code;

  ArmadaByIdModel({this.message, this.code});

  factory ArmadaByIdModel.fromJson(Map<String, dynamic> json) {
    return ArmadaByIdModel(message: json['message'], code: json['code']);
  }

  @override
  String toString() {
    return 'ArmadaByIdModel(message: $message, code: $code)';
  }
}

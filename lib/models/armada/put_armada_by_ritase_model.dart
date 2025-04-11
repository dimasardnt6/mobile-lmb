class PutArmadaByRitaseModel {
  String? message;
  int? code;

  PutArmadaByRitaseModel({this.message, this.code});

  factory PutArmadaByRitaseModel.fromJson(Map<String, dynamic> json) {
    return PutArmadaByRitaseModel(message: json['message'], code: json['code']);
  }

  @override
  String toString() {
    return 'PutArmadaByRitaseModel(message: $message, code: $code)';
  }
}

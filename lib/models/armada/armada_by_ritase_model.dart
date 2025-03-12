class ArmadaByRitaseModel {
  String? message;
  int? code;

  ArmadaByRitaseModel({this.message, this.code});

  factory ArmadaByRitaseModel.fromJson(Map<String, dynamic> json) {
    return ArmadaByRitaseModel(message: json['message'], code: json['code']);
  }

  @override
  String toString() {
    return 'ArmadaByRitaseModel(message: $message, code: $code)';
  }
}

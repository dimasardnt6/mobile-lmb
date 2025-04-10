class RejectTiketModel {
  int? code;
  String? message;

  RejectTiketModel({this.code, this.message});

  factory RejectTiketModel.fromJson(Map<String, dynamic> json) {
    return RejectTiketModel(code: json['code'], message: json['message']);
  }

  @override
  String toString() {
    return 'RejectTiketModel(code: $code, message: $message)';
  }
}

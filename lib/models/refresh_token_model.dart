class RefreshTokenModel {
  String? token;
  String? status;
  String? code;
  String? desc;

  RefreshTokenModel({this.token, this.status, this.code, this.desc});

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenModel(
      token: json['token'],
      status: json['status'],
      code: json['code'],
      desc: json['desc'],
    );
  }

  @override
  String toString() {
    return 'RefreshTokenModel(token: $token, status: $status, code: $code, desc: $desc)';
  }
}

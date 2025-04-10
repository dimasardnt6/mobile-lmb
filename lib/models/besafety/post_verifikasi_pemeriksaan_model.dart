class PostVerifikasiPemeriksaanModel {
  final int code;
  final String message;

  PostVerifikasiPemeriksaanModel({required this.code, required this.message});

  factory PostVerifikasiPemeriksaanModel.fromJson(Map<String, dynamic> json) {
    return PostVerifikasiPemeriksaanModel(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'PostVerifikasiPemeriksaanModel(code: $code, message: $message)';
  }
}

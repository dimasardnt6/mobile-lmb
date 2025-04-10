class PostJadwalModel {
  int? code;
  String? message;
  List<PostJadwalData>? data;

  PostJadwalModel({this.code, this.message, this.data});

  factory PostJadwalModel.fromJson(Map<String, dynamic> json) {
    return PostJadwalModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => PostJadwalData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'PostJadwalModel(code: $code, message: $message, data: $data)';
  }
}

class PostJadwalData {
  String? bis;
  String? tanggal;
  String? jam1;
  String? jenis;
  String? kd_trayek;

  PostJadwalData({
    this.bis,
    this.tanggal,
    this.jam1,
    this.jenis,
    this.kd_trayek,
  });

  factory PostJadwalData.fromJson(Map<String, dynamic> json) {
    return PostJadwalData(
      bis: json['bis'],
      tanggal: json['tanggal'],
      jam1: json['jam1'],
      jenis: json['jenis'],
      kd_trayek: json['kd_trayek'],
    );
  }

  @override
  String toString() {
    return 'PostJadwalData(bis: $bis, tanggal: $tanggal, jam1: $jam1, jenis: $jenis, kd_trayek: $kd_trayek)';
  }
}

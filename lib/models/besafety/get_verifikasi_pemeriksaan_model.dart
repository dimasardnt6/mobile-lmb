class GetVerifikasiPemeriksaanModel {
  int? code;
  String? message;
  GetVerifikasiPemeriksaanData? data;

  GetVerifikasiPemeriksaanModel({this.code, this.message, this.data});

  factory GetVerifikasiPemeriksaanModel.fromJson(Map<String, dynamic> json) {
    return GetVerifikasiPemeriksaanModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? GetVerifikasiPemeriksaanData.fromJson(json['data'])
              : null,
    );
  }

  @override
  String toString() {
    return 'GetVerifikasiPemeriksaanModel{code: $code, message: $message, data: $data}';
  }
}

class GetVerifikasiPemeriksaanData {
  String? id_user;
  String? nm_user;
  String? tanggal;
  String? keterangan;

  GetVerifikasiPemeriksaanData({
    this.id_user,
    this.nm_user,
    this.tanggal,
    this.keterangan,
  });

  factory GetVerifikasiPemeriksaanData.fromJson(Map<String, dynamic> json) {
    return GetVerifikasiPemeriksaanData(
      id_user: json['id_user'],
      nm_user: json['nm_user'],
      tanggal: json['tanggal'],
      keterangan: json['keterangan'],
    );
  }

  @override
  String toString() {
    return 'GetVerifikasiPemeriksaanData{id_user: $id_user, nm_user: $nm_user, tanggal: $tanggal, keterangan: $keterangan}';
  }
}

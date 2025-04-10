class CekTiketModel {
  int? code;
  String? message;
  CekTiketData? data;

  CekTiketModel({required this.code, required this.message, this.data});

  factory CekTiketModel.fromJson(Map<String, dynamic> json) {
    return CekTiketModel(
      code: json['code'] ?? 0,
      message: json['message'] ?? "",
      data: json['data'] != null ? CekTiketData.fromJson(json['data']) : null,
    );
  }

  @override
  String toString() {
    return 'CekTiketModel('
        'code: $code, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

class CekTiketData {
  final String? id_lmb;
  final String? asal;
  final String? tujuan;
  final String? kd_tiket;
  final String? tgl_tiket;
  final String? harga;
  final String? kd_armada;
  final String? nm_user;
  final String? cdate;

  CekTiketData({
    required this.id_lmb,
    required this.asal,
    required this.tujuan,
    required this.kd_tiket,
    required this.tgl_tiket,
    required this.harga,
    required this.kd_armada,
    required this.nm_user,
    required this.cdate,
  });

  factory CekTiketData.fromJson(Map<String, dynamic> json) {
    return CekTiketData(
      id_lmb: json['id_lmb'],
      asal: json['asal'],
      tujuan: json['tujuan'],
      kd_tiket: json['kd_tiket'],
      tgl_tiket: json['tgl_tiket'],
      harga: json['harga'],
      kd_armada: json['kd_armada'],
      nm_user: json['nm_user'],
      cdate: json['cdate'],
    );
  }
}

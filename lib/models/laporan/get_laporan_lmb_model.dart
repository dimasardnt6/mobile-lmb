class GetLaporanLmbModel {
  int? code;
  String? message;
  final List<GetLaporanLmbData>? data;

  GetLaporanLmbModel({this.code, this.message, this.data});

  factory GetLaporanLmbModel.fromJson(Map<String, dynamic> json) {
    return GetLaporanLmbModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetLaporanLmbData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLaporanLmbModel('
        'code: $code, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

class GetLaporanLmbData {
  String? id_lmb;
  String? nm_driver1;
  String? nm_driver2;
  String? tgl_awal;
  String? kd_armada;
  String? plat_armada;
  String? kd_trayek;
  String? nm_trayek;
  String? kd_trayek_detail;
  String? nm_trayek_detail;
  String? kd_trayek_tiket;
  String? nm_segment_transaksi;
  String? nm_segment_sub;
  String? nm_layanan;
  String? active;

  GetLaporanLmbData({
    this.id_lmb,
    this.nm_driver1,
    this.nm_driver2,
    this.tgl_awal,
    this.kd_armada,
    this.plat_armada,
    this.kd_trayek,
    this.nm_trayek,
    this.kd_trayek_detail,
    this.nm_trayek_detail,
    this.kd_trayek_tiket,
    this.nm_segment_transaksi,
    this.nm_segment_sub,
    this.nm_layanan,
    this.active,
  });

  factory GetLaporanLmbData.fromJson(Map<String, dynamic> json) {
    return GetLaporanLmbData(
      id_lmb: json['id_lmb'],
      nm_driver1: json['nm_driver1'],
      nm_driver2: json['nm_driver2'],
      tgl_awal: json['tgl_awal'],
      kd_armada: json['kd_armada'],
      plat_armada: json['plat_armada'],
      kd_trayek: json['kd_trayek'],
      nm_trayek: json['nm_trayek'],
      kd_trayek_detail: json['kd_trayek_detail'],
      nm_trayek_detail: json['nm_trayek_detail'],
      kd_trayek_tiket: json['kd_trayek_tiket'],
      nm_segment_transaksi: json['nm_segment_transaksi'],
      nm_segment_sub: json['nm_segment_sub'],
      nm_layanan: json['nm_layanan'],
      active: json['active'],
    );
  }

  @override
  String toString() {
    return 'GetLaporanLmbData('
        'id_lmb: $id_lmb, '
        'nm_driver1: $nm_driver1, '
        'nm_driver2: $nm_driver2, '
        'tgl_awal: $tgl_awal, '
        'kd_armada: $kd_armada, '
        'plat_armada: $plat_armada, '
        'kd_trayek: $kd_trayek, '
        'nm_trayek: $nm_trayek, '
        'kd_trayek_detail: $kd_trayek_detail, '
        'nm_trayek_detail: $nm_trayek_detail, '
        'kd_trayek_tiket: $kd_trayek_tiket, '
        'nm_segment_transaksi: $nm_segment_transaksi, '
        'nm_segment_sub: $nm_segment_sub, '
        'nm_layanan: $nm_layanan, '
        'active: $active'
        ')';
  }
}

class GetLmbAdminModel {
  int? code;
  String? message;
  final List<GetLmbAdminData>? data;

  GetLmbAdminModel({this.code, this.message, this.data});

  factory GetLmbAdminModel.fromJson(Map<String, dynamic> json) {
    return GetLmbAdminModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetLmbAdminData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLmbAdminModel('
        'code: $code, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

class GetLmbAdminData {
  String? id_bu;
  String? id_lmb;
  String? nm_driver1;
  String? nm_driver2;
  String? tgl_awal;
  String? kd_armada;
  String? plat_armada;
  String? id_trayek;
  String? id_trayek_detail;
  String? kd_trayek;
  String? nm_trayek;
  String? kd_trayek_detail;
  String? nm_trayek_detail;
  String? kd_trayek_tiket;
  String? id_segment_transaksi;
  String? nm_segment_transaksi;
  String? nm_segment_sub;
  String? kode_layanan;
  String? nm_layanan;
  String? tipe_lmb_online;
  String? approval_lmb_online;
  String? bis;

  GetLmbAdminData({
    this.id_bu,
    this.id_lmb,
    this.nm_driver1,
    this.nm_driver2,
    this.tgl_awal,
    this.kd_armada,
    this.plat_armada,
    this.id_trayek,
    this.id_trayek_detail,
    this.kd_trayek,
    this.nm_trayek,
    this.kd_trayek_detail,
    this.nm_trayek_detail,
    this.kd_trayek_tiket,
    this.id_segment_transaksi,
    this.nm_segment_transaksi,
    this.nm_segment_sub,
    this.kode_layanan,
    this.nm_layanan,
    this.tipe_lmb_online,
    this.approval_lmb_online,
    this.bis,
  });

  factory GetLmbAdminData.fromJson(Map<String, dynamic> json) {
    return GetLmbAdminData(
      id_bu: json['id_bu'],
      id_lmb: json['id_lmb'],
      nm_driver1: json['nm_driver1'],
      nm_driver2: json['nm_driver2'],
      tgl_awal: json['tgl_awal'],
      kd_armada: json['kd_armada'],
      plat_armada: json['plat_armada'],
      id_trayek: json['id_trayek'],
      id_trayek_detail: json['id_trayek_detail'],
      kd_trayek: json['kd_trayek'],
      nm_trayek: json['nm_trayek'],
      kd_trayek_detail: json['kd_trayek_detail'],
      nm_trayek_detail: json['nm_trayek_detail'],
      kd_trayek_tiket: json['kd_trayek_tiket'],
      id_segment_transaksi: json['id_segment_transaksi'],
      nm_segment_transaksi: json['nm_segment_transaksi'],
      nm_segment_sub: json['nm_segment_sub'],
      kode_layanan: json['kode_layanan'],
      nm_layanan: json['nm_layanan'],
      tipe_lmb_online: json['tipe_lmb_online'],
      approval_lmb_online: json['approval_lmb_online'],
      bis: json['bis'],
    );
  }

  @override
  String toString() {
    return 'GetLmbAdminData('
        'id_bu: $id_bu, '
        'id_lmb: $id_lmb, '
        'nm_driver1: $nm_driver1, '
        'nm_driver2: $nm_driver2, '
        'tgl_awal: $tgl_awal, '
        'kd_armada: $kd_armada, '
        'plat_armada: $plat_armada, '
        'id_trayek: $id_trayek, '
        'id_trayek_detail: $id_trayek_detail, '
        'kd_trayek: $kd_trayek, '
        'nm_trayek: $nm_trayek, '
        'kd_trayek_detail: $kd_trayek_detail, '
        'nm_trayek_detail: $nm_trayek_detail, '
        'kd_trayek_tiket: $kd_trayek_tiket, '
        'id_segment_transaksi: $id_segment_transaksi, '
        'nm_segment_transaksi: $nm_segment_transaksi, '
        'nm_segment_sub: $nm_segment_sub, '
        'kode_layanan: $kode_layanan, '
        'nm_layanan: $nm_layanan, '
        'tipe_lmb_online: $tipe_lmb_online, '
        'approval_lmb_online: $approval_lmb_online, '
        'bis: $bis'
        ')';
  }
}

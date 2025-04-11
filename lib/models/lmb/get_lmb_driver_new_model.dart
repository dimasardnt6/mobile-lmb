class GetLmbDriverNewModel {
  final int? code;
  final String? message;
  final List<LmbDriverNewData>? data;

  GetLmbDriverNewModel({required this.code, required this.message, this.data});

  factory GetLmbDriverNewModel.fromJson(Map<String, dynamic> json) {
    return GetLmbDriverNewModel(
      code: json['code'] ?? 0,
      message: json['message'] ?? "",
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => LmbDriverNewData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLmbDriverNewModel('
        'code: $code, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

class LmbDriverNewData {
  final String? id_bu;
  final String? id_lmb;
  final String? nm_driver1;
  final String? nm_driver2;
  final String? tgl_awal;
  final String? kd_armada;
  final String? plat_armada;
  final String? id_trayek;
  final String? id_trayek_detail;
  final String? kd_trayek;
  final String? nm_trayek;
  final String? kd_trayek_detail;
  final String? nm_trayek_detail;
  final String? kd_trayek_tiket;
  final String? id_segment_transaksi;
  final String? nm_segment_transaksi;
  final String? nm_segment_sub;
  final String? kode_layanan;
  final String? nm_layanan;
  final String? tipe_lmb_online;
  final String? approval_lmb_online;
  final String? bis;
  final String? status_ritase;

  LmbDriverNewData({
    required this.id_bu,
    required this.id_lmb,
    required this.nm_driver1,
    required this.nm_driver2,
    required this.tgl_awal,
    required this.kd_armada,
    required this.plat_armada,
    required this.id_trayek,
    required this.id_trayek_detail,
    required this.kd_trayek,
    required this.nm_trayek,
    required this.kd_trayek_detail,
    required this.nm_trayek_detail,
    required this.kd_trayek_tiket,
    required this.id_segment_transaksi,
    required this.nm_segment_transaksi,
    required this.nm_segment_sub,
    required this.kode_layanan,
    required this.nm_layanan,
    required this.tipe_lmb_online,
    required this.approval_lmb_online,
    required this.bis,
    required this.status_ritase,
  });

  factory LmbDriverNewData.fromJson(Map<String, dynamic> json) {
    return LmbDriverNewData(
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
      status_ritase: json['status_ritase'],
    );
  }

  @override
  String toString() {
    return 'LmbDriverNewData(id_bu: $id_bu, id_lmb: $id_lmb, nm_driver1: $nm_driver1, nm_driver2: $nm_driver2, tgl_awal: $tgl_awal, kd_armada: $kd_armada, plat_armada: $plat_armada, id_trayek: $id_trayek, id_trayek_detail: $id_trayek_detail, kd_trayek: $kd_trayek, nm_trayek: $nm_trayek, kd_trayek_detail: $kd_trayek_detail, nm_trayek_detail: $nm_trayek_detail, kd_trayek_tiket: $kd_trayek_tiket, id_segment_transaksi: $id_segment_transaksi, nm_segment_transaksi: $nm_segment_transaksi, nm_segment_sub: $nm_segment_sub, kode_layanan: $kode_layanan, nm_layanan: $nm_layanan, tipe_lmb_online: $tipe_lmb_online, approval_lmb_online: $approval_lmb_online, bis: $bis, status_ritase: $status_ritase)';
  }
}

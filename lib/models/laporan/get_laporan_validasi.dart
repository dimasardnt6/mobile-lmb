class GetLaporanValidasiModel {
  int? code;
  String? message;
  final List<GetLaporanValidasiData>? data;

  GetLaporanValidasiModel({this.code, this.message, this.data});

  factory GetLaporanValidasiModel.fromJson(Map<String, dynamic> json) {
    return GetLaporanValidasiModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetLaporanValidasiData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLaporanValidasiModel('
        'code: $code, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

class GetLaporanValidasiData {
  String? id_lmb;
  String? kd_armada;
  String? kd_trayek;
  String? ritase;
  String? jml_pnp;

  GetLaporanValidasiData({
    this.id_lmb,
    this.kd_armada,
    this.kd_trayek,
    this.ritase,
    this.jml_pnp,
  });

  factory GetLaporanValidasiData.fromJson(Map<String, dynamic> json) {
    return GetLaporanValidasiData(
      id_lmb: json['id_lmb'],
      kd_armada: json['kd_armada'],
      kd_trayek: json['kd_trayek'],
      ritase: json['ritase'],
      jml_pnp: json['jml_pnp'],
    );
  }

  @override
  String toString() {
    return 'GetLaporanValidasiData('
        'id_lmb: $id_lmb, '
        'kd_armada: $kd_armada, '
        'kd_trayek: $kd_trayek, '
        'ritase: $ritase, '
        'jml_pnp: $jml_pnp'
        ')';
  }
}

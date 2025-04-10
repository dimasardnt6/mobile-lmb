class GetAktifitasDriverModel {
  int? code;
  String? message;
  List<GetAktifitasDriverData>? data;

  GetAktifitasDriverModel({this.code, this.message, this.data});

  factory GetAktifitasDriverModel.fromJson(Map<String, dynamic> json) {
    return GetAktifitasDriverModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetAktifitasDriverData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetAktifitasDriverModel{code: $code, message: $message, data: $data}';
  }
}

class GetAktifitasDriverData {
  String? id_lmb;
  String? tgl_awal;
  String? ritase;
  String? km;
  String? status_ritase;
  String? tot_pnp;

  GetAktifitasDriverData({
    this.id_lmb,
    this.tgl_awal,
    this.ritase,
    this.km,
    this.status_ritase,
    this.tot_pnp,
  });

  factory GetAktifitasDriverData.fromJson(Map<String, dynamic> json) {
    return GetAktifitasDriverData(
      id_lmb: json['id_lmb'],
      tgl_awal: json['tgl_awal'],
      ritase: json['ritase'],
      km: json['km'],
      status_ritase: json['status_ritase'],
      tot_pnp: json['tot_pnp'],
    );
  }

  @override
  String toString() {
    return 'GetAktifitasDriverData{id_lmb: $id_lmb, tgl_awal: $tgl_awal, ritase: $ritase, km: $km, status_ritase: $status_ritase,tot_pnp: $tot_pnp}';
  }
}

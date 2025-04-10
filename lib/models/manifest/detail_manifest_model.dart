class DetailManifestModel {
  int? code;
  String? message;
  List<DetailManifestData>? data;

  DetailManifestModel({this.code, this.message, this.data});

  factory DetailManifestModel.fromJson(Map<String, dynamic> json) {
    return DetailManifestModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => DetailManifestData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'DetailManifestModel(code: $code, message: $message, data: $data)';
  }
}

class DetailManifestData {
  String? kd_tiket;
  String? id_lmb_reguler_apps;
  String? nm_asal;
  String? nm_tujuan;
  String? penumpang_nama;
  String? harga;
  String? kursi;
  String? no_hp;
  String? nm_user;
  String? active;

  DetailManifestData({
    this.kd_tiket,
    this.id_lmb_reguler_apps,
    this.nm_asal,
    this.nm_tujuan,
    this.penumpang_nama,
    this.harga,
    this.kursi,
    this.no_hp,
    this.nm_user,
    this.active,
  });

  factory DetailManifestData.fromJson(Map<String, dynamic> json) {
    return DetailManifestData(
      kd_tiket: json['kd_tiket'],
      id_lmb_reguler_apps: json['id_lmb_reguler_apps'],
      nm_asal: json['nm_asal'],
      nm_tujuan: json['nm_tujuan'],
      penumpang_nama: json['penumpang_nama'],
      harga: json['harga'],
      kursi: json['kursi'],
      no_hp: json['no_hp'],
      nm_user: json['nm_user'],
      active: json['active'],
    );
  }

  @override
  String toString() {
    return 'DetailManifestData(kd_tiket: $kd_tiket, id_lmb_reguler_apps: $id_lmb_reguler_apps, nm_asal: $nm_asal, nm_tujuan: $nm_tujuan, penumpang_nama: $penumpang_nama, harga: $harga, kursi: $kursi, no_hp: $no_hp, nm_user: $nm_user, active: $active)';
  }
}

class DetailRitaseModel {
  int? code;
  String? message;
  List<DetailRitaseData>? data;

  DetailRitaseModel({this.code, this.message, this.data});

  factory DetailRitaseModel.fromJson(Map<String, dynamic> json) {
    return DetailRitaseModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => DetailRitaseData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'DetailRitaseModel(code: $code, message: $message, data: $data)';
  }
}

class DetailRitaseData {
  String? kd_tiket;
  String? id_lmb_reguler_apps;
  String? nm_asal;
  String? nm_tujuan;
  String? harga;
  String? channel;
  String? nm_user;
  String? active;

  DetailRitaseData({
    this.kd_tiket,
    this.id_lmb_reguler_apps,
    this.nm_asal,
    this.nm_tujuan,
    this.harga,
    this.channel,
    this.nm_user,
    this.active,
  });

  factory DetailRitaseData.fromJson(Map<String, dynamic> json) {
    return DetailRitaseData(
      kd_tiket: json['kd_tiket'],
      id_lmb_reguler_apps: json['id_lmb_reguler_apps'],
      nm_asal: json['nm_asal'],
      nm_tujuan: json['nm_tujuan'],
      harga: json['harga'],
      channel: json['channel'],
      nm_user: json['nm_user'],
      active: json['active'],
    );
  }

  @override
  String toString() {
    return 'DetailRitaseData(kd_tiket: $kd_tiket, id_lmb_reguler_apps: $id_lmb_reguler_apps, nm_asal: $nm_asal, nm_tujuan: $nm_tujuan, harga: $harga, channel: $channel, nm_user: $nm_user, active: $active)';
  }
}

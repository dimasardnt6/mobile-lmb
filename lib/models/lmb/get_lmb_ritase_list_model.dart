class GetLmbRitaseListModel {
  int? code;
  String? message;
  List<LmbRitaseListData>? data;

  GetLmbRitaseListModel({this.code, this.message, this.data});

  factory GetLmbRitaseListModel.fromJson(Map<String, dynamic> json) {
    return GetLmbRitaseListModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => LmbRitaseListData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLmbRitaseListModel(code: $code, message: $message, data: $data)';
  }
}

class LmbRitaseListData {
  String? id_lmb_ritase;
  String? id_lmb;
  String? ritase;
  String? level;
  String? status;
  String? waktu_awal;
  String? waktu_akhir;
  String? km_awal;
  String? km_akhir;

  LmbRitaseListData({
    this.id_lmb_ritase,
    this.id_lmb,
    this.ritase,
    this.level,
    this.status,
    this.waktu_awal,
    this.waktu_akhir,
    this.km_awal,
    this.km_akhir,
  });

  factory LmbRitaseListData.fromJson(Map<String, dynamic> json) {
    return LmbRitaseListData(
      id_lmb_ritase: json['id_lmb_ritase'],
      id_lmb: json['id_lmb'],
      ritase: json['ritase'],
      level: json['level'],
      status: json['status'],
      waktu_awal: json['waktu_awal'],
      waktu_akhir: json['waktu_akhir'],
      km_awal: json['km_awal'],
      km_akhir: json['km_akhir'],
    );
  }

  @override
  String toString() {
    return 'LmbRitaseListData(id_lmb_ritase: $id_lmb_ritase, id_lmb: $id_lmb, ritase: $ritase, level: $level, status: $status, waktu_awal: $waktu_awal, waktu_akhir: $waktu_akhir, km_awal: $km_awal, km_akhir: $km_akhir)';
  }
}

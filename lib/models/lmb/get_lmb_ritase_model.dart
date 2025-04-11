class GetLmbRitaseModel {
  int code;
  String message;
  LmbRitaseData? data;

  GetLmbRitaseModel({required this.code, required this.message, this.data});

  factory GetLmbRitaseModel.fromJson(Map<String, dynamic> json) {
    return GetLmbRitaseModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? LmbRitaseData.fromJson(json['data']) : null,
    );
  }

  @override
  String toString() {
    return 'GetLmbRitaseModel(code: $code, message: $message, data: ${data?.toString() ?? "null"})';
  }
}

class LmbRitaseData {
  String id_lmb;
  String ritase;
  String level;
  String status;
  String waktu_awal;
  String waktu_akhir;
  String km_awal;
  String km_akhir;

  LmbRitaseData({
    required this.id_lmb,
    required this.ritase,
    required this.level,
    required this.status,
    required this.waktu_awal,
    required this.waktu_akhir,
    required this.km_awal,
    required this.km_akhir,
  });

  factory LmbRitaseData.fromJson(Map<String, dynamic> json) {
    return LmbRitaseData(
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
    return 'LmbRitaseData(id_lmb: $id_lmb, ritase: $ritase, level: $level, status: $status, waktu_awal: $waktu_awal, waktu_akhir: $waktu_akhir, km_awal: $km_awal, km_akhir: $km_akhir)';
  }
}

class GetLaporanLmbRitaseModel {
  int? code;
  String? message;
  final List<GetLaporanLmbRitaseData>? data;

  GetLaporanLmbRitaseModel({this.code, this.message, this.data});

  factory GetLaporanLmbRitaseModel.fromJson(Map<String, dynamic> json) {
    return GetLaporanLmbRitaseModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetLaporanLmbRitaseData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLaporanLmbRitaseModel('
        'code: $code, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

class GetLaporanLmbRitaseData {
  String? ritase;
  String? waktu_awal;
  String? km_awal;
  String? waktu_akhir;
  String? km_akhir;
  String? status;

  GetLaporanLmbRitaseData({
    this.ritase,
    this.waktu_awal,
    this.km_awal,
    this.waktu_akhir,
    this.km_akhir,
    this.status,
  });

  factory GetLaporanLmbRitaseData.fromJson(Map<String, dynamic> json) {
    return GetLaporanLmbRitaseData(
      ritase: json['ritase'],
      waktu_awal: json['waktu_awal'],
      km_awal: json['km_awal'],
      waktu_akhir: json['waktu_akhir'],
      km_akhir: json['km_akhir'],
      status: json['status'],
    );
  }

  @override
  String toString() {
    return 'GetLaporanLmbRitaseData('
        'ritase: $ritase, '
        'waktu_awal: $waktu_awal, '
        'km_awal: $km_awal, '
        'waktu_akhir: $waktu_akhir, '
        'km_akhir: $km_akhir, '
        'status: $status, '
        ')';
  }
}

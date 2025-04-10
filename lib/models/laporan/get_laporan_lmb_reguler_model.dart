class GetLaporanLmbRegulerModel {
  int? code;
  String? message;
  final List<GetLaporanLmbRegulerData>? data;

  GetLaporanLmbRegulerModel({this.code, this.message, this.data});

  factory GetLaporanLmbRegulerModel.fromJson(Map<String, dynamic> json) {
    return GetLaporanLmbRegulerModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetLaporanLmbRegulerData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLaporanLmbRegulerModel('
        'code: $code, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

class GetLaporanLmbRegulerData {
  String? ritase;
  String? nm_trayek_detail;
  String? jml_pnp;

  GetLaporanLmbRegulerData({this.ritase, this.nm_trayek_detail, this.jml_pnp});

  factory GetLaporanLmbRegulerData.fromJson(Map<String, dynamic> json) {
    return GetLaporanLmbRegulerData(
      ritase: json['ritase'],
      nm_trayek_detail: json['nm_trayek_detail'],
      jml_pnp: json['jml_pnp'],
    );
  }

  @override
  String toString() {
    return 'GetLaporanLmbRegulerData('
        'ritase: $ritase, '
        'nm_trayek_detail: $nm_trayek_detail, '
        'jml_pnp: $jml_pnp, '
        ')';
  }
}

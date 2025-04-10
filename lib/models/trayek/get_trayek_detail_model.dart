class GetTrayekDetailModel {
  int? code;
  String? message;
  List<GetTrayekDetailData>? data;

  GetTrayekDetailModel({this.code, this.message, this.data});

  factory GetTrayekDetailModel.fromJson(Map<String, dynamic> json) {
    return GetTrayekDetailModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetTrayekDetailData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetTrayekDetailModel{code: $code, message: $message, data: $data}';
  }
}

class GetTrayekDetailData {
  String? id_trayek_detail;
  String? kd_trayek_detail;
  String? nm_trayek_detail;
  String? km;

  GetTrayekDetailData({
    this.id_trayek_detail,
    this.kd_trayek_detail,
    this.nm_trayek_detail,
    this.km,
  });

  factory GetTrayekDetailData.fromJson(Map<String, dynamic> json) {
    return GetTrayekDetailData(
      id_trayek_detail: json['id_trayek_detail'],
      kd_trayek_detail: json['kd_trayek_detail'],
      nm_trayek_detail: json['nm_trayek_detail'],
      km: json['km'],
    );
  }

  @override
  String toString() {
    return 'GetTrayekDetailData{id_trayek_detail: $id_trayek_detail, kd_trayek_detail: $kd_trayek_detail, nm_trayek_detail: $nm_trayek_detail, km: $km}';
  }
}

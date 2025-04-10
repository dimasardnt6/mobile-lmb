class GetTrayekBkoModel {
  int? code;
  String? message;
  List<GetTrayekBkoData>? data;

  GetTrayekBkoModel({this.code, this.message, this.data});

  factory GetTrayekBkoModel.fromJson(Map<String, dynamic> json) {
    return GetTrayekBkoModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetTrayekBkoData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetTrayekBkoModel{code: $code, message: $message, data: $data}';
  }
}

class GetTrayekBkoData {
  String? id_trayek;
  String? id_trayek_detail;
  String? kd_trayek_detail;
  String? nm_trayek_detail;
  String? km;

  GetTrayekBkoData({
    this.id_trayek,
    this.id_trayek_detail,
    this.kd_trayek_detail,
    this.nm_trayek_detail,
    this.km,
  });

  factory GetTrayekBkoData.fromJson(Map<String, dynamic> json) {
    return GetTrayekBkoData(
      id_trayek: json['id_trayek'],
      id_trayek_detail: json['id_trayek_detail'],
      kd_trayek_detail: json['kd_trayek_detail'],
      nm_trayek_detail: json['nm_trayek_detail'],
      km: json['km'],
    );
  }

  @override
  String toString() {
    return 'GetTrayekBkoData{id_trayek: $id_trayek,id_trayek_detail: $id_trayek_detail, kd_trayek_detail: $kd_trayek_detail, nm_trayek_detail: $nm_trayek_detail, km: $km}';
  }
}

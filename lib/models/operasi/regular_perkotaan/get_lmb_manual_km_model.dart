// TIPE LMB 3
class GetLmbManualKmModel {
  int? code;
  String? message;
  final List<GetLmbManualKmData>? data;

  GetLmbManualKmModel({required this.code, required this.message, this.data});

  factory GetLmbManualKmModel.fromJson(Map<String, dynamic> json) {
    return GetLmbManualKmModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetLmbManualKmData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetLmbManualKmModel(code: $code, message: $message, data: $data)';
  }
}

class GetLmbManualKmData {
  String id_lmb_reguler;
  String ritase;
  String nm_trayek_detail;
  String km_ritase;
  String nm_user;
  String cdate;

  GetLmbManualKmData({
    required this.id_lmb_reguler,

    required this.ritase,
    required this.nm_trayek_detail,
    required this.km_ritase,
    required this.nm_user,
    required this.cdate,
  });

  factory GetLmbManualKmData.fromJson(Map<String, dynamic> json) {
    return GetLmbManualKmData(
      id_lmb_reguler: json['id_lmb_reguler'],
      ritase: json['ritase'],
      nm_trayek_detail: json['nm_trayek_detail'],
      km_ritase: json['km_ritase'],
      nm_user: json['nm_user'],
      cdate: json['cdate'],
    );
  }

  @override
  String toString() {
    return 'GetLmbManualKmData(id_lmb_reguler: $id_lmb_reguler, ritase: $ritase,nm_trayek_detail: $nm_trayek_detail,km_ritase: $km_ritase,nm_user: $nm_user,cdate: $cdate)';
  }
}

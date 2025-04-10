// Tipe LMB 2
class GetRegulerModel {
  int? code;
  String? message;
  final List<GetRegulerData>? data;

  GetRegulerModel({required this.code, required this.message, this.data});

  factory GetRegulerModel.fromJson(Map<String, dynamic> json) {
    return GetRegulerModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetRegulerData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetRegulerModel(code: $code, message: $message, data: $data)';
  }
}

class GetRegulerData {
  String id_lmb_reguler;
  String id_lmb;
  String id_trayek_detail;
  String kd_trayek_detail;
  String nm_trayek_detail;
  String km_operasi;
  String km_ritase;
  String waktu;
  String ritase;
  String cuser;
  String nm_user;

  GetRegulerData({
    required this.id_lmb_reguler,
    required this.id_lmb,
    required this.id_trayek_detail,
    required this.kd_trayek_detail,
    required this.nm_trayek_detail,
    required this.km_operasi,
    required this.km_ritase,
    required this.waktu,
    required this.ritase,
    required this.cuser,
    required this.nm_user,
  });

  factory GetRegulerData.fromJson(Map<String, dynamic> json) {
    return GetRegulerData(
      id_lmb_reguler: json['id_lmb_reguler'],
      id_lmb: json['id_lmb'],
      id_trayek_detail: json['id_trayek_detail'],
      kd_trayek_detail: json['kd_trayek_detail'],
      nm_trayek_detail: json['nm_trayek_detail'],
      km_operasi: json['km_operasi'],
      km_ritase: json['km_ritase'],
      waktu: json['waktu'],
      ritase: json['ritase'],
      cuser: json['cuser'],
      nm_user: json['nm_user'],
    );
  }

  @override
  String toString() {
    return 'GetRegulerData(id_lmb_reguler: $id_lmb_reguler,id_lmb: $id_lmb,id_trayek_detail: $id_trayek_detail,kd_trayek_detail: $kd_trayek_detail,nm_trayek_detail: $nm_trayek_detail,km_operasi: $km_operasi,km_ritase: $km_ritase,waktu: $waktu,ritase: $ritase,cuser: $cuser,nm_user: $nm_user)';
  }
}

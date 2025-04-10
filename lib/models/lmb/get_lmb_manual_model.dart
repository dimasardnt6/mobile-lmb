class GetLmbManualModel {
  int? code;
  String? message;
  List<GetLmbManualData>? data;

  GetLmbManualModel({this.code, this.message, this.data});

  factory GetLmbManualModel.fromJson(Map<String, dynamic> json) {
    return GetLmbManualModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetLmbManualData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetLmbManualModel{code: $code, message: $message, data: $data}';
  }
}

class GetLmbManualData {
  String? id_lmb_reguler_apps;
  String? id_lmb;
  String? id_trayek_detail;
  String? nm_trayek_detail;
  String? jml_penumpang;
  String? ritase;
  String? cuser;
  String? nm_user;
  String? active;
  String? cdate;

  GetLmbManualData({
    this.id_lmb_reguler_apps,
    this.id_lmb,
    this.id_trayek_detail,
    this.nm_trayek_detail,
    this.jml_penumpang,
    this.ritase,
    this.cuser,
    this.nm_user,
    this.active,
    this.cdate,
  });

  factory GetLmbManualData.fromJson(Map<String, dynamic> json) {
    return GetLmbManualData(
      id_lmb_reguler_apps: json['id_lmb_reguler_apps'],
      id_lmb: json['id_lmb'],
      id_trayek_detail: json['id_trayek_detail'],
      nm_trayek_detail: json['nm_trayek_detail'],
      jml_penumpang: json['jml_penumpang'],
      ritase: json['ritase'],
      cuser: json['cuser'],
      nm_user: json['nm_user'],
      active: json['active'],
      cdate: json['cdate'],
    );
  }

  @override
  String toString() {
    return 'GetLmbManualData{id_lmb_reguler_apps: $id_lmb_reguler_apps, id_lmb: $id_lmb, id_trayek_detail: $id_trayek_detail, nm_trayek_detail: $nm_trayek_detail, jml_penumpang: $jml_penumpang, ritase: $ritase, cuser: $cuser, nm_user: $nm_user, active: $active, cdate: $cdate}';
  }
}

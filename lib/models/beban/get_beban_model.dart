class GetBebanModel {
  int? code;
  String? message;
  List<GetBebanData>? data;

  GetBebanModel({this.code, this.message, this.data});

  factory GetBebanModel.fromJson(Map<String, dynamic> json) {
    return GetBebanModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetBebanData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetBebanModel{code: $code, message: $message, data: $data}';
  }
}

class GetBebanData {
  String? id_lmb;
  String? id_lmb_beban;
  String? nm_komponen;
  String? jumlah_beban;
  String? nominal_beban;
  String? nm_item;

  GetBebanData({
    this.id_lmb,
    this.id_lmb_beban,
    this.nm_komponen,
    this.jumlah_beban,
    this.nominal_beban,
    this.nm_item,
  });

  factory GetBebanData.fromJson(Map<String, dynamic> json) {
    return GetBebanData(
      id_lmb: json['id_lmb'],
      id_lmb_beban: json['id_lmb_beban'],
      nm_komponen: json['nm_komponen'],
      jumlah_beban: json['jumlah_beban'],
      nominal_beban: json['nominal_beban'],
      nm_item: json['nm_item'],
    );
  }

  @override
  String toString() {
    return 'GetBebanData{id_lmb: $id_lmb, id_lmb_beban: $id_lmb_beban, nm_komponen: $nm_komponen, jumlah_beban: $jumlah_beban, nominal_beban: $nominal_beban,nm_item: $nm_item}';
  }
}

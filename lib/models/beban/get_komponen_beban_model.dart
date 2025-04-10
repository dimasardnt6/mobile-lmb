class GetKomponenBebanModel {
  int? code;
  String? message;
  List<GetKomponenBebanData>? data;

  GetKomponenBebanModel({this.code, this.message, this.data});

  factory GetKomponenBebanModel.fromJson(Map<String, dynamic> json) {
    return GetKomponenBebanModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetKomponenBebanData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetKomponenBebanModel{code: $code, message: $message, data: $data}';
  }
}

class GetKomponenBebanData {
  String? id_komponen;
  String? nm_komponen;
  String? id_kategori_item_teknik;

  GetKomponenBebanData({
    this.id_komponen,
    this.nm_komponen,
    this.id_kategori_item_teknik,
  });

  factory GetKomponenBebanData.fromJson(Map<String, dynamic> json) {
    return GetKomponenBebanData(
      id_komponen: json['id_komponen'],
      nm_komponen: json['nm_komponen'],
      id_kategori_item_teknik: json['id_kategori_item_teknik'],
    );
  }

  @override
  String toString() {
    return 'GetKomponenBebanData{id_komponen: $id_komponen, nm_komponen: $nm_komponen, id_kategori_item_teknik: $id_kategori_item_teknik}';
  }
}

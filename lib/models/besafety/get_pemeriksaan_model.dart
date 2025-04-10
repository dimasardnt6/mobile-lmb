class GetPemeriksaanModel {
  int? code;
  String? message;
  List<GetPemeriksaanData>? data;

  GetPemeriksaanModel({this.code, this.message, this.data});

  factory GetPemeriksaanModel.fromJson(Map<String, dynamic> json) {
    return GetPemeriksaanModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetPemeriksaanData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetPemeriksaanModel{code: $code, message: $message, data: $data}';
  }
}

class GetPemeriksaanData {
  String? id_pemeriksaan;
  String? pernyataan_pemeriksaan;

  GetPemeriksaanData({this.id_pemeriksaan, this.pernyataan_pemeriksaan});

  factory GetPemeriksaanData.fromJson(Map<String, dynamic> json) {
    return GetPemeriksaanData(
      id_pemeriksaan: json['id_pemeriksaan'],
      pernyataan_pemeriksaan: json['pernyataan_pemeriksaan'],
    );
  }

  @override
  String toString() {
    return 'GetPemeriksaanData{id_pemeriksaan: $id_pemeriksaan, pernyataan_pemeriksaan: $pernyataan_pemeriksaan}';
  }
}

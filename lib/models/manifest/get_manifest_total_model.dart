class GetManifestTotalModel {
  int? code;
  String? message;
  List<GetManifestTotalData>? data;

  GetManifestTotalModel({this.code, this.message, this.data});

  factory GetManifestTotalModel.fromJson(Map<String, dynamic> json) {
    return GetManifestTotalModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => GetManifestTotalData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'GetManifestTotalModel(code: $code, message: $message, data: $data)';
  }
}

class GetManifestTotalData {
  String? ritase;
  String? bis;
  String? catatan;
  String? total_validasi;
  String? total_manifest;
  String? active;

  GetManifestTotalData({
    this.ritase,
    this.bis,
    this.catatan,
    this.total_validasi,
    this.total_manifest,
    this.active,
  });

  factory GetManifestTotalData.fromJson(Map<String, dynamic> json) {
    return GetManifestTotalData(
      ritase: json['ritase'],
      bis: json['bis'],
      catatan: json['catatan'],
      total_validasi: json['total_validasi'],
      total_manifest: json['total_manifest'],
      active: json['active'],
    );
  }

  @override
  String toString() {
    return 'GetManifestTotalData(ritase: $ritase, bis: $bis, catatan: $catatan, total_validasi: $total_validasi, total_manifest: $total_manifest, active: $active)';
  }
}

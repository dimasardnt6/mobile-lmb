class KomersilTotalModel {
  final int code;
  final String message;
  final List<KomersilTotalData>? data;

  KomersilTotalModel({required this.code, required this.message, this.data});

  factory KomersilTotalModel.fromJson(Map<String, dynamic> json) {
    return KomersilTotalModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => KomersilTotalData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'KomersilTotalModel(code: $code, message: $message, data: $data)';
  }
}

class KomersilTotalData {
  final String ritase;
  final String? catatan;
  final String nm_trayek_detail;
  final String total;
  final String active;

  KomersilTotalData({
    required this.ritase,
    this.catatan,
    required this.nm_trayek_detail,
    required this.total,
    required this.active,
  });

  factory KomersilTotalData.fromJson(Map<String, dynamic> json) {
    return KomersilTotalData(
      ritase: json['ritase'],
      catatan: json['catatan'] ?? "Tidak ada catatan",
      nm_trayek_detail: json['nm_trayek_detail'],
      total: json['total'],
      active: json['active'],
    );
  }

  @override
  String toString() {
    return 'KomersilTotalData(ritase: $ritase, catatan: $catatan, nm_trayek_detail: $nm_trayek_detail, total: $total, active: $active)';
  }
}

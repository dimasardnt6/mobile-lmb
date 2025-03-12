class ListArmadaByLmbModel {
  final int? code;
  final String? message;
  final List<ListArmadaByLmbData>? data;

  ListArmadaByLmbModel({this.code, this.message, this.data});

  factory ListArmadaByLmbModel.fromJson(Map<String, dynamic> json) {
    return ListArmadaByLmbModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] == null
              ? null
              : (json['data'] as List)
                  .map((item) => ListArmadaByLmbData.fromJson(item))
                  .toList(),
    );
  }

  @override
  String toString() {
    return 'ListArmadaByLmbModel(code: $code, message: $message, data: $data)';
  }
}

class ListArmadaByLmbData {
  final String? id_lmb;
  final String? kd_armada;
  final String? kd_trayek;

  ListArmadaByLmbData({this.id_lmb, this.kd_armada, this.kd_trayek});

  factory ListArmadaByLmbData.fromJson(Map<String, dynamic> json) {
    return ListArmadaByLmbData(
      id_lmb: json['id_lmb'],
      kd_armada: json['kd_armada'],
      kd_trayek: json['kd_trayek'],
    );
  }

  @override
  String toString() {
    return 'ListArmadaByLmbData(id_lmb: $id_lmb, kd_armada: $kd_armada, kd_trayek: $kd_trayek)';
  }
}

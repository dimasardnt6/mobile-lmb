class GetItemBebanModel {
  int? code;
  String? message;
  List<GetItemBebanData>? data;

  GetItemBebanModel({this.code, this.message, this.data});

  factory GetItemBebanModel.fromJson(Map<String, dynamic> json) {
    return GetItemBebanModel(
      code: json['code'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((i) => GetItemBebanData.fromJson(i))
                  .toList()
              : null,
    );
  }

  @override
  String toString() {
    return 'GetItemBebanModel{code: $code, message: $message, data: $data}';
  }
}

class GetItemBebanData {
  String? id_item;
  String? nm_item;
  String? harga;

  GetItemBebanData({this.id_item, this.nm_item, this.harga});

  factory GetItemBebanData.fromJson(Map<String, dynamic> json) {
    return GetItemBebanData(
      id_item: json['id_item'],
      nm_item: json['nm_item'],
      harga: json['harga'],
    );
  }

  @override
  String toString() {
    return 'GetItemBebanData{id_item: $id_item, nm_item: $nm_item, harga: $harga}';
  }
}

class VersionModel {
  final VersionData? data;
  final int code;
  final String message;

  VersionModel({this.data, required this.code, required this.message});

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      data: json['data'] != null ? VersionData.fromJson(json['data']) : null,
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'VersionModel(data: ${data?.toString() ?? "null"}, code: $code, message: $message)';
  }
}

class VersionData {
  final String version_code;
  final String version_name;
  final String keterangan;
  final String active;

  VersionData({
    required this.version_code,
    required this.version_name,
    required this.keterangan,
    required this.active,
  });

  factory VersionData.fromJson(Map<String, dynamic> json) {
    return VersionData(
      version_code: json['version_code'],
      version_name: json['version_name'],
      keterangan: json['keterangan'],
      active: json['active'],
    );
  }

  @override
  String toString() {
    return 'VersionData(version_code: $version_code, version_name: $version_name, keterangan: $keterangan, active: $active)';
  }
}

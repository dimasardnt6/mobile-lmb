class AuthModel {
  final bool status;
  final UserData? data;
  final int code;
  final String message;

  AuthModel({
    required this.status,
    this.data,
    required this.code,
    required this.message,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      status: json['status'],
      data: json['status'] ? UserData.fromJson(json['data']) : null,
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'AuthModel(status: $status, code: $code, message: $message, data: ${data?.toString() ?? "null"})';
  }
}

class UserData {
  final String nm_user;
  final String user_id;
  final String username;
  final String id_level;
  final String id_bu;
  final String id_perusahaan;
  final String nm_perusahaan;
  final String active;
  final String developer;
  final String token;

  UserData({
    required this.nm_user,
    required this.user_id,
    required this.username,
    required this.id_level,
    required this.id_bu,
    required this.id_perusahaan,
    required this.nm_perusahaan,
    required this.active,
    required this.developer,
    required this.token,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nm_user: json['nm_user'],
      user_id: json['user_id'],
      username: json['username'],
      id_level: json['id_level'],
      id_bu: json['id_bu'],
      id_perusahaan: json['id_perusahaan'],
      nm_perusahaan: json['nm_perusahaan'],
      active: json['active'],
      developer: json['developer'],
      token: json['token'],
    );
  }

  @override
  String toString() {
    return 'UserData(nm_user: $nm_user, userId: $user_id, username: $username, token: $token)';
  }
}

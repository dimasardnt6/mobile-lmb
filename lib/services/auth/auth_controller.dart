import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lmb_online/models/auth/login_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class AuthController {
  final Dio _dio = Dio();

  Future<AuthModel> login(String username, String password) async {
    final String url = "${Endpoints.baseUrl}/operasi/login";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    FormData formData = FormData.fromMap({
      "username": username,
      "password": password,
    });

    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      print("Response Data Auth Controller: $response");

      // Ambil response dari API
      final responseData = response.data;
      final int responseCode = responseData['code'] ?? 400;

      if (responseCode == 200 && responseData['status'] == true) {
        AuthModel user = AuthModel.fromJson(responseData);
        await saveUserToPreferences(user.data!);
        return user;
      } else {
        return AuthModel(
          status: false,
          code: responseCode,
          message: responseData['message'] ?? "Login gagal, coba lagi.",
          data: null,
        );
      }
    } on DioError catch (e) {
      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return AuthModel(
        status: false,
        code: e.response?.statusCode ?? 500,
        message: "Gagal login: $errorMessage",
        data: null,
      );
    } catch (e) {
      return AuthModel(
        status: false,
        code: 500,
        message: "Terjadi Kesalahan: ${e.toString()}",
        data: null,
      );
    }
  }

  /// **Menyimpan data pengguna dan token ke SharedPreferences**
  Future<void> saveUserToPreferences(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nm_user', user.nm_user);
    await prefs.setString('user_id', user.user_id);
    await prefs.setString('username', user.username);
    await prefs.setString('id_level', user.id_level);
    await prefs.setString('id_bu', user.id_bu);
    await prefs.setString('id_perusahaan', user.id_perusahaan);
    await prefs.setString('nm_perusahaan', user.nm_perusahaan);
    await prefs.setString('active', user.active);
    await prefs.setString('developer', user.developer);
    await prefs.setString('token', user.token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nm_user');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('id_level');
    await prefs.remove('id_bu');
    await prefs.remove('id_perusahaan');
    await prefs.remove('nm_perusahaan');
    await prefs.remove('active');
    await prefs.remove('developer');
    await prefs.remove('token');
  }
}

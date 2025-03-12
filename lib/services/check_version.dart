import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/models/version_model.dart';

class CheckVersion {
  final Dio _dio = Dio();

  final _baseUrl = "http://apioperasi.bigiip.com";

  Future<VersionModel> checkVersion() async {
    final String url = "$_baseUrl/lmb_online/dashboard/version_apps";
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    try {
      Response response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return VersionModel.fromJson(responseData);
      } else {
        return VersionModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal mendapatkan versi aplikasi.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return VersionModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan versi aplikasi: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return VersionModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

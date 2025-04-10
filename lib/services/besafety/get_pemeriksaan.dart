import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/besafety/get_pemeriksaan_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetPemeriksaan {
  final Dio _dio = Dio();

  Future<GetPemeriksaanModel> getPemeriksaan(
    String id_level,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/besafety/pemeriksaan?id_level=$id_level";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    try {
      Response response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print("Response Data: $responseData");

      if (responseCode == 200) {
        return GetPemeriksaanModel.fromJson(responseData);
      } else {
        return GetPemeriksaanModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal mendapatkan data pemeriksaan",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetPemeriksaanModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data pemeriksaan: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetPemeriksaanModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/besafety/get_verifikasi_pemeriksaan_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetVerifikasiPemeriksaan {
  final Dio _dio = Dio();

  Future<GetVerifikasiPemeriksaanModel> getVerifikasiPemeriksaan(
    String id_user,
    String id_level,
    String id_lmb_value,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/besafety/verifikasi_pemeriksaan?id_user=$id_user&id_level=$id_level&id_lmb=$id_lmb_value";

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

      if (response.statusCode == 200) {
        return GetVerifikasiPemeriksaanModel.fromJson(responseData);
      } else {
        return GetVerifikasiPemeriksaanModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data verifikasi pemeriksaan",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetVerifikasiPemeriksaanModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data verifikasi pemeriksaan: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetVerifikasiPemeriksaanModel(
        code: 500,
        message: "Terjadi Kesalahan: $e",
      );
    }
  }
}

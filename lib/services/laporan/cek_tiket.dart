import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/laporan/cek_tiket_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class CekTiketPenumpang {
  final Dio _dio = Dio();

  Future<CekTiketModel> cekTiketPenumpang(String kd_tiket, String token) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/laporan/cek-tiket?kd_tiket=$kd_tiket";

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

      print('Response Data HANDLECEKTIKET : $responseData');

      if (responseCode == 200) {
        return CekTiketModel.fromJson(responseData);
      } else {
        return CekTiketModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data tiket.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return CekTiketModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data tiket: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return CekTiketModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

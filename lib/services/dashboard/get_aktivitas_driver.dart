import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/dashboard/get_aktifitas_driver_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetAktivitasDriver {
  final Dio _dio = Dio();

  Future<GetAktifitasDriverModel> getAktivitasDriver(
    String username,
    String tgl_awal,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/dashboard/aktivitas-driver?nik=$username&tgl_awal=$tgl_awal";

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
        return GetAktifitasDriverModel.fromJson(responseData);
      } else {
        return GetAktifitasDriverModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data aktivitas driver",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetAktifitasDriverModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data aktivitas driver: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetAktifitasDriverModel(
        code: 500,
        message: "Terjadi Kesalahan: $e",
      );
    }
  }
}

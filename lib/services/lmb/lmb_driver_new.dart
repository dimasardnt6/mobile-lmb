import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';

class LmbDriverNew {
  final Dio _dio = Dio();

  Future<LmbDriverNewModel> getLmbDriverNew(
    String username,
    String token,
  ) async {
    final _baseUrl = "http://apioperasi.bigiip.com";

    // tanggal
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String tanggal = formatter.format(now);

    final String url =
        "$_baseUrl/lmb-online/dashboard/lmb-driver-new?nik=$username&tgl_awal=$tanggal";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization_Token": token,
      "Authorization": basicAuth,
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
        LmbDriverNewModel lmbDriverNewModel = LmbDriverNewModel.fromJson(
          responseData,
        );
        print("LMB Driver New: $lmbDriverNewModel");
        return lmbDriverNewModel;
      } else {
        return LmbDriverNewModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data LMB.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return LmbDriverNewModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data LMB: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return LmbDriverNewModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

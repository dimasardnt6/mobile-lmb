import 'package:dio/dio.dart';
import 'package:lmb_online/models/operasi/regular_perkotaan/get_reguler_model.dart';
import 'dart:convert';

import 'package:lmb_online/services/endpoint.dart';

// TIPE LMB 3
class GetReguler {
  final Dio _dio = Dio();

  Future<GetRegulerModel> getReguler(String id_lmb) async {
    final String url =
        "${Endpoints.baseUrl}/operasi/lmb/reguler?id_lmb=$id_lmb";

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
        return GetRegulerModel.fromJson(responseData);
      } else {
        return GetRegulerModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data reguler.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetRegulerModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data reguler: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetRegulerModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

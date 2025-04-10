import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/models/operasi/reguler_komersil/komersil_total_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetKomersilTotal {
  final Dio _dio = Dio();

  Future<KomersilTotalModel> getKomersilTotal(String id_lmb) async {
    final String url =
        "${Endpoints.baseUrl}/operasi/reguler/komersil_total?id_lmb=$id_lmb";

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
        return KomersilTotalModel.fromJson(responseData);
      } else {
        return KomersilTotalModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data total komersil.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return KomersilTotalModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data total komersil: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return KomersilTotalModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/services/endpoint.dart';
import 'package:lmb_online/models/beban/get_beban_model.dart';

class GetBeban {
  final Dio _dio = Dio();

  Future<GetBebanModel> getBeban(String id_lmb, String token) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/beban?id_lmb=$id_lmb";

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
        return GetBebanModel.fromJson(responseData);
      } else {
        return GetBebanModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data beban",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetBebanModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data beban: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetBebanModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

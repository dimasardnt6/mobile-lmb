import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/beban/get_komponen_beban_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetKomponenBeban {
  final Dio _dio = Dio();

  Future<GetKomponenBebanModel> getKomponenBeban(String token) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/komponen-beban";

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
        return GetKomponenBebanModel.fromJson(responseData);
      } else {
        return GetKomponenBebanModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data komponen beban",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetKomponenBebanModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data komponen beban: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetKomponenBebanModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

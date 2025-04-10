import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/trayek/get_trayek_bko_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetTrayekBko {
  final Dio _dio = Dio();

  Future<GetTrayekBkoModel> getTrayekBko(
    String id_bu,
    String search,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/operasi/trayek/all?id_bu=$id_bu&search=$search";

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

      if (responseCode == 200) {
        return GetTrayekBkoModel.fromJson(responseData);
      } else {
        return GetTrayekBkoModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal mendapatkan data trayek BKO.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetTrayekBkoModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data trayek: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetTrayekBkoModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

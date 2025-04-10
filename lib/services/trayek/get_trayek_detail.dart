import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/trayek/get_trayek_detail_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetTrayekDetail {
  final Dio _dio = Dio();

  Future<GetTrayekDetailModel> getTrayekDetail(String id_trayek) async {
    final String url = "${Endpoints.baseUrl}/operasi/trayek/detail/$id_trayek";

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
        return GetTrayekDetailModel.fromJson(responseData);
      } else {
        return GetTrayekDetailModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data trayek.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetTrayekDetailModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data trayek: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetTrayekDetailModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

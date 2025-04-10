import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:lmb_online/models/lmb/detail_ritase_model.dart';

class GetDetailRitase {
  final Dio _dio = Dio();

  Future<DetailRitaseModel> getDetailRitase(
    String id_lmb,
    String ritase,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/operasi/reguler/detail_ritase?id_lmb=$id_lmb&ritase=$ritase";

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
        return DetailRitaseModel.fromJson(responseData);
      } else {
        return DetailRitaseModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data detail ritase.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return DetailRitaseModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data detail ritase: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return DetailRitaseModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

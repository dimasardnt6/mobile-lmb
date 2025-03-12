import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:lmb_online/models/armada/armada_by_id_model.dart';

class PutArmadaById {
  final Dio _dio = Dio();

  Future<ArmadaByIdModel> putArmadaById(
    String id_lmb_reguler_apps,
    String id_lmb,
    String ritase,
  ) async {
    final _baseUrl = "http://apioperasi.bigiip.com";

    final String url = "$_baseUrl/operasi/reguler/armada-by-id";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    Map<String, dynamic> body = {
      "id_lmb_reguler_apps": id_lmb_reguler_apps,
      "id_lmb": id_lmb,
      "ritase": ritase,
    };

    print("Body: $body");

    try {
      Response response = await _dio.put(
        url,
        data: body,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print("Response: $responseCode");

      if (responseCode == 202) {
        print("Response Data: $responseData");
        return ArmadaByIdModel(
          code: responseCode,
          message: responseData['message'] ?? "Berhasil mengubah data armada.",
        );
      } else {
        return ArmadaByIdModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mengubah data armada.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return ArmadaByIdModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mengubah data armada: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return ArmadaByIdModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

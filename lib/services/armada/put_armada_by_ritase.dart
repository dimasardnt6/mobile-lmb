import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:lmb_online/models/armada/armada_by_ritase_model.dart';

class PutArmadaByRitase {
  final Dio _dio = Dio();

  Future<ArmadaByRitaseModel> putArmadaByRitase(
    String id_lmb_lama,
    String id_lmb_baru,
    String ritase_lama,
    String ritase_baru,
  ) async {
    final _baseUrl = "http://apioperasi.bigiip.com";

    final String url = "$_baseUrl/operasi/reguler/armada-by-ritase";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    Map<String, dynamic> body = {
      "id_lmb_lama": id_lmb_lama,
      "id_lmb_baru": id_lmb_baru,
      "ritase_lama": ritase_lama,
      "ritase_baru": ritase_baru,
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
        return ArmadaByRitaseModel(
          code: responseCode,
          message: responseData['message'] ?? "Berhasil mengubah data armada.",
        );
      } else {
        return ArmadaByRitaseModel(
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

      return ArmadaByRitaseModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mengubah data armada: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return ArmadaByRitaseModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

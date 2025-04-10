import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:lmb_online/models/manifest/reject_tiket_model.dart';

class RejectTiket {
  final Dio _dio = Dio();

  Future<RejectTiketModel> rejectTiket(String kd_tiket, String token) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/akap/reject-ticket";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({"kd_tiket": kd_tiket});

    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 201) {
        return RejectTiketModel.fromJson(responseData);
      } else {
        return RejectTiketModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal menambahkan manifest.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return RejectTiketModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menambahkan manifest: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return RejectTiketModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

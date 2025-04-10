import 'package:dio/dio.dart';
import 'package:lmb_online/models/ppa/verifikasi_ppa_akap_model.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';

class VerifikasiPpaAkap {
  final Dio _dio = Dio();

  Future<VerifikasiPpaAkapModel> verifikasiPpaAkap(
    String id_lmb,
    String ritase,
    String user,
    String pnp,
    String status,
    String catatan,
    String level,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/akap/verifikasi-ppa";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "ritase": ritase,
      "user": user,
      "pnp": pnp,
      "status": status,
      "catatan": catatan,
    });

    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 201) {
        return VerifikasiPpaAkapModel.fromJson(responseData);
      } else {
        return VerifikasiPpaAkapModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal verifikasi PPA AKAP.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return VerifikasiPpaAkapModel(
        code: e.response?.data['code'],
        message: errorMessage,
      );
    }
  }
}

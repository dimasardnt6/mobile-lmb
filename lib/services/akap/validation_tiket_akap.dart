import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/akap/validation_tiket_akap_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class ValidationTiketAkap {
  final Dio _dio = Dio();

  Future<ValidationTiketAkapModel> validationTiketAkap(
    String id_lmb,
    String id_trayek,
    String id_trayek_detail,
    String kd_tiket,
    String cuser,
    String tgl_lmb,
    String ritase,
    String tiket_beli,
    String isTrayekValid,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/akap/validation";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization_Token": token,
      "Authorization": basicAuth,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "id_trayek": id_trayek,
      "id_trayek_detail": id_trayek_detail,
      "kd_tiket": kd_tiket,
      "cuser": cuser,
      "tgl_lmb": tgl_lmb,
      "ritase": ritase,
      "tiket_beli": tiket_beli,
      "isTrayekValid": isTrayekValid,
    });

    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        print("Response Data: $responseData");
        return ValidationTiketAkapModel.fromJson(responseData);
      } else {
        return ValidationTiketAkapModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data LMB.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return ValidationTiketAkapModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data LMB: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return ValidationTiketAkapModel(code: 500, message: "Terjadi Kesalahan.");
    }
  }
}

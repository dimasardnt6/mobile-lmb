import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/ap2/validation_tiket_ap2_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class ValidationTiketAp2 {
  final Dio _dio = Dio();

  Future<ValidationTiketAp2Model> postValidation(
    String id_lmb,
    String id_trayek,
    String kd_tiket,
    String cuser,
    String tgl_lmb,
    String ritase,
    String tiket_beli,
    String isTrayekValid,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/airport/validation/ap2";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization_Token": token,
      "Authorization": basicAuth,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "id_trayek": id_trayek,
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
        return ValidationTiketAp2Model.fromJson(responseData);
      } else {
        return ValidationTiketAp2Model(
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

      return ValidationTiketAp2Model(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data LMB: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return ValidationTiketAp2Model(
        code: 500,
        message: "Terjadi Kesalahan: $e",
      );
    }
  }
}

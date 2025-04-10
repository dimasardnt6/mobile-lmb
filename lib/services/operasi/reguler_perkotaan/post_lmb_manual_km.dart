import 'package:dio/dio.dart';
import 'package:lmb_online/models/operasi/regular_perkotaan/post_lmb_manual_km_model.dart';
import 'dart:convert';

import 'package:lmb_online/services/endpoint.dart';

// TIPE LMB 2
class PostLmbManualKm {
  final Dio _dio = Dio();

  Future<PostLmbManualKmModel> postLmbManualKm(
    String id_lmb,
    String id_trayek,
    String id_trayek_detail,
    String ritase,
    String km_ritase,
    String waktu,
    String kode_layanan,
    String cuser,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/manual/reguler-km";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "id_trayek": id_trayek,
      "id_trayek_detail": id_trayek_detail,
      "ritase": ritase,
      "km_ritase": km_ritase,
      "waktu": waktu,
      "kode_layanan": kode_layanan,
      "cuser": cuser,
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
        return PostLmbManualKmModel.fromJson(responseData);
      } else {
        return PostLmbManualKmModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal menambahkan data LMB manual km",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return PostLmbManualKmModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menambahkan data LMB manual km: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return PostLmbManualKmModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:lmb_online/models/operasi/regular_perkotaan/post_reguler_model.dart';
import 'package:lmb_online/services/endpoint.dart';

// TIPE LMB 3
class PostReguler {
  final Dio _dio = Dio();

  Future<PostRegulerModel> postReguler(
    String id_trayek_detail,
    String id_lmb,
    String ritase,
    String jml_penumpang,
    String waktu,
    String nomor_ap3,
    String cuser,
  ) async {
    final String url = "${Endpoints.baseUrl}/operasi/lmb/reguler";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    FormData formData = FormData.fromMap({
      "id_trayek_detail": id_trayek_detail,
      "id_lmb": id_lmb,
      "ritase": ritase,
      "jml_penumpang": jml_penumpang,
      "waktu": waktu,
      "nomor_ap3": nomor_ap3,
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
        return PostRegulerModel.fromJson(responseData);
      } else {
        return PostRegulerModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal menambahkan data reguler",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return PostRegulerModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menambahkan data reguler: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return PostRegulerModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

import 'package:dio/dio.dart';
import 'package:lmb_online/models/operasi/regular_perkotaan/delete_reguler_model.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';

// TIPE LMB 3
class DeleteReguler {
  final Dio _dio = Dio();

  Future<DeleteRegulerModel> deleteReguler(String id_lmb_reguler_value) async {
    final String url = "${Endpoints.baseUrl}/operasi/lmb/reguler";

    // Basic Auth
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    // Header
    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    final data = {
      "data": [
        {"id_lmb_reguler": id_lmb_reguler_value},
      ],
    };

    try {
      Response response = await _dio.delete(
        url,
        data: data,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 201) {
        return DeleteRegulerModel.fromJson(responseData);
      } else {
        return DeleteRegulerModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal menghapus data reguler",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return DeleteRegulerModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menghapus data reguler: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return DeleteRegulerModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

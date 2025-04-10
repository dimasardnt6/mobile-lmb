import 'package:dio/dio.dart';
import 'package:lmb_online/models/operasi/regular_perkotaan/delete_lmb_manual_km_model.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';

// TIPE LMB 2
class DeleteLmbManualKm {
  final Dio _dio = Dio();

  Future<DeleteLmbManualKmModel> deleteLmbManualKm(
    String id_lmb,
    String id_lmb_reguler_value,
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

    final data = {
      "id_lmb": id_lmb,
      "id_lmb_reguler": id_lmb_reguler_value,
      "cuser": cuser,
    };

    try {
      Response response = await _dio.delete(
        url,
        data: data,
        options: Options(
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 201) {
        return DeleteLmbManualKmModel.fromJson(responseData);
      } else {
        return DeleteLmbManualKmModel(
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

      return DeleteLmbManualKmModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menghapus data reguler: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return DeleteLmbManualKmModel(
        code: 500,
        message: "Terjadi Kesalahan: $e",
      );
    }
  }
}

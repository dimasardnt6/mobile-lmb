import 'package:dio/dio.dart';
import 'package:lmb_online/models/operasi/regular_perkotaan/get_lmb_manual_km_model.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';

// TIPE LMB 2
class GetLmbManualKm {
  final Dio _dio = Dio();

  Future<GetLmbManualKmModel> getLmbManualKm(
    String id_lmb,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/manual/reguler-km?id_lmb=$id_lmb";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    try {
      Response response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return GetLmbManualKmModel.fromJson(responseData);
      } else {
        return GetLmbManualKmModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data LMB manual km.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetLmbManualKmModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data LMB manual km: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetLmbManualKmModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:lmb_online/models/manifest/detail_manifest_model.dart';

class GetDetailManifest {
  final Dio _dio = Dio();

  Future<DetailManifestModel> getDetailManifest(
    String id_lmb,
    String ritase,
    String bis,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/akap/manifest-detail?id_lmb=$id_lmb&ritase=$ritase&bis=$bis";

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
        return DetailManifestModel.fromJson(responseData);
      } else {
        return DetailManifestModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data detail manifest.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return DetailManifestModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data detail manifest: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return DetailManifestModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

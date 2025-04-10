import 'package:dio/dio.dart';
import 'package:lmb_online/models/manifest/delete_manifest_model.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';

class DeleteManifest {
  final Dio _dio = Dio();

  Future<DeleteManifestModel> deleteManifest(
    String id_lmb,
    String bis_value,
    String ritase_value,
    String verifikasi,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/akap/manifest";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    final data = {
      "id_lmb": id_lmb,
      "bis": bis_value,
      "ritase": ritase_value,
      "verifikasi": verifikasi,
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
        return DeleteManifestModel.fromJson(responseData);
      } else {
        return DeleteManifestModel(
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

      return DeleteManifestModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menghapus data reguler: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return DeleteManifestModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

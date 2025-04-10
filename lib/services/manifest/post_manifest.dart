import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:lmb_online/models/manifest/post_manifest_model.dart';

class PostManifest {
  final Dio _dio = Dio();

  Future<PostManifestModel> postManifest(
    String id_lmb,
    String ritase,
    String bis,
    String tanggal,
    String kd_trayek,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/akap/manifest";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "ritase": ritase,
      "bis": bis,
      "tanggal": tanggal,
      "kd_trayek": kd_trayek,
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
        return PostManifestModel.fromJson(responseData);
      } else {
        return PostManifestModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal menambahkan manifest.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return PostManifestModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menambahkan manifest: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return PostManifestModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

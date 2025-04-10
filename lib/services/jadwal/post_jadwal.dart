import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/jadwal/post_jadwal_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class PostJadwal {
  final Dio _dio = Dio();

  Future<PostJadwalModel> postJadwal(
    String kd_trayek,
    String tanggal,
    String jenis,
    String kd_segmen,
    String token,
  ) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "kd_trayek": kd_trayek,
      "tanggal": tanggal,
      "jenis": jenis,
      "kd_segmen": kd_segmen,
    });

    try {
      Response response = await _dio.post(
        "${Endpoints.baseUrl}/lmb-online/akap/jadwal",
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        print("Response Data: $responseData");
        return PostJadwalModel.fromJson(responseData);
      } else {
        return PostJadwalModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal menambahkan jadwal.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return PostJadwalModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menambahkan jadwal: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return PostJadwalModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/besafety/post_verifikasi_pemeriksaan_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class PostVerifikasiPemeriksaan {
  final Dio _dio = Dio();

  Future<PostVerifikasiPemeriksaanModel> postVerifikasiPemeriksaan(
    String id_user,
    String respon_pemeriksaan,
    String keterangan,
    String id_lmb_value,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/besafety/verifikasi_pemeriksaan";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "id_user": id_user,
      "respon_pemeriksaan": respon_pemeriksaan,
      "keterangan": keterangan,
      "id_lmb": id_lmb_value,
    });

    print('id_user controller: $id_user');
    print('respon_pemeriksaan controller: $respon_pemeriksaan');
    print('keterangan controller: $keterangan');
    print('id_lmb_value controller: $id_lmb_value');
    print('token controller: $token');

    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print("Response Data: $responseData");

      if (responseCode == 201) {
        return PostVerifikasiPemeriksaanModel.fromJson(responseData);
      } else {
        return PostVerifikasiPemeriksaanModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal menambahkan data verifikasi pemeriksaan",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return PostVerifikasiPemeriksaanModel(
        code: e.response?.statusCode ?? 500,
        message:
            "Gagal menambahkan data verifikasi pemeriksaan : $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return PostVerifikasiPemeriksaanModel(
        code: 500,
        message: "Terjadi Kesalahan: $e",
      );
    }
  }
}

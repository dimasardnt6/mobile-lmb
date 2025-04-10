import 'dart:convert';
import 'package:lmb_online/models/laporan/get_laporan_lmb_ritase_model.dart';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';

class GetLaporanLmbRitase {
  final Dio _dio = Dio();

  Future<GetLaporanLmbRitaseModel> getLaporanLmbRitase(
    String id_lmb,
    String token,
  ) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    try {
      Response response = await _dio.get(
        "${Endpoints.baseUrl}/lmb-online/laporan/lmb-ritase?id_lmb=$id_lmb",
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return GetLaporanLmbRitaseModel.fromJson(responseData);
      } else {
        return GetLaporanLmbRitaseModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data laporan lmb ritase.",
        );
      }
    } on DioError catch (e) {
      return GetLaporanLmbRitaseModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

import 'dart:convert';
import 'package:lmb_online/models/laporan/get_laporan_lmb_reguler_model.dart';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';

class GetLaporanLmbReguler {
  final Dio _dio = Dio();

  Future<GetLaporanLmbRegulerModel> getLaporanLmbReguler(
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
        "${Endpoints.baseUrl}/lmb-online/laporan/lmb-reguler?id_lmb=$id_lmb",
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return GetLaporanLmbRegulerModel.fromJson(responseData);
      } else {
        return GetLaporanLmbRegulerModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data laporan lmb reguler.",
        );
      }
    } on DioError catch (e) {
      return GetLaporanLmbRegulerModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

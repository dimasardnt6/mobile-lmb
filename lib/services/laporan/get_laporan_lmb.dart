import 'dart:convert';
import 'package:lmb_online/models/laporan/get_laporan_lmb_model.dart';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';

class GetLaporanLmb {
  final Dio _dio = Dio();

  Future<GetLaporanLmbModel> getLaporanLmb(
    String username,
    String tgl_awal,
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
        "${Endpoints.baseUrl}/lmb-online/laporan/lmb?nik=$username&tgl_awal=$tgl_awal",
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return GetLaporanLmbModel.fromJson(responseData);
      } else {
        return GetLaporanLmbModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal mendapatkan data laporan lmb.",
        );
      }
    } on DioError catch (e) {
      return GetLaporanLmbModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

import 'dart:convert';
import 'package:lmb_online/models/laporan/get_laporan_validasi.dart';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';

class GetLaporanValidasi {
  final Dio _dio = Dio();

  Future<GetLaporanValidasiModel> getLaporanValidasi(
    String user_id,
    String tgl_awal,
    String level,
    String token,
  ) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    print("Tanggal Awal LAPORAN VALIDASI CONTROLLER: $tgl_awal");
    print("User ID LAPORAN VALIDASI CONTROLLER: $user_id");
    print("Level LAPORAN VALIDASI CONTROLLER: $level");

    try {
      Response response = await _dio.get(
        "${Endpoints.baseUrl}/lmb-online/laporan/ppa?user_id=$user_id&tgl_awal=$tgl_awal&level=$level",
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return GetLaporanValidasiModel.fromJson(responseData);
      } else {
        return GetLaporanValidasiModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal mendapatkan data laporan ppa.",
        );
      }
    } on DioError catch (e) {
      return GetLaporanValidasiModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

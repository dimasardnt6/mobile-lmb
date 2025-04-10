import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:lmb_online/models/armada/list_armada_by_lmb_model.dart';

class GetListArmadaByLmb {
  final Dio _dio = Dio();

  Future<ListArmadaByLmbModel> getListArmadaByLmb(
    String id_bu,
    String tgl_awal,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/operasi/lmb/armada-by-lmb?id_bu=$id_bu&tanggal=$tgl_awal";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    try {
      Response response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return ListArmadaByLmbModel.fromJson(responseData);
      } else {
        return ListArmadaByLmbModel(
          code: responseCode,
          message:
              responseData['message'] ??
              "Gagal mendapatkan data detail ritase.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return ListArmadaByLmbModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data detail ritase: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return ListArmadaByLmbModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

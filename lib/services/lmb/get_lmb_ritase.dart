import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/lmb/get_lmb_ritase_model.dart';

class GetLmbRitase {
  final Dio _dio = Dio();

  Future<GetLmbRitaseModel> getLmbRitase(String id_lmb, String token) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    try {
      Response response = await _dio.get(
        "${Endpoints.baseUrl}/lmb-online/ritase/lmb-ritase?id_lmb=$id_lmb",
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      if (responseCode == 200) {
        return GetLmbRitaseModel.fromJson(responseData);
      } else {
        return GetLmbRitaseModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data ritase.",
        );
      }
    } on DioError catch (e) {
      return GetLmbRitaseModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

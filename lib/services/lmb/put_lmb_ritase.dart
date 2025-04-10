import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lmb_online/models/lmb/put_lmb_ritase_model.dart';

class PutLmbRitase {
  final Dio _dio = Dio();

  Future<PutLmbRitaseModel> putLmbRitase(
    String id_lmb,
    String id_lmb_ritase_value,
    String km_awal,
    String km_akhir,
    String token,
  ) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    final data = {
      "id_lmb": id_lmb,
      "id_lmb_ritase": id_lmb_ritase_value,
      "km_awal": km_awal,
      "km_akhir": km_akhir,
    };

    try {
      Response response = await _dio.put(
        "${Endpoints.baseUrl}/lmb-online/ritase/lmb-ritase",
        data: data,
        options: Options(
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print('rsponse data api $responseData');

      if (responseCode == 201) {
        return PutLmbRitaseModel.fromJson(responseData);
      } else {
        return PutLmbRitaseModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal update data ritase.",
        );
      }
    } on DioError catch (e) {
      debugPrint("DioError: ${e.response?.data}");
      return PutLmbRitaseModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

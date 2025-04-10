import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lmb_online/models/lmb/delete_lmb_ritase_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class DeleteLmbRitase {
  final Dio _dio = Dio();

  Future<DeleteLmbRitaseModel> deleteLmbRitase(
    String id_lmb,
    String id_lmb_ritase,
    String token,
  ) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    final data = {"id_lmb": id_lmb, "id_lmb_ritase": id_lmb_ritase};

    try {
      Response response = await _dio.delete(
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

      if (responseCode == 200) {
        return DeleteLmbRitaseModel.fromJson(responseData);
      } else {
        return DeleteLmbRitaseModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal hapus data ritase.",
        );
      }
    } on DioError catch (e) {
      debugPrint("DioError: ${e.response?.data}");
      return DeleteLmbRitaseModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

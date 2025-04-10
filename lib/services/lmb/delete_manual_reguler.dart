import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lmb_online/models/lmb/delete_manual_reguler_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class DeleteManualReguler {
  final Dio _dio = Dio();

  Future<DeleteManualRegulerModel> deleteManualReguler(
    String id_lmb,
    String id_lmb_reguler_apps,
    String token,
  ) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    final data = {"id_lmb": id_lmb, "id_lmb_reguler_apps": id_lmb_reguler_apps};

    try {
      Response response = await _dio.delete(
        "${Endpoints.baseUrl}/lmb-online/manual/lmb-manual",
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
        return DeleteManualRegulerModel.fromJson(responseData);
      } else {
        return DeleteManualRegulerModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal hapus data manual reguler.",
        );
      }
    } on DioError catch (e) {
      debugPrint("DioError: ${e.response?.data}");
      return DeleteManualRegulerModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

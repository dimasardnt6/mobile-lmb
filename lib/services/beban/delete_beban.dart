import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lmb_online/models/beban/delete_beban_model.dart';

class DeleteBeban {
  final Dio _dio = Dio();

  Future<DeleteBebanModel> deleteBeban(
    String id_lmb,
    String id_lmb_beban_value,
    String cuser,
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
      "id_lmb_beban": id_lmb_beban_value,
      "cuser": cuser,
    };

    try {
      Response response = await _dio.delete(
        "${Endpoints.baseUrl}/lmb-online/beban",
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
        return DeleteBebanModel.fromJson(responseData);
      } else {
        return DeleteBebanModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal hapus data beban.",
        );
      }
    } on DioError catch (e) {
      debugPrint("DioError: ${e.response?.data}");
      return DeleteBebanModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

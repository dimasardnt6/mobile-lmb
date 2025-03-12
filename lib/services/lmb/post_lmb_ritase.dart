import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lmb_online/models/lmb/post_lmb_ritase_model.dart';

class PostLmbRitase {
  final Dio _dio = Dio();

  final _baseUrl = "http://apioperasi.bigiip.com";

  Future<PostLmbRitaseModel> postLmbRitase(
    String id_lmb,
    String ritase,
    String status,
    String km,
    String level,
    String cuser,
    String? catatan,
    String token,
  ) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:1234'))}';

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "ritase": ritase,
      "status": status,
      "km": km,
      "level": level,
      "cuser": cuser,
      "catatan": catatan,
    });

    print("Form Data id_lmb = $id_lmb");
    print("Form Data ritase = $ritase");
    print("Form Data status = $status");
    print("Form Data km = $km");
    print("Form Data level = $level");
    print("Form Data cuser = $cuser");
    print("Form Data catatan = $catatan");

    try {
      Response response = await _dio.post(
        "$_baseUrl/lmb-online/ritase/lmb-ritase",
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print('rsponse data api $responseData');

      if (responseCode == 201) {
        return PostLmbRitaseModel.fromJson(responseData);
      } else {
        return PostLmbRitaseModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal menambahkan data ritase.",
        );
      }
    } on DioError catch (e) {
      debugPrint("DioError: ${e.response?.data}");
      return PostLmbRitaseModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

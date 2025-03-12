import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lmb_online/models/lmb/lmb_ritase_list_model.dart';

class GetLmbRitaseList {
  final Dio _dio = Dio();

  final _baseUrl = "http://apioperasi.bigiip.com";

  Future<LmbRitaseListModel> getLmbRitaseList(
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
        "$_baseUrl/lmb-online/ritase/lmb-ritase-list?id_lmb=$id_lmb",
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print("Response: $responseCode");
      print("Response Data: $responseData");

      if (responseCode == 200) {
        return LmbRitaseListModel.fromJson(responseData);
      } else {
        return LmbRitaseListModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data ritase.",
        );
      }
    } on DioError catch (e) {
      debugPrint("DioError: ${e.response?.data}");
      return LmbRitaseListModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

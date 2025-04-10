import 'dart:convert';
import 'package:lmb_online/services/endpoint.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lmb_online/models/lmb/get_lmb_ritase_list_model.dart';

class GetLmbRitaseList {
  final Dio _dio = Dio();

  Future<GetLmbRitaseListModel> getLmbRitaseList(
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
        "${Endpoints.baseUrl}/lmb-online/ritase/lmb-ritase-list?id_lmb=$id_lmb",
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print("Response: $responseCode");
      print("Response Data: $responseData");

      if (responseCode == 200) {
        return GetLmbRitaseListModel.fromJson(responseData);
      } else {
        return GetLmbRitaseListModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data ritase.",
        );
      }
    } on DioError catch (e) {
      debugPrint("DioError: ${e.response?.data}");
      return GetLmbRitaseListModel(
        code: e.response?.data['code'],
        message: e.response?.data['message'],
      );
    }
  }
}

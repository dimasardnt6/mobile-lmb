import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:lmb_online/models/refresh_token_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class RefreshToken {
  final Dio _dio = Dio();

  Future<RefreshTokenModel> refreshToken(String token, String username) async {
    final String url = "${Endpoints.baseUrl}/operasi/generate-token";
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
    };

    FormData formData = FormData.fromMap({
      "token": token,
      "username": username,
    });

    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;

      if (response.statusCode == 200) {
        // return tokennya saja
        RefreshTokenModel refreshToken = RefreshTokenModel.fromJson(
          responseData,
        );
        return refreshToken;
      } else {
        return RefreshTokenModel(
          code: responseData['code'],
          status: responseData['status'],
          desc: responseData['desc'],
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");
      return RefreshTokenModel(
        code: e.response?.data['code'],
        status: e.response?.data['status'],
        desc: e.response?.data['desc'],
      );
    }
  }
}

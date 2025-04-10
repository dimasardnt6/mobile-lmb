import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/beban/get_item_beban_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetItemBeban {
  final Dio _dio = Dio();

  Future<GetItemBebanModel> getItemBeban(
    String token,
    String id_kategori_item_teknik_value,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/item-beban?id_kategori_item_teknik=$id_kategori_item_teknik_value";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    try {
      Response response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print("Response Data: $responseData");

      if (responseCode == 200) {
        return GetItemBebanModel.fromJson(responseData);
      } else {
        return GetItemBebanModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal mendapatkan data item beban",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetItemBebanModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data item beban: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetItemBebanModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

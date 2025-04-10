import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/beban/post_beban_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class PostBeban {
  final Dio _dio = Dio();

  Future<PostBebanModel> postBeban(
    String id_lmb,
    String id_komponen,
    String id_item_teknik,
    String jumlah_beban,
    String harga_beban,
    String cuser,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/beban";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "id_komponen": id_komponen,
      "id_item_teknik": id_item_teknik,
      "jumlah_beban": jumlah_beban,
      "harga_beban": harga_beban,
      "cuser": cuser,
    });

    print('id_lmb controller: $id_lmb');
    print('id_komponen controller: $id_komponen');
    print('id_item_teknik controller: $id_item_teknik');
    print('jumlah_beban controller: $jumlah_beban');
    print('cuser controller: $cuser');
    print('token controller: $token');

    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      final int responseCode = responseData['code'];

      print("Response Data: $responseData");

      if (responseCode == 201) {
        return PostBebanModel.fromJson(responseData);
      } else {
        return PostBebanModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal menambahkan data beban.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return PostBebanModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menambahkan data beban: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return PostBebanModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

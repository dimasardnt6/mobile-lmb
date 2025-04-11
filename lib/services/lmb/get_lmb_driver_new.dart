import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:lmb_online/models/lmb/get_lmb_driver_new_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetLmbDriverNew {
  final Dio _dio = Dio();

  Future<GetLmbDriverNewModel> getLmbDriverNew(
    String username,
    String token,
  ) async {
    // tanggal
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String tanggal = formatter.format(now);

    final String url =
        "${Endpoints.baseUrl}/lmb-online/dashboard/lmb-driver-new?nik=$username&tgl_awal=$tanggal";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization_Token": token,
      "Authorization": basicAuth,
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
        GetLmbDriverNewModel GetlmbDriverNewModel =
            GetLmbDriverNewModel.fromJson(responseData);
        print("LMB Driver New: $GetlmbDriverNewModel");
        return GetlmbDriverNewModel;
      } else {
        return GetLmbDriverNewModel(
          code: responseCode,
          message: responseData['message'] ?? "Gagal mendapatkan data LMB.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return GetLmbDriverNewModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data LMB: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return GetLmbDriverNewModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

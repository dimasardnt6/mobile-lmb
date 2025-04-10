import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/lmb/get_lmb_admin_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class GetLmbAdmin {
  final Dio _dio = Dio();

  Future<GetLmbAdminModel> getLmbAdmin(
    String kd_armada,
    String tanggal,
    String id_bu,
    String id_user,
    String token,
  ) async {
    final String url =
        "${Endpoints.baseUrl}/lmb-online/dashboard/lmb-admin?kd_armada=$kd_armada&tgl_awal=$tanggal&id_bu=$id_bu&id_user=$id_user";

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
        GetLmbAdminModel getLmbAdminModel = GetLmbAdminModel.fromJson(
          responseData,
        );
        print("LMB Admin: $getLmbAdminModel");
        return getLmbAdminModel;
      } else {
        return GetLmbAdminModel(
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

      return GetLmbAdminModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal mendapatkan data LMB: $errorMessage",
      );
    }
  }
}

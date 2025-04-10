import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lmb_online/models/lmb/post_lmb_manual_model.dart';
import 'package:lmb_online/services/endpoint.dart';

class PostLmbManual {
  final Dio _dio = Dio();

  Future<PostLmbManualModel> postLmbManual(
    String id_lmb,
    String id_trayek,
    String id_trayek_detail,
    String tot_pnp,
    String tgl_lmb,
    String jenis,
    String ritase,
    String kd_armada,
    String id_bu,
    String cuser,
    String token,
  ) async {
    final String url = "${Endpoints.baseUrl}/lmb-online/manual/lmb-manual";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('admin:1234'));

    Map<String, String> headers = {
      "X-API-KEY": "d4mr1@pp4",
      "Authorization": basicAuth,
      "Authorization_Token": token,
    };

    FormData formData = FormData.fromMap({
      "id_lmb": id_lmb,
      "id_trayek": id_trayek,
      "id_trayek_detail": id_trayek_detail,
      "tot_pnp": tot_pnp,
      "tgl_lmb": tgl_lmb,
      "jenis": jenis,
      "ritase": ritase,
      "kd_armada": kd_armada,
      "id_bu": id_bu,
      "cuser": cuser,
    });

    print('id_lmb controller: $id_lmb');
    print('id_trayek controller: $id_trayek');
    print('id_trayek_detail controller: $id_trayek_detail');
    print('tot_pnp controller: $tot_pnp');
    print('tgl_lmb controller: $tgl_lmb');
    print('jenis controller: $jenis');
    print('ritase controller: $ritase');
    print('kd_armada controller: $kd_armada');
    print('id_bu controller: $id_bu');
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
        return PostLmbManualModel.fromJson(responseData);
      } else {
        return PostLmbManualModel(
          code: responseCode,
          message:
              responseData['message'] ?? "Gagal menambahkan data LMB manual.",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");

      final errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          "Terjadi Kesalahan.";

      return PostLmbManualModel(
        code: e.response?.statusCode ?? 500,
        message: "Gagal menambahkan data LMB manual: $errorMessage",
      );
    } catch (e) {
      print("Error: $e");
      return PostLmbManualModel(code: 500, message: "Terjadi Kesalahan: $e");
    }
  }
}

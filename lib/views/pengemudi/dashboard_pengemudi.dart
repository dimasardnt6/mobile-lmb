import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lmb_online/models/besafety/get_verifikasi_pemeriksaan_model.dart';
import 'package:lmb_online/models/dashboard/get_aktifitas_driver_model.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';
import 'package:lmb_online/services/besafety/get_verifikasi_pemeriksaan.dart';
import 'package:lmb_online/services/dashboard/get_aktivitas_driver.dart';
import 'package:lmb_online/services/lmb/lmb_driver_new.dart';
import 'package:lmb_online/services/lmb/post_lmb_ritase.dart';
import 'package:lmb_online/services/refresh_token.dart';
import 'package:lmb_online/views/login_screen.dart';
import 'package:lmb_online/services/auth/auth_controller.dart';
import 'package:lmb_online/views/pengemudi/cek_tiket.dart';
import 'package:lmb_online/views/pengemudi/laporan_lmb.dart';
import 'package:lmb_online/views/pengemudi/lmb/lmb_akap.dart';
import 'package:lmb_online/views/pengemudi/lmb/lmb_input_by_km.dart';
import 'package:lmb_online/views/pengemudi/lmb/lmb_manual_reguler.dart';
import 'package:lmb_online/views/pengemudi/lmb/lmb_pemadu_moda.dart';
import 'package:lmb_online/views/pengemudi/lmb/reguler/manual_km.dart';
import 'package:lmb_online/views/pengemudi/pemeriksaan_keselamatan.dart';
import 'package:lmb_online/views/widget/header_dashboard_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPengemudi extends StatefulWidget {
  const DashboardPengemudi({super.key});

  @override
  State<DashboardPengemudi> createState() => _DashboardPengemudiState();
}

class _DashboardPengemudiState extends State<DashboardPengemudi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _catatanFormKey = GlobalKey<FormState>();
  final AuthController authController = AuthController();
  final RefreshToken refreshToken = RefreshToken();
  final LmbDriverNew lmbDriverNew = LmbDriverNew();
  final PostLmbRitase postLmbRitase = PostLmbRitase();
  final GetAktivitasDriver getAktivitasDriver = GetAktivitasDriver();
  final GetVerifikasiPemeriksaan getVerifikasiPemeriksaan =
      GetVerifikasiPemeriksaan();

  // Load User Data
  String nm_user = "";
  String version_name = "";
  String user_name = "";
  // Load User Data

  List<LmbDriverNewData> _lmbDriverList = [];
  List<GetAktifitasDriverData> _listAktivitasDriver = [];
  GetVerifikasiPemeriksaanModel? _verifikasiPemeriksaanData;

  bool isLoading = false;

  // Mulai dan Akhiri Shift
  String? _inputKmValidation;
  String? _inputCatatanValidation;
  int _statusShift = 1;
  String? _selectedLmb;
  String? _kmOdoValue;
  String? _catatanValue;

  // String? _kmAkhirValue;

  final TextEditingController _kmOdoController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // End Mulai dan Akhiri Shift

  @override
  void initState() {
    super.initState();
    _loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();

    handleRefreshToken();
    _handleGetAktivitasDriver();
    await getLmbDriverNew();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nm_user = prefs.getString('nm_user') ?? "User";
      version_name = prefs.getString('version_name') ?? "1.0.0";
      user_name = prefs.getString('username') ?? "";
    });
  }

  Future<void> handleRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? username = prefs.getString('username');

    print("Token: $token");
    print("Username: $username");

    if (token != null && username != null) {
      final response = await refreshToken.refreshToken(token, username);
      if (response.token != null) {
        await prefs.setString('token', response.token!);
        print("Token baru: ${response.token}");
      } else {
        await _handleLogout();
      }
    } else {
      await _handleLogout();
    }
  }

  Future<void> _handleGetAktivitasDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? username = prefs.getString('username');
    final String? tgl_awal = DateTime.now().toString().substring(0, 10);

    try {
      var response = await getAktivitasDriver.getAktivitasDriver(
        username!,
        tgl_awal!,
        token!,
      );

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listAktivitasDriver = response.data!;
        });
        print("Data Aktivitas Driver: $_listAktivitasDriver");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetVerifikasiPemeriksaan(String id_lmb) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_user = prefs.getString('user_id');
    final String? id_level = prefs.getString('id_level');
    final String? id_lmb_value = id_lmb;

    try {
      var response = await getVerifikasiPemeriksaan.getVerifikasiPemeriksaan(
        id_user!,
        id_level!,
        id_lmb_value!,
        token!,
      );

      if (response.message == "EMPTY" || response.message == "OK") {
        setState(() {
          _verifikasiPemeriksaanData = response;
        });
        print("Data Verifikasi Pemeriksaan: $_verifikasiPemeriksaanData");
      }
    } catch (e) {
      print(e);
    }
  }

  // get lmb driver new
  Future<void> getLmbDriverNew() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? username = prefs.getString('username');

    if (token != null && username != null) {
      final response = await lmbDriverNew.getLmbDriverNew(username, token);

      if (response.code == 200 && response.data != null) {
        setState(() {
          _lmbDriverList = response.data!;
        });
        print("Data LMB Driver New: ${response.data}");
      } else {
        print("Gagal mendapatkan data LMB Driver New: ${response.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      await _handleLogout();
    }
  }

  void _handleDetailLmb(LmbDriverNewData item) {
    if (item.tipe_lmb_online == "1" && item.id_segment_transaksi == "2") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LmbPemaduModa(lmbDriverNew: item),
        ),
      ).then((refresh) {
        if (refresh == true) {
          _initData();
        }
      });
    } else if (item.tipe_lmb_online == "1" &&
        item.id_segment_transaksi == "1") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LmbAkap(lmbDriverNew: item)),
      ).then((refresh) {
        if (refresh == true) {
          _initData();
        }
      });
    } else if (item.tipe_lmb_online == "0") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LmbManualReguler(lmbDriverNew: item),
        ),
      );
    } else if (item.tipe_lmb_online == "2") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LmbInputByKm(lmbDriverNew: item),
        ),
      );
    } else if (item.tipe_lmb_online == "3") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManualKm(lmbDriverNew: item)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Tipe LMB tidak dikenali",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _handlePostLmbRitase(int _statusShift) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = _selectedLmb;
    final String? ritase = "0";
    final String? cuser = prefs.getString('user_id');
    final String? km = _kmOdoValue;
    final String? catatan = _catatanValue;
    final String? status = _statusShift.toString();
    final String? level = prefs.getString('id_level');

    print('id_lmb: $id_lmb');
    print('id_lmb type : ${id_lmb.runtimeType}');
    print('cuser: $cuser');
    print('cuser type : ${cuser.runtimeType}');
    print('ritase: $ritase');
    print('ritase type : ${ritase.runtimeType}');
    print('token: $token');
    print('km: $km');
    print('km type : ${km.runtimeType}');
    print('status: $status');
    // cek tipe data status
    print('status type: ${status.runtimeType}');
    print('level: $level');
    print('level type : ${level.runtimeType}');
    print('catatan: $catatan');
    print('catatan type : ${catatan.runtimeType}');

    try {
      var response = await postLmbRitase.postLmbRitase(
        id_lmb!,
        ritase!,
        status!,
        km!,
        level!,
        cuser!,
        catatan!,
        token!,
      );

      print('Response mulai shift: $response');

      if (response.code == 201) {
        Navigator.pop(context);
        _dialogSuccess(message: response.message);
      } else {
        _initData();
        _dialogFailed(response.message, response.code);
        print(response.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal melakukan action : ${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleLogout() async {
    await authController.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // dialog success
  void _showDialogPemeriksaanKeselamatan({String? idLmbValue}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 242, 248, 255),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Color(0xFF1A447F),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'Pemeriksaan Keselamatan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_confirm.svg',
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sebelum melakukan aktivitas pekerjaan pastikan semua alat dan kelengkapan dapat berjalan dengan baik. Lakukan pemeriksaan pada tombol berikut!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PemeriksaanKeselamatan(
                                      id_lmb: idLmbValue!,
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A447F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Verifikasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dialogShift() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Color(0xFF1A447F),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 40),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Shift',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _inputKmValidation = null;
                                  _inputCatatanValidation = null;
                                  _catatanController.clear;
                                  _catatanValue = "";
                                  _kmOdoController.clear();
                                  _kmOdoValue = "";
                                  _statusShift = 1;
                                  _selectedLmb = null;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // radio button
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Shift',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Radio<int>(
                                        value: 1,
                                        groupValue: _statusShift,
                                        activeColor: Colors.blue,
                                        onChanged: (value) {
                                          setStateDialog(() {
                                            _statusShift = value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        'Mulai',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Radio<int>(
                                        value: 6,
                                        groupValue: _statusShift,
                                        activeColor: Colors.blue,
                                        onChanged: (value) {
                                          setStateDialog(() {
                                            _statusShift = value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        'Akhiri',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Pilih LMB',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // pilih lmb
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          1,
                                          43,
                                          80,
                                        ),
                                      ),
                                    ),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedLmb,
                                      hint: const Text(
                                        'Pilih LMB',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      underline: const SizedBox(),
                                      // Filter data agar hanya menampilkan item dengan status != '6'
                                      items:
                                          _lmbDriverList
                                              .where(
                                                (item) =>
                                                    item.status_ritase != '6',
                                              )
                                              .map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item.id_lmb,
                                                  child: Row(
                                                    children: [
                                                      Text(item.id_lmb ?? '-'),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        '(${item.tgl_awal ?? '-'})',
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        '(${item.kd_trayek ?? '-'})',
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                              .toList(),
                                      onChanged: (String? newValue) {
                                        setStateDialog(() {
                                          _selectedLmb = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'KM Odo',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          1,
                                          43,
                                          80,
                                        ),
                                      ),
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: TextField(
                                        controller: _kmOdoController,
                                        maxLength: 12,
                                        buildCounter: (
                                          BuildContext context, {
                                          int? currentLength,
                                          int? maxLength,
                                          bool? isFocused,
                                        }) {
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          hintText: 'ex: 1234',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _inputKmValidation ?? "",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Catatan',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          1,
                                          43,
                                          80,
                                        ),
                                      ),
                                    ),
                                    child: Form(
                                      key: _catatanFormKey,
                                      child: TextField(
                                        controller: _catatanController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          hintText: 'input catatan',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _inputCatatanValidation ?? "",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setStateDialog(() {
                                          _inputKmValidation =
                                              _kmOdoController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'Field tidak boleh kosong'
                                                  : null;

                                          _inputCatatanValidation =
                                              _catatanController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'Field tidak boleh kosong'
                                                  : null;
                                        });

                                        if (_inputKmValidation != null ||
                                            _inputCatatanValidation != null)
                                          return;

                                        setState(() {
                                          _kmOdoValue = _kmOdoController.text;
                                          _catatanValue =
                                              _catatanController.text;
                                        });

                                        await _handlePostLmbRitase(
                                          _statusShift,
                                        );

                                        setStateDialog(() {
                                          _statusShift = 1;
                                          _catatanController.clear();
                                          _kmOdoController.clear();
                                          _kmOdoValue = "";
                                          _catatanValue = "";
                                          _selectedLmb = null;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1A447F),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Simpan',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // dialog success
  void _dialogSuccess({required message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 242, 248, 255),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_data_success.svg',
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$message',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // _kodeTiketController.clear();
                              // _kdTiketValue = null;
                            });

                            Navigator.pop(context);
                            _initData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A447F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // dialog gagal
  void _dialogFailed(String? message, int? code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 242, 248, 255),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_data_error.svg',
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$message',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Button rounded
                      const SizedBox(height: 20),
                      Container(
                        // Lebar full
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A447F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Memuat...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Anda yakin ingin logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                await _handleLogout();
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 242, 248, 255),
        body: RefreshIndicator(
          onRefresh: () async {
            _initData();
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Dashboar
                HeaderDashboardCard(
                  nmUser: nm_user,
                  versionName: version_name,
                  onRefresh: _initData,
                  onLogout: () => _showLogoutConfirmationDialog(context),
                ),
                // Slider LMB
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children:
                                _lmbDriverList.isNotEmpty
                                    ? _lmbDriverList.map((item) {
                                      return GestureDetector(
                                        onTap: () async {
                                          await _handleGetVerifikasiPemeriksaan(
                                            item.id_lmb!,
                                          );
                                          if (item.status_ritase == "6" ||
                                              item.status_ritase == null) {
                                            // if (item.status_ritase == "6") {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  item.status_ritase == "6"
                                                      ? 'LMB Sudah Selesai'
                                                      : item.status_ritase ==
                                                          null
                                                      ? 'Belum Mulai Shift'
                                                      : '',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } else {
                                            if (_verifikasiPemeriksaanData!
                                                    .code ==
                                                404) {
                                              _showDialogPemeriksaanKeselamatan(
                                                idLmbValue: item.id_lmb,
                                              );
                                            } else if (_verifikasiPemeriksaanData!
                                                    .code ==
                                                200) {
                                              _handleDetailLmb(item);
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "${_verifikasiPemeriksaanData!.message}",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.85,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  item.status_ritase == "1" ||
                                                          item.status_ritase ==
                                                              "2" ||
                                                          item.status_ritase ==
                                                              "3"
                                                      ? const Color.fromARGB(
                                                        255,
                                                        167,
                                                        211,
                                                        151,
                                                      )
                                                      : item.status_ritase ==
                                                          "6"
                                                      // dark grey
                                                      ? const Color.fromARGB(
                                                        255,
                                                        169,
                                                        169,
                                                        169,
                                                      )
                                                      : const Color.fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255,
                                                      ),
                                              boxShadow: [
                                                BoxShadow(
                                                  // ignore: deprecated_member_use
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 5,
                                                  offset: const Offset(2, 2),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 20,
                                                bottom: 20,
                                                left: 20,
                                                right: 5,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Kolom No LMB
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'No LMB',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/ic_lmb.svg',
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                item.id_lmb ??
                                                                    '-',
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      // Kolom Tanggal
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Tanggal',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/ic_calendar.svg',
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                item.tgl_awal ??
                                                                    '-',
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  // Kolom Kode Armada
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Kode Armada',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/ic_bus_front.svg',
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                item.kd_armada ??
                                                                    '-',
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      // Kolom Trayek
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Trayek',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/ic_route.svg',
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                item.kd_trayek ??
                                                                    '-',
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  if (item.id_segment_transaksi ==
                                                      "1")
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 10,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/images/ic_bus_front.svg',
                                                            width: 50,
                                                            height: 60,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (item.id_segment_transaksi ==
                                                      "2")
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 10,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/images/ic_plane.svg',
                                                            width: 50,
                                                            height: 60,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList()
                                    : [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'LMB',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Center(
                                              child: SvgPicture.asset(
                                                'assets/images/ic_data_error.svg',
                                                width: 100,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Aktifitas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Text(
                        'Aktifitas',
                        style: TextStyle(
                          color: Color.fromARGB(255, 1, 43, 80),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                children:
                                    _listAktivitasDriver.isNotEmpty
                                        ? _listAktivitasDriver.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Container(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.85,
                                              margin: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    // ignore: deprecated_member_use
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 5,
                                                    offset: const Offset(2, 2),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 20,
                                                  bottom: 20,
                                                  left: 20,
                                                  right: 20,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Kolom 1
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Kolom No LMB
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'No LMB',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              item.id_lmb ??
                                                                  '-',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        // Kolom Tanggal
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Tanggal',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              item.tgl_awal ??
                                                                  '-',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    // Kolom 2
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Kolom Ritase
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Ritase',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              item.ritase ??
                                                                  '0',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        // Kolom Total PNP
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Total PNP',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              item.tot_pnp ??
                                                                  '0',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    // Kolom 3
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Kolom Status
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Status',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              item.status_ritase ??
                                                                  'Belum Mulai Shift',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        // Kolom KM Odo
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'KM Odo',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              item.km
                                                                      ?.split(
                                                                        '.',
                                                                      )
                                                                      .first ??
                                                                  '0',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList()
                                        : [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'LMB',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Center(
                                                  child: SvgPicture.asset(
                                                    'assets/images/ic_data_error.svg',
                                                    width: 100,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Menu',
                            style: TextStyle(
                              color: Color.fromARGB(255, 1, 43, 80),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Card 1
                              GestureDetector(
                                onTap: () {
                                  _dialogShift();
                                },
                                child: Container(
                                  height: 130,
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_shift.svg',
                                        width: 60,
                                        height: 60,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Shift',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Card 2
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CekTiket(),
                                    ),
                                  ).then((refresh) {
                                    if (refresh == true) {
                                      _initData();
                                    }
                                  });
                                },
                                child: Container(
                                  height: 130,
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_ticket.svg',
                                        width: 60,
                                        height: 60,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Cek Tiket',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Card 3
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LaporanLmb(),
                                    ),
                                  ).then((refresh) {
                                    if (refresh == true) {
                                      _initData();
                                    }
                                  });
                                },
                                child: Container(
                                  height: 130,
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_lmb.svg',
                                        width: 60,
                                        height: 60,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Laporan',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

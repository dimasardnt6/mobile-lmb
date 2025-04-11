import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lmb_online/models/lmb/get_lmb_admin_model.dart';
import 'package:lmb_online/services/auth/auth_controller.dart';
import 'package:lmb_online/services/lmb/get_lmb_admin.dart';
import 'package:lmb_online/services/refresh_token.dart';
import 'package:lmb_online/views/login_screen.dart';
import 'package:lmb_online/views/widget/header_dashboard_card.dart';
import 'package:lmb_online/views/widget/scan_barcode.dart';
import 'package:lmb_online/views/ppa/detail_laporan_validasi.dart';
import 'package:lmb_online/views/widget/tab_bar_detail_lmb.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPpa extends StatefulWidget {
  const DashboardPpa({super.key});

  @override
  State<DashboardPpa> createState() => _DashboardPpaState();
}

class _DashboardPpaState extends State<DashboardPpa> {
  final GlobalKey<FormState> _formKeyKdArmada = GlobalKey<FormState>();

  AuthController authController = AuthController();
  RefreshToken refreshToken = RefreshToken();
  GetLmbAdmin getLmbAdmin = GetLmbAdmin();

  String? _inputKdArmadaValidation;

  // Load User Data
  String nm_user = "";
  String version_name = "";
  String user_name = "";
  // Load User Data

  // List LMB ADMIN
  List<GetLmbAdminData> _listLmbAdmin = [];
  // List LMB ADMIN

  // Cari LMB
  DateTime? selectedDate;
  final DateTime dateNow = DateTime.now();
  final TextEditingController _kodeArmadaController = TextEditingController();
  String _kdArmadaValue = '';
  // Cari LMB

  // Scan
  String _scannedValue = '';
  // Scan

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
    setState(() {
      _inputKdArmadaValidation = '';
      _listLmbAdmin = [];
      _kdArmadaValue = '';
      _scannedValue = '';
    });

    await _handleRefreshToken();
    // await getLmbDriverNew();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleGetLmbAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? kd_armada =
        _scannedValue.isNotEmpty ? _scannedValue : _kdArmadaValue;
    final String? tanggal =
        selectedDate == null
            ? DateFormat('yyyy-MM-dd').format(dateNow)
            : DateFormat('yyyy-MM-dd').format(selectedDate!);
    final String? id_bu = prefs.getString('id_bu');
    final String? id_user = prefs.getString('user_id');

    print('Token: $token');
    print('Kode Armada: $kd_armada');
    print('Tanggal: $tanggal');
    print('ID BU: $id_bu');
    print('ID User: $id_user');

    final response = await getLmbAdmin.getLmbAdmin(
      kd_armada!,
      tanggal!,
      id_bu!,
      id_user!,
      token!,
    );

    if (response.code == 200) {
      setState(() {
        _listLmbAdmin = response.data!;
        print('PRINT LMB ADMIN $_listLmbAdmin');
      });
    } else {
      Navigator.pop(context);
      _dialogFailed(message: 'Data tidak ditemukan');
    }
  }

  Future<void> _handleRefreshToken() async {
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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nm_user = prefs.getString('nm_user') ?? "User";
      version_name = prefs.getString('version_name') ?? "1.0.0";
      user_name = prefs.getString('username') ?? "";
    });
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

  // void _handleDetailLmb(GetLmbAdminData data) {
  //   if (data.tipe_lmb_online == "1" && data.id_segment_transaksi == "2") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => LmbPemaduModaPpa(lmbData: data),
  //       ),
  //     ).then((refresh) {
  //       if (refresh == true) {
  //         _initData();
  //       }
  //     });
  //   } else if (data.tipe_lmb_online == "1" &&
  //       data.id_segment_transaksi == "1") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => LmbAkapPpa(lmbData: data)),
  //     ).then((refresh) {
  //       if (refresh == true) {
  //         _initData();
  //       }
  //     });
  //   } else if (data.tipe_lmb_online == "0") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => LmbManualRegulerPpa(lmbData: data),
  //       ),
  //     );
  //     // } else if (data.tipe_lmb_online == "2") {
  //     //   Navigator.push(
  //     //     context,
  //     //     MaterialPageRoute(
  //     //       builder: (context) => DetailLmbInputByKm(lmbData: data),
  //     //     ),
  //     //   );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         backgroundColor: Colors.red,
  //         content: Text(
  //           "Tipe LMB tidak dikenali",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     );
  //   }
  // }

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

  // Failed Dialog
  void _dialogFailed({required message}) {
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
                        'assets/images/ic_failed.svg',
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 242, 248, 255),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              key: const Key('background'),
              bottom: 20,
              child: SvgPicture.asset(
                'assets/images/ic_data.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
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
                  //  Laporan
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailLaporanValidasi(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
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
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laporan Reguler',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: SvgPicture.asset(
                                  'assets/images/ic_bus_front.svg',
                                  width: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'Cari LMB',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // datepicker
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/ic_calendar.svg',
                                          width: 32,
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          selectedDate == null
                                              ? DateFormat(
                                                'dd MMM yyyy',
                                              ).format(dateNow)
                                              : DateFormat(
                                                'dd MMM yyyy',
                                              ).format(selectedDate!),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    if (_kodeArmadaController.text
                                        .trim()
                                        .isEmpty) {
                                      _inputKdArmadaValidation =
                                          'Field tidak boleh kosong';
                                    } else {
                                      _inputKdArmadaValidation = null;
                                    }
                                  });

                                  if (_inputKdArmadaValidation != null) return;

                                  setState(() {
                                    _kdArmadaValue = _kodeArmadaController.text;
                                  });
                                  _showLoadingDialog();

                                  await _handleGetLmbAdmin();

                                  if (_listLmbAdmin.isNotEmpty) {
                                    Navigator.pop(context);
                                  }

                                  setState(() {
                                    _inputKdArmadaValidation = '';
                                    _kodeArmadaController.clear();
                                    _kdArmadaValue = '';
                                    selectedDate = null;
                                    // _listLmbAdmin = [];
                                  });
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A447F),
                                    borderRadius: BorderRadius.circular(30),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Cari',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Field Kode Armada
                              Container(
                                width: MediaQuery.of(context).size.width * 0.65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_bus_front.svg',
                                        width: 32,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Form(
                                          key: _formKeyKdArmada,
                                          child: TextFormField(
                                            controller: _kodeArmadaController,
                                            focusNode: FocusNode(
                                              canRequestFocus: false,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: 'Kode Armada',
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Scan Kode Armada
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: IconButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ScanBarcode(
                                              tiketBeliValue: '4',
                                            ),
                                      ),
                                    );
                                    print('HASIL SCAN $result');
                                    if (result != null) {
                                      setState(() {
                                        _scannedValue = result;
                                      });
                                      _showLoadingDialog();

                                      await _handleGetLmbAdmin();

                                      if (_listLmbAdmin.isNotEmpty) {
                                        Navigator.pop(context);
                                      }

                                      setState(() {
                                        _scannedValue = '';
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Color(0xFF1A447F),
                                    size: 50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _inputKdArmadaValidation ?? "",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // hasil cari lmb
                  if (_listLmbAdmin.isNotEmpty)
                    Column(
                      children: [
                        for (final data in _listLmbAdmin)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            TabBarDetailLmb(lmbData: data),
                                  ),
                                ).then((refresh) {
                                  if (refresh == true) {
                                    _initData();
                                  }
                                });
                                // _handleDetailLmb(data);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
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
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Kolom No LMB
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'No LMB',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/ic_lmb.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    data.id_lmb ?? '-',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          // Kolom Driver
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Driver',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/ic_driver.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    data.nm_driver1 ?? '-',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
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
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Kode Armada',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/ic_bus_front.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    data.kd_armada ?? '-',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          // Kolom Trayek
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Trayek',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/ic_route.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    data.kd_trayek ?? '-',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (data.id_segment_transaksi == "1")
                                        SvgPicture.asset(
                                          'assets/images/ic_bus_front.svg',
                                          width: 50,
                                        ),
                                      if (data.id_segment_transaksi == "2")
                                        SvgPicture.asset(
                                          'assets/images/ic_plane.svg',
                                          width: 50,
                                        ),
                                    ],
                                  ),
                                ),
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
      ),
    );
  }
}

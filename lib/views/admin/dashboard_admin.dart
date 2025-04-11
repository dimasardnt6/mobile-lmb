import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lmb_online/models/dashboard/get_aktifitas_driver_model.dart';
import 'package:lmb_online/services/besafety/get_verifikasi_pemeriksaan.dart';
import 'package:lmb_online/services/dashboard/get_aktivitas_driver.dart';
import 'package:lmb_online/services/lmb/get_lmb_driver_new.dart';
import 'package:lmb_online/services/lmb/post_lmb_ritase.dart';
import 'package:lmb_online/services/refresh_token.dart';
import 'package:lmb_online/views/login_screen.dart';
import 'package:lmb_online/services/auth/auth_controller.dart';
import 'package:lmb_online/views/pengemudi/cek_tiket.dart';
import 'package:lmb_online/views/pengemudi/laporan_lmb.dart';
import 'package:lmb_online/views/widget/header_dashboard_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final AuthController authController = AuthController();
  final RefreshToken refreshToken = RefreshToken();
  final GetLmbDriverNew getLmbDriverNew = GetLmbDriverNew();
  final PostLmbRitase postLmbRitase = PostLmbRitase();
  final GetAktivitasDriver getAktivitasDriver = GetAktivitasDriver();
  final GetVerifikasiPemeriksaan getVerifikasiPemeriksaan =
      GetVerifikasiPemeriksaan();

  // Load User Data
  String nm_user = "";
  String version_name = "";
  String user_name = "";
  // Load User Data

  List<GetAktifitasDriverData> _listAktivitasDriver = [];

  bool isLoading = false;

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

  void _showDialogDaftarCabang() {
    // Controller untuk search bar
    TextEditingController _searchController = TextEditingController();
    // Inisialisasi filtered data dengan semua data awal
    // List<PostJadwalData> _filteredJadwal = List.from(_listJadwal);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 248, 255),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Dialog
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
                                'DAFTAR CABANG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                // _selectedKdBis = "";
                              });
                              Navigator.pop(context);
                              _initData();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                        left: 10,
                        top: 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.search,
                                color: Color(0xFF1A447F),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(
                                    left: 5,
                                  ),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Cari Armada ...',
                                ),
                                onChanged: (value) {
                                  String query = value.toLowerCase();
                                  setState(() {
                                    // if (query.isNotEmpty) {
                                    //   _filteredJadwal =
                                    //       _listJadwal.where((item) {
                                    //         return item.bis!
                                    //                 .toLowerCase()
                                    //                 .contains(query) ||
                                    //             item.kd_trayek!
                                    //                 .toLowerCase()
                                    //                 .contains(query);
                                    //       }).toList();
                                    // } else {
                                    //   _filteredJadwal = List.from(_listJadwal);
                                    // }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children:
                        // _filteredJadwal.isNotEmpty
                        //     ? _filteredJadwal.map((item) {
                        //       return Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 20,
                        //           vertical: 5,
                        //         ),
                        //         child: GestureDetector(
                        //           onTap: () {
                        //             setState(() {
                        //               _selectedKdBis = item.bis!;
                        //               print(
                        //                 'VALUE NEW ARMADA $_selectedKdBis',
                        //               );
                        //             });
                        //             Navigator.pop(context);
                        //             _initData();
                        //           },
                        //           child: Container(
                        //             decoration: BoxDecoration(
                        //               color: Colors.white,
                        //               borderRadius: BorderRadius.circular(
                        //                 30,
                        //               ),
                        //               boxShadow: [
                        //                 BoxShadow(
                        //                   // ignore: deprecated_member_use
                        //                   color: Colors.grey.withOpacity(
                        //                     0.5,
                        //                   ),
                        //                   spreadRadius: 1,
                        //                   blurRadius: 1,
                        //                   offset: const Offset(0, 1),
                        //                 ),
                        //               ],
                        //             ),
                        //             child: Padding(
                        //               padding: const EdgeInsets.all(15),
                        //               child: Column(
                        //                 children: [
                        //                   Row(
                        //                     mainAxisAlignment:
                        //                         MainAxisAlignment
                        //                             .spaceBetween,
                        //                     children: [
                        //                       Column(
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment
                        //                                 .start,
                        //                         children: [
                        //                           Text(
                        //                             'Bis',
                        //                             style: TextStyle(
                        //                               color: const Color(
                        //                                 0xFF1A447F,
                        //                               ),
                        //                               fontSize: 14,
                        //                             ),
                        //                           ),
                        //                           const SizedBox(width: 20),
                        //                           Text(
                        //                             'Tujuan',
                        //                             style: TextStyle(
                        //                               color: const Color(
                        //                                 0xFF1A447F,
                        //                               ),
                        //                               fontSize: 14,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                       Column(
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment
                        //                                 .start,
                        //                         children: [
                        //                           Row(
                        //                             children: [
                        //                               Text(
                        //                                 item.bis!,
                        //                                 style: TextStyle(
                        //                                   color:
                        //                                       Colors.black,
                        //                                   fontSize: 14,
                        //                                   fontWeight:
                        //                                       FontWeight
                        //                                           .bold,
                        //                                 ),
                        //                               ),
                        //                               // divider
                        //                               const SizedBox(
                        //                                 width: 10,
                        //                               ),
                        //                               Container(
                        //                                 width: 1,
                        //                                 height: 20,
                        //                                 color: Colors.grey,
                        //                               ),
                        //                               const SizedBox(
                        //                                 width: 10,
                        //                               ),
                        //                               Text(
                        //                                 item.tanggal!,
                        //                                 style: TextStyle(
                        //                                   color:
                        //                                       Colors.black,
                        //                                   fontSize: 14,
                        //                                   fontWeight:
                        //                                       FontWeight
                        //                                           .bold,
                        //                                 ),
                        //                               ),
                        //                               const SizedBox(
                        //                                 width: 10,
                        //                               ),
                        //                               Text(
                        //                                 (item.jam1 !=
                        //                                             null &&
                        //                                         item.jam1!.length >=
                        //                                             5)
                        //                                     ? item.jam1!
                        //                                         .substring(
                        //                                           0,
                        //                                           5,
                        //                                         )
                        //                                     : '-',
                        //                                 style: TextStyle(
                        //                                   color:
                        //                                       Colors.black,
                        //                                   fontSize: 14,
                        //                                   fontWeight:
                        //                                       FontWeight
                        //                                           .bold,
                        //                                 ),
                        //                               ),
                        //                             ],
                        //                           ),
                        //                           Text(
                        //                             item.kd_trayek!,
                        //                             style: TextStyle(
                        //                               color: Colors.black,
                        //                               fontSize: 14,
                        //                               fontWeight:
                        //                                   FontWeight.bold,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     }).toList()
                        //     : [
                        //       const Center(
                        //         child: Text('Data tidak ditemukan'),
                        //       ),
                        //     ],
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 2,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  // _selectedKdTrayek = idTrayek;
                                  // _selectedKmOperasional = km!;
                                  // _selectedNmTrayek = nmTrayek;

                                  // _kmOperasionalController.text =
                                  //     _selectedKmOperasional;
                                  // print('KD TRAYEK: $_selectedKdTrayek');
                                });
                                Navigator.pop(context);
                                _initData();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Text(
                                    'Aceh',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        height: 80,
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
                              borderRadius: BorderRadius.circular(25),
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
                        height: 80,
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
                              borderRadius: BorderRadius.circular(25),
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
                const SizedBox(height: 20),
                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
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
                      children: [
                        // Cabang dan Tanggal
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: GestureDetector(
                                onTap: () {
                                  _showDialogDaftarCabang();
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/ic_school.svg',
                                      width: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cabang',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Bandara Soekarno Hatta',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_date.svg',
                                  width: 30,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanggal',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '2025-03-14',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        // LMB Sima dan LMB Online
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // LMB SIMA
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.35,
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
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/ic_web.svg',
                                          width: 20,
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 2,
                                          height: 60,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Text(
                                              'LMB SIMA',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '30',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // LMB ONLINE
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.35,
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
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/ic_smartphone.svg',
                                          width: 20,
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 2,
                                          height: 60,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Text(
                                              'LMB ONLINE',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '20',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // PENUMPANG
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // PNP VALIDASI
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.35,
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
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/ic_pnp_validasi.svg',
                                          width: 20,
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 2,
                                          height: 60,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Text(
                                              'PNP VALIDASI',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '200',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // PNP APPROVED
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.35,
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
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/ic_pnp_approved.svg',
                                          width: 20,
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 2,
                                          height: 60,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Text(
                                              'PNP APPROVED',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '30',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 3 Menu
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Card 1
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
                                  height: 80,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_ticket.svg',
                                        width: 20,
                                        height: 25,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'CEK TIKET',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
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
                                      builder: (context) => LaporanLmb(),
                                    ),
                                  ).then((refresh) {
                                    if (refresh == true) {
                                      _initData();
                                    }
                                  });
                                },
                                child: Container(
                                  height: 80,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_lmb.svg',
                                        width: 20,
                                        height: 25,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'LAPORAN',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
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
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => LaporanLmb(),
                                  //   ),
                                  // ).then((refresh) {
                                  //   if (refresh == true) {
                                  //     _initData();
                                  //   }
                                  // });
                                },
                                child: Container(
                                  height: 80,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_bus_front.svg',
                                        width: 20,
                                        height: 25,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'ARMADA',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

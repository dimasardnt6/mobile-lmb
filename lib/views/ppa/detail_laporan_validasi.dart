import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lmb_online/models/laporan/get_laporan_validasi.dart';
import 'package:lmb_online/services/laporan/get_laporan_validasi.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class DetailLaporanValidasi extends StatefulWidget {
  const DetailLaporanValidasi({super.key});

  @override
  State<DetailLaporanValidasi> createState() => _DetailLaporanValidasiState();
}

class _DetailLaporanValidasiState extends State<DetailLaporanValidasi> {
  GetLaporanValidasi getLaporanValidasi = GetLaporanValidasi();

  List<GetLaporanValidasiData> _listDataLaporanValidasi = [];

  // Laporan Validasi
  String nm_user = "";
  String username = "";
  DateTime? _selectedDate;
  // Laporan Validasi

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();

    await _handleGetLaporanValidasi();
    await _loadUserData();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "";
      nm_user = prefs.getString('nm_user') ?? "";
    });
  }

  Future<void> _handleGetLaporanValidasi() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String level = prefs.getString('id_level') ?? "";
    final String user_id = prefs.getString('user_id') ?? "";
    final String tgl_awal =
        _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now());

    print("Tanggal Awal LAPORAN VALIDASI: $tgl_awal");
    print("User ID LAPORAN VALIDASI: $user_id");
    print("Level LAPORAN VALIDASI: $level");

    try {
      var response = await getLaporanValidasi.getLaporanValidasi(
        user_id,
        tgl_awal,
        level,
        token!,
      );

      print("Response Code LAPORAN VALIDASI: ${response.code}");

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listDataLaporanValidasi = response.data!;
        });
        print("Data Hasil Validasi: $_listDataLaporanValidasi");
      }
    } catch (e) {
      print(e);
    }
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 242, 248, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A447F),
        title: const Text(
          'Detail Laporan LMB',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Buka date picker
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });

                String onlyDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(_selectedDate!);
                debugPrint('Tanggal dipilih: $onlyDate');

                _listDataLaporanValidasi = [];
                _showLoadingDialog();
                await _handleGetLaporanValidasi();
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            },
            icon: SvgPicture.asset('assets/images/ic_calendar.svg', width: 32),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _initData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
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
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'NIK',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                username,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Nama',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                nm_user,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Tanggal',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                DateFormat(
                                  'dd-MM-yyyy',
                                ).format(_selectedDate ?? DateTime.now()),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Validasi',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // DATA
                    _listDataLaporanValidasi.isNotEmpty
                        ? Table(
                          columnWidths: const {
                            0: FractionColumnWidth(0.15), // LMB
                            1: FractionColumnWidth(0.25), // KD Armada
                            2: FractionColumnWidth(0.3), // KD Trayek
                            3: FractionColumnWidth(0.17), // Ritase
                            4: FractionColumnWidth(0.13), // Jml Pnp
                          },
                          children: <TableRow>[
                            TableRow(
                              decoration: BoxDecoration(
                                // border all
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                color: Colors.white,
                              ),
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: _buildTableCellHeader('LMB'),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: _buildTableCellHeader('Armada'),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: _buildTableCellHeader('Trayek'),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: _buildTableCellHeader('Ritase'),
                                ),
                                _buildTableCellHeader('PNP'),
                              ],
                            ),
                            for (final item in _listDataLaporanValidasi)
                              TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: _buildTableCell('${item.id_lmb}'),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: _buildTableCell('${item.kd_armada}'),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: _buildTableCell('${item.kd_trayek}'),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: _buildTableCell('${item.ritase}'),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: _buildTableCell('${item.jml_pnp}'),
                                  ),
                                ],
                              ),
                          ],
                        )
                        : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/images/ic_data_error.svg',
                                  width: 100,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Tidak ada Data Hasil Validasi',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
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

Widget _buildTableCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14),
    ),
  );
}

Widget _buildTableCellHeader(String text) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

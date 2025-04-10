import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lmb_online/models/laporan/get_laporan_lmb_model.dart';
import 'package:lmb_online/services/laporan/get_laporan_lmb.dart';
import 'package:lmb_online/views/pengemudi/detail_laporan_lmb.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class LaporanLmb extends StatefulWidget {
  const LaporanLmb({super.key});

  @override
  State<LaporanLmb> createState() => _LaporanLmbState();
}

class _LaporanLmbState extends State<LaporanLmb> {
  GetLaporanLmb getLaporanLmb = GetLaporanLmb();

  List<GetLaporanLmbData> _listDataLaporanLmB = [];

  // Laporan Pengemudi
  DateTime? _selectedDate;
  // Laporan Pengemudi

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();

    await _handleGetLaporanLmb();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleGetLaporanLmb() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? username = prefs.getString('username');
    // tanggal hari ini atau jika ada selectedDate maka pakai selectedDate
    final String tgl_awal =
        _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      var response = await getLaporanLmb.getLaporanLmb(
        username!,
        tgl_awal,
        token!,
      );

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listDataLaporanLmB = response.data!;
        });
        print("Data Total Komersil: $_listDataLaporanLmB");
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
          'Laporan LMB',
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

                _listDataLaporanLmB = [];
                _showLoadingDialog();
                await _handleGetLaporanLmb();
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              children:
                  _listDataLaporanLmB.isNotEmpty
                      ? _listDataLaporanLmB.map((item) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DetailLaporanLmb(lmbData: item),
                              ),
                            ).then((refresh) {
                              if (refresh == true) {
                                _initData();
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color:
                                    item.active == "1"
                                        ? Colors
                                            .yellow // Kuning
                                        : item.active == "2"
                                        ? const Color.fromARGB(
                                          255,
                                          167,
                                          211,
                                          151,
                                        )
                                        : item.active == "3"
                                        ? Colors.grey
                                        : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
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
                                                  item.id_lmb ?? '-',
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
                                        // Kolom Tanggal
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Tanggal',
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
                                                  'assets/images/ic_calendar.svg',
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  item.tgl_awal ?? '-',
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
                                                  item.kd_armada ?? '-',
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
                                                  item.kd_trayek ?? '-',
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
                                    if (item.nm_segment_sub == "AKAP")
                                      Padding(
                                        padding: const EdgeInsets.only(
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
                                    if (item.nm_segment_sub == "BANDARA")
                                      Padding(
                                        padding: const EdgeInsets.only(
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
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/images/ic_data_error.svg',
                                  width: 100,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Tidak ada data LMB Ritase',
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
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_online/models/laporan/get_laporan_lmb_model.dart';
import 'package:lmb_online/models/laporan/get_laporan_lmb_reguler_model.dart';
import 'package:lmb_online/models/laporan/get_laporan_lmb_ritase_model.dart';
import 'package:lmb_online/services/laporan/get_laporan_lmb_reguler.dart';
import 'package:lmb_online/services/laporan/get_laporan_lmb_ritase.dart';
import 'package:lmb_online/views/pengemudi/widget/detail_lmb_card.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class DetailLaporanLmb extends StatefulWidget {
  final GetLaporanLmbData lmbData;

  const DetailLaporanLmb({Key? key, required this.lmbData}) : super(key: key);
  @override
  State<DetailLaporanLmb> createState() => _DetailLaporanLmbState();
}

class _DetailLaporanLmbState extends State<DetailLaporanLmb> {
  GetLaporanLmbReguler getLaporanLmbReguler = GetLaporanLmbReguler();
  GetLaporanLmbRitase getLaporanLmbRitase = GetLaporanLmbRitase();

  List<GetLaporanLmbRegulerData> _listDataLmbReguler = [];
  List<GetLaporanLmbRitaseData> _listDataLmbRitase = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();

    await _handleGetLaporanLmbReguler();
    await _handleGetLaporanLmbRitase();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleGetLaporanLmbReguler() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbData.id_lmb;

    try {
      var response = await getLaporanLmbReguler.getLaporanLmbReguler(
        id_lmb!,
        token!,
      );

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listDataLmbReguler = response.data!;
        });
        print("Data LMB Reguler: $_listDataLmbReguler");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetLaporanLmbRitase() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbData.id_lmb;

    try {
      var response = await getLaporanLmbRitase.getLaporanLmbRitase(
        id_lmb!,
        token!,
      );

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listDataLmbRitase = response.data!;
        });
        print("Data LMB Ritase: $_listDataLmbRitase");
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _initData();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Detail LMB
              DetailLmbCard(
                id_lmb: widget.lmbData.id_lmb ?? '',
                kd_armada: widget.lmbData.kd_armada ?? '',
                tgl_awal: widget.lmbData.tgl_awal ?? '',
                plat_armada: widget.lmbData.plat_armada ?? '',
                nm_driver1: widget.lmbData.nm_driver1 ?? '',
                nm_driver2: widget.lmbData.nm_driver2 ?? '',
                nm_trayek: widget.lmbData.nm_trayek ?? '',
                nm_layanan: widget.lmbData.nm_layanan ?? '',
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Reguler',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children:
                            _listDataLmbReguler.isNotEmpty
                                ? _listDataLmbReguler.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 1,
                                    ),
                                    child: Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Ritase',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  item.ritase ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              height: 50,
                                              width: 1,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.nm_trayek_detail ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Jumlah Penumpang',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        item.jml_pnp ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
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
                                  );
                                }).toList()
                                : [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 20),
                                        Center(
                                          child: SvgPicture.asset(
                                            'assets/images/ic_data_error.svg',
                                            width: 100,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Tidak ada data LMB Reguler',
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
                  ],
                ),
              ),
              const SizedBox(height: 5),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Kilometer',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children:
                          _listDataLmbRitase.isNotEmpty
                              ? _listDataLmbRitase.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 1,
                                  ),
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
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
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Ritase',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                '${item.ritase}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 50,
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Waktu Mulai',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                item.waktu_awal != "0"
                                                    ? item.waktu_awal!.split(
                                                      ' ',
                                                    )[0]
                                                    : "0",
                                                style: const TextStyle(
                                                  color: Color(0xFF1A447F),
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                item.waktu_awal != "0"
                                                    ? (item.waktu_awal!
                                                                .split(' ')
                                                                .length >
                                                            1
                                                        ? item.waktu_awal!
                                                            .split(' ')[1]
                                                        : "")
                                                    : "",
                                                style: const TextStyle(
                                                  color: Color(0xFF1A447F),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'KM Mulai',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                '${item.km_awal}',
                                                style: const TextStyle(
                                                  color: Color(0xFF1A447F),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Waktu Akhir',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                item.waktu_akhir != null &&
                                                        item.waktu_akhir != "0"
                                                    ? item.waktu_akhir!.split(
                                                      ' ',
                                                    )[0]
                                                    : "0",
                                                style: const TextStyle(
                                                  color: Color(0xFF1A447F),
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                item.waktu_akhir != null &&
                                                        item.waktu_akhir != "0"
                                                    ? (item.waktu_akhir!
                                                                .split(' ')
                                                                .length >
                                                            1
                                                        ? item.waktu_akhir!
                                                            .split(' ')[1]
                                                        : "")
                                                    : "",
                                                style: const TextStyle(
                                                  color: Color(0xFF1A447F),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'KM Akhir',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                item.km_akhir != null
                                                    ? '${item.km_akhir}'
                                                    : '0',
                                                style: const TextStyle(
                                                  color: Color(0xFF1A447F),
                                                  fontSize: 11,
                                                ),
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
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),
                                      Center(
                                        child: SvgPicture.asset(
                                          'assets/images/ic_data_error.svg',
                                          width: 100,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

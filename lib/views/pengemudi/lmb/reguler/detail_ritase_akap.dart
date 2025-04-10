import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_online/models/manifest/detail_manifest_model.dart';
import 'package:lmb_online/services/manifest/get_detail_manifest.dart';
import 'package:lmb_online/services/manifest/reject_tiket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailRitaseAkap extends StatefulWidget {
  final String? ritaseValue;
  final String? idLmbValue;
  final String? bisValue;

  const DetailRitaseAkap({
    Key? key,
    required this.ritaseValue,
    required this.idLmbValue,
    required this.bisValue,
  }) : super(key: key);

  @override
  State<DetailRitaseAkap> createState() => _DetailRitaseAkapState();
}

class _DetailRitaseAkapState extends State<DetailRitaseAkap> {
  GetDetailManifest getDetailManifest = GetDetailManifest();
  RejectTiket rejectTiket = RejectTiket();

  List<DetailManifestData> _detailManifestList = [];

  @override
  void initState() {
    super.initState();
    // _showLoadingDialog();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();

    await _handleDetailManifest();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleRejectTiket(String? kodeTiket) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      var response = await rejectTiket.rejectTiket(kodeTiket!, token!);
      if (response.code == 200) {
        Navigator.pop(context);
        _dialogSuccess(header: "Hasil Reject", tittle: "${response.message}");
      } else {
        Navigator.pop(context);
        _dialogFailed(message: "$response.message", code: response.code);
        print(response.message);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleDetailManifest() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ritase = widget.ritaseValue;
    final String? id_lmb = widget.idLmbValue;
    final String? bis = widget.bisValue;
    final String? token = prefs.getString('token');

    try {
      var response = await getDetailManifest.getDetailManifest(
        id_lmb!,
        ritase!,
        bis!,
        token!,
      );

      if (response.code == 200) {
        print(response.data);
        setState(() {
          _detailManifestList = response.data!;
        });
      } else {
        print(response.message);
        Center(child: Text("Belum ada data"));
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

  // dialog success
  void _dialogDetailTiket({
    String? nama,
    String? asal,
    String? tujuan,
    String? kodeTiket,
    String? kursi,
    String? telepon,
    String? harga,
    String? active,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
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
                      Expanded(
                        child: Center(
                          child: Text(
                            'Detail Tiket',
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
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Nama',
                                style: TextStyle(color: Color(0xFF1A447F)),
                              ),
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(nama ?? ''),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Asal',
                                style: TextStyle(color: Color(0xFF1A447F)),
                              ),
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(asal ?? ''),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Tujuan',
                                style: TextStyle(color: Color(0xFF1A447F)),
                              ),
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(tujuan ?? ''),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Kode Tiket',
                                style: TextStyle(color: Color(0xFF1A447F)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Text(kodeTiket ?? ''),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  size: 25,
                                  color: Color(0xFF1A447F),
                                ),
                                onPressed: () {
                                  if (kodeTiket != null) {
                                    Clipboard.setData(
                                      ClipboardData(text: kodeTiket),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Kode Tiket berhasil disalin',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Kursi',
                                style: TextStyle(color: Color(0xFF1A447F)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(kursi ?? ''),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Harga',
                                style: TextStyle(color: Color(0xFF1A447F)),
                              ),
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                (harga != null)
                                    ? double.parse(harga).toStringAsFixed(0)
                                    : '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                'Telepon',
                                style: TextStyle(color: Color(0xFF1A447F)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(telepon ?? ''),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // redirect ke nomor telepon
                                      final url = 'tel:$telepon';
                                      // ignore: deprecated_member_use
                                      launch(url);
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/ic_phone.svg',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () {
                                      final url = 'https://wa.me/$telepon';
                                      // ignore: deprecated_member_use
                                      launch(url);
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/ic_whatsapp.svg',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            active == "1"
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.highlight_remove,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    _dialogConfirmReject(kodeTiket);
                                  },
                                )
                                : Center(child: Text('')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dialogConfirmReject(String? kodeTiket) {
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
                        'assets/images/ic_confirm.svg',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Apakah yakin ingin menghapus tiket tersebut?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // setState(() {
                                //   _kodeTiketController.clear();
                                //   _kdTiketValue = null;
                                // });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tidak',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                _showLoadingDialog();

                                Navigator.pop(context);
                                await _handleRejectTiket(kodeTiket);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: const BorderSide(
                                    color: Color(0xFF1A447F),
                                  ),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Ya',
                                  style: TextStyle(
                                    color: Color(0xFF1A447F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
      },
    );
  }

  // dialog success
  void _dialogSuccess({String? header, String? tittle}) {
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
                      const SizedBox(width: 40),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$header',
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
                          Navigator.pop(context);
                          _initData();
                        },
                      ),
                    ],
                  ),
                ),
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
                        '$tittle',
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

  // dialog gagal
  void _dialogFailed({String? message, int? code}) {
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
                      const SizedBox(width: 40),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Hasil Reject",
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
                          Navigator.pop(context);
                          _initData();
                        },
                      ),
                    ],
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 248, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A447F),
        title: Text(
          'Detail Ritase - ${widget.bisValue}',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children:
                _detailManifestList.isNotEmpty
                    ? _detailManifestList.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: GestureDetector(
                          onTap: () {
                            _dialogDetailTiket(
                              nama: item.penumpang_nama,
                              asal: item.nm_asal,
                              tujuan: item.nm_tujuan,
                              kodeTiket: item.kd_tiket,
                              kursi: item.kursi,
                              harga: item.harga,
                              telepon: item.no_hp,
                              active: item.active,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              // color: const Color.fromARGB(255, 249, 232, 151),
                              color:
                                  item.active == '2'
                                      ? const Color.fromARGB(255, 167, 211, 151)
                                      : item.active == '1'
                                      ? const Color.fromARGB(255, 249, 232, 151)
                                      : Colors.white,
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
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tiket : ${item.kd_tiket}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF1A447F,
                                                  ),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 20,
                                              color: const Color(0xFF1A447F),
                                            ),
                                            Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1A447F),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${item.nm_asal}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              '${item.nm_tujuan}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(
                                                  'Kursi : ${item.kursi}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Rp. ${(double.parse(item.harga!).toStringAsFixed(0))}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    item.active == '1'
                                        ? Text(
                                          item.nm_user ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        )
                                        : const SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList()
                    : [],
          ),
        ),
      ),
    );
  }
}

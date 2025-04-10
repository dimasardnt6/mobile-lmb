import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_online/models/laporan/cek_tiket_model.dart';
import 'package:lmb_online/services/laporan/cek_tiket.dart';
import 'package:lmb_online/views/pengemudi/widget/scan_tiket.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class CekTiket extends StatefulWidget {
  final String? kdTiketValue;

  const CekTiket({Key? key, this.kdTiketValue}) : super(key: key);

  @override
  State<CekTiket> createState() => _CekTiketState();
}

class _CekTiketState extends State<CekTiket> {
  final GlobalKey<FormState> _formKeyKdTiket = GlobalKey<FormState>();

  CekTiketPenumpang cekTiketPenumpang = CekTiketPenumpang();

  CekTiketData? _dataTiket;

  // CEK TIKET
  TextEditingController _kdTiketController = TextEditingController();
  String? _inputKdTiketValidation;

  // Jika Scan
  String? _scannedValue;
  // Jika Input Manual
  String? _kdTiketValue;

  // CEK TIKET

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();

    setState(() {
      _inputKdTiketValidation = '';
      _dataTiket = null;

      if (widget.kdTiketValue != null && widget.kdTiketValue!.isNotEmpty) {
        _kdTiketValue = widget.kdTiketValue!;
        setState(() {
          _kdTiketController.text = widget.kdTiketValue!;
        });
      } else {
        _kdTiketValue = '';
      }
    });

    if (_kdTiketValue!.isNotEmpty) {
      await _handleCekTiket();
      Navigator.pop(context);
    } else {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleCekTiket() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? kd_tiket;
    if (_scannedValue != null) {
      kd_tiket = _scannedValue;
    } else {
      kd_tiket = _kdTiketValue;
    }

    print('Token HANDLECEKTIKET: $token');
    print('Kode Tiket HANDLECEKTIKET: $kd_tiket');

    final response = await cekTiketPenumpang.cekTiketPenumpang(
      kd_tiket!,
      token!,
    );

    print('HANDLECEKTIKET RESPONSE CODE $response.code');

    if (response.code == 200) {
      setState(() {
        _dataTiket = response.data;
      });
      print('LIST HANDLECEKTIKET : $_dataTiket');
    } else {
      setState(() {
        _dataTiket = null;
      });
      Navigator.pop(context);
      _dialogFailed(message: 'Data tidak ditemukan');
    }
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 242, 248, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A447F),
        title: const Text(
          'DETAIL TIKET',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cari Tiket',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 1, 43, 80),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Form(
                                    key: _formKeyKdTiket,
                                    child: TextFormField(
                                      focusNode: FocusNode(
                                        canRequestFocus: false,
                                      ),
                                      controller: _kdTiketController,
                                      autofocus: false,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Kode Tiket',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _inputKdTiketValidation ?? "",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.42,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _inputKdTiketValidation =
                                        _kdTiketController.text.trim().isEmpty
                                            ? 'Field tidak boleh kosong'
                                            : null;
                                  });

                                  if (_inputKdTiketValidation != null) return;

                                  _showLoadingDialog();

                                  setState(() {
                                    _kdTiketValue = _kdTiketController.text;
                                  });

                                  await _handleCekTiket();

                                  if (_dataTiket != null) {
                                    Navigator.pop(context);
                                  }

                                  setState(() {
                                    _kdTiketController.clear();
                                    _kdTiketValue = '';
                                    // _dataTiket = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1A447F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  'Cari Tiket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.42,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const ScanTiket(
                                            tiketBeliValue: '3',
                                          ),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      print('HASIL SCAN CEK $result');
                                      _scannedValue = result;
                                    });
                                    _showLoadingDialog();

                                    await _handleCekTiket();

                                    if (_dataTiket != null) {
                                      Navigator.pop(context);
                                    }

                                    setState(() {
                                      _scannedValue = '';
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1A447F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  'Scan Tiket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // hasil cari tiket
              _dataTiket != null
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detail Tiket',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Asal',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.asal ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Tujuan',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.tujuan ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Kode Tiket',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.kd_tiket ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Tanggal Tiket',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.tgl_tiket ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Harga',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.harga ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Kode Armada',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.kd_armada ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'No LMB',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.id_lmb ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Petugas',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.nm_user ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        child: Text(
                                          'Waktu Validasi',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _dataTiket?.cdate ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF1A447F),
                                            fontSize: 14,
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
                    ),
                  )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

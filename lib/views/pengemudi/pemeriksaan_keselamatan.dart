import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_online/models/besafety/get_pemeriksaan_model.dart';
import 'package:lmb_online/services/besafety/get_pemeriksaan.dart';
import 'package:lmb_online/services/besafety/post_verifikasi_pemeriksaan.dart';
import 'package:lmb_online/views/pengemudi/dashboard_pengemudi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PemeriksaanKeselamatan extends StatefulWidget {
  final String id_lmb;

  const PemeriksaanKeselamatan({Key? key, required this.id_lmb})
    : super(key: key);

  @override
  State<PemeriksaanKeselamatan> createState() => _PemeriksaanKeselamatanState();
}

class _PemeriksaanKeselamatanState extends State<PemeriksaanKeselamatan> {
  final GlobalKey<FormState> _formKeyCatatan = GlobalKey<FormState>();

  final GetPemeriksaan getPemeriksaan = GetPemeriksaan();
  final PostVerifikasiPemeriksaan postVerifikasiPemeriksaan =
      PostVerifikasiPemeriksaan();

  List<GetPemeriksaanData> _listPemeriksaanData = [];
  Set<String> _selectedVerifikasiPemeriksaan = {};

  TextEditingController _catatanController = TextEditingController();
  String? _inputCatatanValidation;
  String _catatanValue = "";

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
      _catatanController.clear();
      _inputCatatanValidation = '';
      _catatanValue = '';
    });

    await _handleGetPemeriksaan();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleGetPemeriksaan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_level = prefs.getString('id_level');

    try {
      var response = await getPemeriksaan.getPemeriksaan(id_level!, token!);

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listPemeriksaanData = response.data!;
        });
        print("Data pemeriksaan: $_listPemeriksaanData");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mendapatkan pemeriksaan data"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePostVerifikasiPemeriksaan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_user = prefs.getString('user_id');
    final String? id_lmb_value = '${widget.id_lmb}';
    final String? respon_pemeriksaan = _selectedVerifikasiPemeriksaan.join(',');
    final String? keterangan = _catatanValue;

    print('${widget.id_lmb}');
    // print('RESPON PEMERIKSAAN ID USER $id_user');
    // print('RESPON PEMERIKSAAN KETERANGAN $keterangan');
    // print('RESPON PEMERIKSAAN $respon_pemeriksaan');

    try {
      var response = await postVerifikasiPemeriksaan.postVerifikasiPemeriksaan(
        id_user!,
        respon_pemeriksaan!,
        keterangan!,
        id_lmb_value!,
        token!,
      );

      if (response.code == 201) {
        _dialogSuccess(
          header: "Verifikasi Pemeriksaan",
          tittle: response.message,
        );
      } else {
        _dialogFailed(response.message, response.code);
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DashboardPengemudi(),
                            ),
                          );
                          // _initData();
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardPengemudi(),
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
                            'Gagal Verifikasi',
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
                      const SizedBox(height: 20),
                      Container(
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
                              style: const TextStyle(
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
      body: RefreshIndicator(
        onRefresh: () async {
          _initData();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 50,
                  bottom: 20,
                  right: 20,
                  left: 20,
                ),
                color: const Color(0xFF1A447F),
                child: Text(
                  'Pemeriksaan Keselamatan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 10),
              // Checklist
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children:
                      _listPemeriksaanData.isNotEmpty
                          ? _listPemeriksaanData.map((item) {
                            final id = item.id_pemeriksaan;
                            final isChecked = _selectedVerifikasiPemeriksaan
                                .contains(id);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.7,
                                        child: Text(
                                          '${item.pernyataan_pemeriksaan}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 1),
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedVerifikasiPemeriksaan
                                                  .add(id!);
                                            } else {
                                              _selectedVerifikasiPemeriksaan
                                                  .remove(id);
                                            }

                                            print('ID YANG DIPILIH : $id');
                                            print(
                                              'YANG DIPILIH : $_selectedVerifikasiPemeriksaan',
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList()
                          : [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
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
                                  const Text(
                                    'Tidak ada data pemeriksaan',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                ),
              ),
              const SizedBox(height: 10),
              // Simpan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color.fromARGB(255, 1, 43, 80),
                        ),
                      ),
                      child: Form(
                        key: _formKeyCatatan,
                        child: TextField(
                          controller: _catatanController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
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
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // button simpan
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _inputCatatanValidation =
                                _catatanController.text.trim().isEmpty
                                    ? 'Field tidak boleh kosong'
                                    : null;
                          });

                          if (_inputCatatanValidation != null) return;

                          setState(() {
                            _catatanValue = _catatanController.text;
                          });

                          await _handlePostVerifikasiPemeriksaan();

                          setState(() {
                            _selectedVerifikasiPemeriksaan = {};
                            _catatanValue = '';
                            _inputCatatanValidation = '';
                            _catatanController.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A447F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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

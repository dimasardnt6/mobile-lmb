import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lmb_online/models/jadwal/post_jadwal_model.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';
import 'package:lmb_online/models/lmb/lmb_ritase_list_model.dart';
import 'package:lmb_online/models/manifest/get_manifest_total_model.dart';
import 'package:lmb_online/services/akap/validation_tiket_akap.dart';
import 'package:lmb_online/services/jadwal/post_jadwal.dart';
import 'package:lmb_online/services/lmb/delete_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/get_lmb_ritase_list.dart';
import 'package:lmb_online/services/lmb/post_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/put_lmb_ritase.dart';
import 'package:lmb_online/services/manifest/delete_manifest.dart';
import 'package:lmb_online/services/manifest/get_manifest_total.dart';
import 'package:lmb_online/services/manifest/post_manifest.dart';
import 'package:lmb_online/views/pengemudi/cek_tiket.dart';
import 'package:lmb_online/views/pengemudi/lmb/reguler/detail_ritase_akap.dart';
import 'package:lmb_online/views/pengemudi/widget/detail_lmb_card.dart';
import 'package:lmb_online/views/pengemudi/widget/scan_tiket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TiketAkap extends StatefulWidget {
  final LmbDriverNewData lmbDriverNew;

  const TiketAkap({Key? key, required this.lmbDriverNew}) : super(key: key);

  @override
  State<TiketAkap> createState() => _TiketAkapState();
}

class _TiketAkapState extends State<TiketAkap> {
  final GlobalKey<FormState> _formKeyKm = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyCatatan = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKmMulai = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKmAkhir = GlobalKey<FormState>();

  ValidationTiketAkap validationTiketAkap = ValidationTiketAkap();
  GetManifestTotal get_manifest_total = GetManifestTotal();
  PostManifest postManifest = PostManifest();
  GetLmbRitaseList getLmbRitaseList = GetLmbRitaseList();
  PostLmbRitase postLmbRitase = PostLmbRitase();
  PutLmbRitase putLmbRitase = PutLmbRitase();
  DeleteLmbRitase deleteLmbRitase = DeleteLmbRitase();
  DeleteManifest deleteManifest = DeleteManifest();

  final GlobalKey<FormState> _formKeyKdTiket = GlobalKey<FormState>();

  PostJadwal post_jadwal = PostJadwal();
  List<GetManifestTotalData> _manifestTotalData = [];
  List<PostJadwalData> _listJadwal = [];
  List<LmbRitaseListData> _lmbRitaseDataList = [];

  TextEditingController _kodeTiketController = TextEditingController();
  TextEditingController _kmAwalController = TextEditingController();
  TextEditingController _kmAkhirController = TextEditingController();
  TextEditingController _catatanController = TextEditingController();
  TextEditingController _kmAwalEditController = TextEditingController();
  TextEditingController _kmAkhirEditController = TextEditingController();

  // SCAN
  String _tiketBeli = '0';
  String _isTrayekValid = "0";
  int value_tiket = 1;
  int _ritase = 1;

  // Jika Scan
  // String? _scannedValue;
  // Jika Input Manual
  String? _inputKdTiketValidation;
  String? _kdTiketValue;
  // END SCAN

  // PILIH JADWAL
  String _selectedKdBis = '';
  String _valueKdBis = '';
  // END PILIH JADWAL

  // Cek Ritase Saat ini
  String _statusRitase = "";
  // End Cek Ritase Saat ini

  // Mulai dan Akhiri Ritase
  String? _inputKmValidation;
  String? _inputCatatanValidation;
  String _kmAwalValue = "";
  String _kmAkhirValue = "";
  String _catatanValue = "";
  // End Mulai dan Akhiri Ritase

  // Edit Riwayat RITASE
  String? _inputKmAwalValidation;
  String? _inputKmAkhirValidation;
  String _kmAwalEditValue = "";
  String _kmAkhirEditValue = "";
  // Edit Riwayat RITASE

  String? _verifikasi = '0';

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
      _manifestTotalData = [];
      _lmbRitaseDataList = [];
    });

    await _handleGetManifestTotal();
    await _handleGetLmbRitaseList();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Fungsi untuk memanggil halaman scan tiket
  Future<void> _handleScanTiket() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanTiket(tiketBeliValue: _tiketBeli),
      ),
    );
    if (result != null) {
      setState(() {
        _kdTiketValue = result;
      });
      print('VALUE KD TIKET : $_kdTiketValue');
      _validationTiket();
    }
  }

  void _addRitase() {
    if (_statusRitase == "2") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tidak bisa menambah ritase, akhiri dulu ritase saat ini",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _ritase++;
    });
  }

  void _subRitase() {
    if (_statusRitase == "2") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tidak bisa mengurangi ritase, akhiri dulu ritase saat ini",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (_ritase > 1) {
        _ritase--;
      }
    });
  }

  Future<void> _handlePutLmbRitase(String id_lmb_ritase) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String id_lmb_ritase_value = id_lmb_ritase;
    final String km_awal = _kmAwalEditValue;
    final String km_akhir = _kmAkhirEditValue;

    try {
      var response = await putLmbRitase.putLmbRitase(
        id_lmb!,
        id_lmb_ritase_value,
        km_awal,
        km_akhir,
        token!,
      );

      if (response.code == 201) {
        Navigator.pop(context);
        _dialogSuccess(
          header: "Edit Ritase",
          tittle: response.message,
          action: "edit ritase",
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code, action: 'edit ritase');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleDeleteLmbRitase(String id_lmb_ritase) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String id_lmb_ritase_value = id_lmb_ritase;

    print('id_lmb delete: $id_lmb');
    print('id_lmb_ritase delete: $id_lmb');

    try {
      var response = await deleteLmbRitase.deleteLmbRitase(
        id_lmb!,
        id_lmb_ritase_value,
        token!,
      );

      if (response.code == 200) {
        Navigator.pop(context);
        _dialogSuccess(
          header: "Delete Ritase",
          tittle: response.message,
          action: "delete ritase",
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code, action: 'delete ritase');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleDeleteManifest(
    String bis,
    String ritase,
    String? _verifikasi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String bis_value = bis;
    final String ritase_value = ritase;
    final String verifikasi = _verifikasi!;

    try {
      var response = await deleteManifest.deleteManifest(
        id_lmb!,
        bis_value,
        ritase_value,
        verifikasi,
        token!,
      );

      if (response.code == 200) {
        _manifestTotalData.removeWhere(
          (item) => item.ritase == ritase_value && item.bis == bis_value,
        );
        Navigator.pop(context);
        _dialogSuccess(
          bis: bis_value,
          ritase: ritase_value,
          header: "Delete Data Manifest",
          tittle: response.message,
          action: "delete manifest",
        );
      } else if (response.code == 100) {
        Navigator.pop(context);
        _dialogKonfirmasiDeleteVerifikasiManifest(
          bis: bis_value,
          ritase: ritase_value,
          tittle: response.message,
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(
          response.message,
          response.code,
          action: 'delete manifest',
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handlePostLmbRitase(String status, String kmValue) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String? ritase = '$_ritase';
    final String? cuser = prefs.getString('user_id');
    final String? km = kmValue;
    // catatan bisa kosong
    final String? catatan = _catatanValue;

    // Gunakan parameter status yang dikirim dari tombol
    final String? level = prefs.getString('id_level');

    print('id_lmb: $id_lmb');
    print('cuser: $cuser');
    print('ritase: $ritase');
    print('token: $token');
    print('km: $km');
    // print tipe data km
    print('km type: ${km.runtimeType}');
    print('status: $status');
    print('level: $level');
    print('catatan: $catatan');

    try {
      var response = await postLmbRitase.postLmbRitase(
        id_lmb!,
        ritase!,
        status,
        km!,
        level!,
        cuser!,
        catatan!,
        token!,
      );

      if (response.code == 201 && status == "2") {
        Navigator.pop(context);
        _dialogSuccess(
          header: "Mulai Ritase",
          tittle: "Berhasil Memulai Ritase $_ritase",
          action: "mulai ritase",
        );
      } else if (response.code == 201 && status == "3") {
        Navigator.pop(context);
        _dialogSuccess(
          header: "Akhiri Ritase",
          tittle: "Berhasil Mengakhiri Ritase $_ritase",
          action: "akhiri ritase",
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code, action: 'ritase');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetLmbRitaseList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;

    print('id_lmb : $id_lmb');
    print('token : $token');

    try {
      var response = await getLmbRitaseList.getLmbRitaseList(id_lmb!, token!);

      if (response.code == 200) {
        setState(() {
          _lmbRitaseDataList = response.data!;
          _kmAkhirValue = response.data![0].km_akhir!;
          _kmAwalValue = response.data![0].km_awal!;

          // Jika status == "3", ritase ditambah 1, jika tidak, gunakan ritase saat ini
          _ritase =
              (response.data![0].status == "3")
                  ? int.parse(response.data![0].ritase!) + 1
                  : int.parse(response.data![0].ritase!);

          // Jika ritase == 0, jadikan ritase = 1
          if (_ritase == 0) {
            _ritase = 1;
          }
          _statusRitase = response.data![0].status!;

          print("status ritase : $_statusRitase");
        });
      } else {
        print(response.message);
        setState(() {
          _statusRitase = "0";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetManifestTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;

    try {
      var response = await get_manifest_total.getManifestTotal(id_lmb!, token!);

      if (response.code == 200 && response.data != null) {
        setState(() {
          _valueKdBis = response.data!.first.bis!;
          _manifestTotalData = response.data!;
        });
        print("Data Total Komersil: $_manifestTotalData");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handlePostManifest() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String? ritase = '$_ritase';
    final String? bis = _selectedKdBis;
    final String? tanggal = widget.lmbDriverNew.tgl_awal;
    final String? kd_trayek = widget.lmbDriverNew.kd_trayek_detail;

    print('id_lmb: $id_lmb');
    print('ritase: $ritase');
    print('bis: $bis');
    print('tanggal: $tanggal');
    print('kd_trayek: $kd_trayek');
    print('token: $token');

    try {
      var response = await postManifest.postManifest(
        id_lmb!,
        ritase!,
        bis!,
        tanggal!,
        kd_trayek!,
        token!,
      );

      if (response.code == 201) {
        // Navigator.pop(context);
        _dialogSuccess(
          header: "Berhasil tambah manifest",
          tittle: response.message,
          action: "tambah manifest",
        );
        // _initData();
      } else {
        // Navigator.pop(context);
        _dialogFailed(
          response.message,
          response.code,
          action: "tambah manifest",
        );
        // _initData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleValidation() async {
    await _validationTiket();
  }

  // Scan tiket validation Post method
  Future<void> _validationTiket() async {
    final prefs = await SharedPreferences.getInstance();

    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String? id_trayek = widget.lmbDriverNew.id_trayek;
    final String? id_trayek_detail = widget.lmbDriverNew.id_trayek_detail;
    final String? kd_tiket = _kdTiketValue;
    final String? cuser = prefs.getString('user_id');
    final String? tgl_lmb = widget.lmbDriverNew.tgl_awal;
    final String? ritase = '$_ritase';
    final String? tiket_beli = _tiketBeli;
    final String? isTrayekValid = _isTrayekValid;
    final String? token = prefs.getString('token');

    print('id_lmb: $id_lmb');
    print('id_trayek: $id_trayek');
    print('id_trayek_detail: $id_trayek_detail');
    print('kd_tiket: $kd_tiket');
    print('kode_tiket_manual : $_kdTiketValue');
    print('cuser: $cuser');
    print('tgl_lmb: $tgl_lmb');
    print('ritase: $ritase');
    print('tiket_beli: $tiket_beli');
    print('isTrayekValid: $isTrayekValid');
    print('token: $token');
    print('hasil scan : $_kdTiketValue');

    try {
      var response = await validationTiketAkap.validationTiketAkap(
        id_lmb!,
        id_trayek!,
        id_trayek_detail!,
        kd_tiket!,
        cuser!,
        tgl_lmb!,
        ritase!,
        tiket_beli!,
        isTrayekValid!,
        token!,
      );

      print(response);

      if (response.code == 201) {
        _dialogSuccess(
          header: "Hasil Validasi",
          tittle: "Tiket Berhasil Divalidasi",
          action: "validasi tiket",
        );
        _initData();
      } else if (response.code == 433) {
        _dialogValidation();
        _initData();
      } else {
        _dialogFailed(
          response.message,
          response.code,
          action: "validasi tiket",
        );
        _initData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handlePostJadwal() async {
    // dapatkan token
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? kd_trayek = widget.lmbDriverNew.kd_trayek_detail;
    final String? tanggal = widget.lmbDriverNew.tgl_awal;
    final String? jenis = widget.lmbDriverNew.kode_layanan;
    final String? kd_segmen = widget.lmbDriverNew.nm_segment_sub;

    print('kd_trayek: $kd_trayek');
    print('tanggal: $tanggal');
    print('jenis: $jenis');
    print('kd_segmen: $kd_segmen');
    print('token: $token');

    try {
      var response = await post_jadwal.postJadwal(
        kd_trayek!,
        tanggal!,
        jenis!,
        kd_segmen!,
        token!,
      );

      if (response.code == 200) {
        setState(() {
          _listJadwal = response.data!;
        });
      } else {
        print(response.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi Kesalahan saat mengambil data jadwal"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDialogMulaiRitase() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                                'Mulai Ritase - $_ritase',
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
                                _inputKmValidation = "";
                                // _kmAwalValue = "";
                                // _kmAkhirValue = "";
                                // _kmAwalController.clear();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Input KM',
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
                                    key: _formKeyKm,
                                    child: TextFormField(
                                      controller: _kmAwalController,
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
                                        hintText:
                                            'km ritase terakhir : $_kmAkhirValue',
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

                                const SizedBox(height: 5),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // setState(() {
                                      //   _kmAwalValue = _kmAwalController.text;
                                      // });
                                      setStateDialog(() {
                                        if (_kmAwalController.text
                                            .trim()
                                            .isEmpty) {
                                          _inputKmValidation =
                                              'Field tidak boleh kosong';
                                        } else {
                                          _inputKmValidation = null;
                                        }
                                      });

                                      if (_inputKmValidation != null) return;

                                      await _handlePostLmbRitase(
                                        "2",
                                        _kmAwalController.text,
                                      );

                                      setState(() {
                                        _inputKmValidation = "";
                                        _kmAwalValue = "";
                                        _kmAwalController.clear();
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
            );
          },
        );
      },
    );
  }

  void _showDialogAkhiriRitase() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                                'Akhiri Ritase - $_ritase',
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
                                _inputKmValidation = "";
                                _inputCatatanValidation = "";
                                // _kmAwalValue = "";
                                // _kmAkhirValue = "";
                                // _kmAkhirController.clear();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Input KM',
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
                                    key: _formKeyKm,
                                    child: TextField(
                                      controller: _kmAkhirController,
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
                                        hintText:
                                            'km ritase terakhir : $_kmAwalValue',
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
                                const SizedBox(height: 5),
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
                                    key: _formKeyCatatan,
                                    child: TextField(
                                      controller: _catatanController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(
                                          left: 20,
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
                                            _kmAkhirController.text
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
                                        // _kmAkhirValue = _kmAkhirController.text;
                                        _catatanValue = _catatanController.text;
                                      });

                                      await _handlePostLmbRitase(
                                        "3",
                                        _kmAkhirController.text,
                                      );

                                      setState(() {
                                        _inputKmValidation = "";
                                        _inputCatatanValidation = "";
                                        _kmAwalValue = "";
                                        _kmAkhirValue = "";
                                        _kmAkhirController.clear();
                                        _catatanValue = "";
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
            );
          },
        );
      },
    );
  }

  void _showDialogRiwayatRitase() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Riwayat Ritase',
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
                            _lmbRitaseDataList = [];
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child:
                      _lmbRitaseDataList.isNotEmpty
                          ? ListView.builder(
                            itemCount: _lmbRitaseDataList.length,
                            itemBuilder: (context, index) {
                              final item = _lmbRitaseDataList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _kmAwalEditController.text = item.km_awal!;
                                    _kmAkhirEditController.text =
                                        item.km_akhir!;
                                  });
                                  _showDialogEditRiwayatRitase(
                                    item.ritase,
                                    item.id_lmb_ritase,
                                    item.km_awal,
                                    item.km_akhir,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2.5,
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
                                                '${item.km_akhir}',
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
                                ),
                              );
                            },
                          )
                          : const Center(
                            child: Text('Belum Ada Riwayat Ritase'),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialogEditRiwayatRitase(
    String? ritase,
    String? id_lmb_ritase,
    String? km_awal,
    String? km_akhir,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                                'Edit Data',
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
                                _inputKmAwalValidation = '';
                                _inputKmAkhirValidation = '';
                                _kmAwalEditController.clear();
                                _kmAkhirEditController.clear();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KM Mulai',
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
                                    key: _formKeyKmMulai,
                                    child: TextFormField(
                                      controller: _kmAwalEditController,
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
                                        hintText: 'km awal : $km_awal',
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
                                    _inputKmAwalValidation ?? "",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  'KM Akhir',
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
                                    key: _formKeyKmAkhir,
                                    child: TextFormField(
                                      controller: _kmAkhirEditController,
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
                                        hintText: 'km akhir : $km_akhir',
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
                                    _inputKmAkhirValidation ?? "",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.42,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // await _handlePostLmbRitase(
                                          //   "2",
                                          //   _kmAwalController.text,
                                          // );

                                          // setState(() {
                                          //   _inputKmValidation = "";
                                          //   _kmAwalValue = "";
                                          //   _kmAwalController.clear();
                                          // });
                                          Navigator.pop(context);
                                          _showDialogKonfirmasiHapus(
                                            ritase,
                                            id_lmb_ritase,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.42,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          setStateDialog(() {
                                            _inputKmAwalValidation =
                                                _kmAwalEditController.text
                                                        .trim()
                                                        .isEmpty
                                                    ? 'Field tidak boleh kosong'
                                                    : null;

                                            _inputKmAkhirValidation =
                                                _kmAkhirEditController.text
                                                        .trim()
                                                        .isEmpty
                                                    ? 'Field tidak boleh kosong'
                                                    : null;
                                          });

                                          if (_inputKmAwalValidation != null ||
                                              _inputKmAkhirValidation != null)
                                            return;

                                          setState(() {
                                            _kmAwalEditValue =
                                                _kmAwalEditController.text;
                                            _kmAkhirEditValue =
                                                _kmAkhirEditController.text;
                                          });

                                          await _handlePutLmbRitase(
                                            id_lmb_ritase!,
                                          );

                                          setState(() {
                                            _inputKmAwalValidation = "";
                                            _inputKmAkhirValidation = "";
                                            _kmAwalEditValue = "";
                                            _kmAkhirEditValue = "";
                                            _kmAwalEditController.clear();
                                            _kmAkhirEditController.clear();
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
                              ],
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

  void _showDialogKonfirmasiHapus(String? ritase, String? id_lmb_ritase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_confirm.svg',
                                  width: 90,
                                  height: 90,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Apakah Anda Yakin Ingin Menghapus Data Kilometer Ritase ke $ritase ?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _inputKmAwalValidation = "";
                                            _inputKmAkhirValidation = "";
                                            _kmAwalEditValue = "";
                                            _kmAkhirEditValue = "";
                                            _kmAwalEditController.clear();
                                            _kmAkhirEditController.clear();
                                          });
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.red,
                                            ),
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
                                          await _handleDeleteLmbRitase(
                                            id_lmb_ritase!,
                                          );

                                          setState(() {
                                            _inputKmAwalValidation = "";
                                            _inputKmAkhirValidation = "";
                                            _kmAwalEditValue = "";
                                            _kmAkhirEditValue = "";
                                            _kmAwalEditController.clear();
                                            _kmAkhirEditController.clear();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDialogKonfirmasiHapusManifest(
    String? bis,
    String? ritase,
    String? active,
    String? _verifikasi,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_confirm.svg',
                                  width: 90,
                                  height: 90,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Apakah Anda Yakin Ingin Menghapus Data Manifest?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          print('konfirmasi delete $active');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.red,
                                            ),
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
                                          await _handleDeleteManifest(
                                            bis!,
                                            ritase!,
                                            _verifikasi = "0",
                                          );
                                          print('konfirmasi delete $active');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDialogPilihJadwal() {
    // Controller untuk search bar
    TextEditingController _searchController = TextEditingController();
    // Inisialisasi filtered data dengan semua data awal
    List<PostJadwalData> _filteredJadwal = List.from(_listJadwal);

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
                                'Pilih Kode Armada',
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
                                _selectedKdBis = "";
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
                                  hintText: 'Cari Data ...',
                                ),
                                onChanged: (value) {
                                  String query = value.toLowerCase();
                                  setState(() {
                                    if (query.isNotEmpty) {
                                      _filteredJadwal =
                                          _listJadwal.where((item) {
                                            return item.bis!
                                                    .toLowerCase()
                                                    .contains(query) ||
                                                item.kd_trayek!
                                                    .toLowerCase()
                                                    .contains(query);
                                          }).toList();
                                    } else {
                                      _filteredJadwal = List.from(_listJadwal);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child:
                          _filteredJadwal.isNotEmpty
                              ? ListView.builder(
                                itemCount: _filteredJadwal.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredJadwal[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedKdBis = item.bis!;
                                          print(
                                            'VALUE NEW ARMADA $_selectedKdBis',
                                          );
                                        });
                                        Navigator.pop(context);
                                        _initData();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              // ignore: deprecated_member_use
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Bis',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF1A447F,
                                                          ),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      Text(
                                                        'Tujuan',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF1A447F,
                                                          ),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            item.bis!,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          // divider
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Container(
                                                            width: 1,
                                                            height: 20,
                                                            color: Colors.grey,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            item.tanggal!,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            (item.jam1 !=
                                                                        null &&
                                                                    item.jam1!.length >=
                                                                        5)
                                                                ? item.jam1!
                                                                    .substring(
                                                                      0,
                                                                      5,
                                                                    )
                                                                : '-',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        item.kd_trayek!,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                    ),
                                  );
                                },
                              )
                              : const Center(
                                child: Text('Data tidak ditemukan'),
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

  void _dialogKonfirmasiDeleteVerifikasiManifest({
    String? bis,
    String? ritase,
    String? tittle,
  }) {
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
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$tittle',
                        textAlign: TextAlign.center,
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
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              child: const Text(
                                'Tidak',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _handleDeleteManifest(
                                  bis!,
                                  ritase!,
                                  _verifikasi = "1",
                                );
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
                              child: const Text(
                                'Ya',
                                style: TextStyle(
                                  color: Color(0xFF1A447F),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

  // dialog validation
  void _dialogValidation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Hasil Validasi',
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
                                _kodeTiketController.clear();
                                _kdTiketValue = null;
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_data_error.svg',
                                  width: 90,
                                  height: 90,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Trayek Tiket Tidak Sesuai',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Apakah Anda Akan Tetap Melanjutkan?',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
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
                                          setState(() {
                                            _kodeTiketController.clear();
                                            _kdTiketValue = null;
                                          });
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.red,
                                            ),
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
                                        onPressed: () {
                                          setState(() {
                                            _isTrayekValid = '1';
                                          });
                                          Navigator.pop(context);
                                          _handleValidation();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
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
                                const SizedBox(height: 20),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _kdTiketValue = null;
                                      });
                                      Navigator.pop(context);
                                      _handleScanTiket();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1A447F),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: const Text(
                                      'Scan',
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
            );
          },
        );
      },
    );
  }

  // dialog input kode manual
  void _inputKodeTiket() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Input Kode Tiket',
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
                              // _showLoadingDialog();
                              setStateDialog(() {
                                _inputKdTiketValidation = "";
                                _kodeTiketController.clear();
                                _tiketBeli = '0';
                                value_tiket = 1;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Tiket',
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
                                      groupValue: value_tiket,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          _tiketBeli = '1';
                                          value_tiket = value!;
                                        });
                                        print('Tiket Beli damri: $_tiketBeli');
                                      },
                                    ),
                                    const Text(
                                      'Damri',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Radio<int>(
                                      value: 2,
                                      groupValue: value_tiket,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          _tiketBeli = '2';
                                          value_tiket = value!;
                                        });
                                        print('Tiket Beli ap2: $_tiketBeli');
                                      },
                                    ),
                                    const Text(
                                      'AP2',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
                                    key: _formKeyKdTiket,
                                    child: TextField(
                                      controller: _kodeTiketController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(
                                          left: 20,
                                        ),
                                        hintText: 'Kode Tiket',
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
                                    _inputKdTiketValidation ?? "",
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
                                      setState(() {
                                        _kdTiketValue =
                                            _kodeTiketController.text;
                                      });
                                      setStateDialog(() {
                                        if (_kodeTiketController.text
                                            .trim()
                                            .isEmpty) {
                                          _inputKdTiketValidation =
                                              'Field tidak boleh kosong';
                                        } else {
                                          _inputKdTiketValidation = null;
                                        }
                                      });

                                      if (_inputKdTiketValidation != null)
                                        return;

                                      Navigator.pop(context);
                                      await _handleValidation();

                                      print('VALUE KD TIKET : $_kdTiketValue');

                                      setState(() {
                                        _inputKdTiketValidation = "";
                                        _tiketBeli = '0';
                                        _kodeTiketController.clear();
                                        value_tiket = 1;
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
                              ],
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
  void _dialogSuccess({
    String? header,
    String? bis,
    String? ritase,
    String? tittle,
    String? action,
  }) {
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
                            textAlign: TextAlign.center,
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
                            _kodeTiketController.clear();
                            _kdTiketValue = null;
                          });
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _kodeTiketController.clear();
                              _kdTiketValue = null;
                            });
                            if (action != "validasi tiket") {
                              Navigator.pop(context);
                              _initData();
                            } else {
                              Navigator.pop(context);
                              _handleScanTiket();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A447F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            action != "validasi tiket" ? 'Tutup' : 'Scan',
                            style: const TextStyle(
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
              ],
            ),
          ),
        );
      },
    );
  }

  // dialog gagal
  void _dialogFailed(String? message, int? code, {required String action}) {
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
                            action == 'validasi tiket'
                                ? 'Hasil Validasi'
                                : 'Gagal',
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
                            _kodeTiketController.clear();
                            _kdTiketValue = null;
                          });
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
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            print(_tiketBeli);
                            Navigator.pop(context);
                            if (action == 'validasi tiket') {
                              if (code == 434) {
                                // Jika code 434, navigasikan ke halaman CekTiket
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CekTiket(
                                          kdTiketValue: _kdTiketValue,
                                        ),
                                  ),
                                ).then((refresh) {
                                  if (refresh == true) {
                                    _initData();
                                  }
                                });
                              } else if (code == 433) {
                                // Jika code 433, tampilkan dialog validasi
                                _dialogValidation();
                              } else {
                                // Kondisi default untuk action 'validasi tiket'
                                _handleScanTiket();
                              }
                            } else {
                              _initData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A447F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              action == 'validasi tiket'
                                  ? code == 434
                                      ? 'Lihat Tiket'
                                      : code == 433
                                      ? 'Scan'
                                      : 'Scan'
                                  : 'Tutup',
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
              const SizedBox(height: 10),
              // Detail LMB
              DetailLmbCard(
                id_lmb: widget.lmbDriverNew.id_lmb ?? '',
                kd_armada: widget.lmbDriverNew.kd_armada ?? '',
                tgl_awal: widget.lmbDriverNew.tgl_awal ?? '',
                plat_armada: widget.lmbDriverNew.plat_armada ?? '',
                nm_driver1: widget.lmbDriverNew.nm_driver1 ?? '',
                nm_driver2: widget.lmbDriverNew.nm_driver2 ?? '',
                nm_trayek: widget.lmbDriverNew.nm_trayek ?? '',
                nm_layanan: widget.lmbDriverNew.nm_layanan ?? '',
              ),
              Card(
                // input ritase
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal Manifest E-Ticketing',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: const Color.fromARGB(255, 1, 43, 80),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                _showLoadingDialog();

                                await _handlePostJadwal();

                                Navigator.pop(context);

                                if (_listJadwal.isNotEmpty) {
                                  _showDialogPilihJadwal();
                                }
                              },
                              child: Container(
                                height: 50,
                                // rounded and border
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 1, 43, 80),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: Text(
                                    _selectedKdBis.isNotEmpty
                                        ? _selectedKdBis
                                        : (_valueKdBis.isNotEmpty
                                            ? _valueKdBis
                                            : 'Pilih Jadwal'),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          // button simpan
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: const Color.fromARGB(255, 1, 43, 80),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                await _handlePostManifest();

                                setState(() {
                                  _selectedKdBis = "";
                                  _valueKdBis = "";
                                });
                              },
                              child: Container(
                                height: 50,
                                // rounded and border
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: const Color(0xFF1A447F),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: Text(
                                    "Simpan",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
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
                    ],
                  ),
                ),
              ),
              Card(
                // input ritase
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Input Ritase',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Ritase',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // button minus
                            GestureDetector(
                              onTap: _subRitase,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // jumlah ritase
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF1A447F),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  // hasil sesuai dengan _ritase
                                  '$_ritase',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // button plus
                            GestureDetector(
                              onTap: _addRitase,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A447F),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aktifitas Ritase',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 50,
                              width: 220,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_statusRitase == "0" ||
                                      _statusRitase == "1" ||
                                      _statusRitase == "3") {
                                    setState(() {
                                      final parsed = double.tryParse(
                                        _kmAkhirValue,
                                      );
                                      if (parsed != null) {
                                        String stringValue = parsed.toString();
                                        stringValue = stringValue.replaceAll(
                                          RegExp(r'\.?0+$'),
                                          '',
                                        );
                                        _kmAkhirValue = stringValue;
                                      }
                                    });
                                    print('km akhir $_kmAkhirValue');
                                    _showDialogMulaiRitase();
                                  } else if (_statusRitase == "2") {
                                    setState(() {
                                      final parsed = double.tryParse(
                                        _kmAwalValue,
                                      );
                                      if (parsed != null) {
                                        String stringValue = parsed.toString();
                                        stringValue = stringValue.replaceAll(
                                          RegExp(r'\.?0+$'),
                                          '',
                                        );
                                        _kmAwalValue = stringValue;
                                      }
                                    });
                                    print('km awal: $_kmAwalValue');
                                    _showDialogAkhiriRitase();
                                  }
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _statusRitase == "0" ||
                                              _statusRitase == "1" ||
                                              _statusRitase == "3"
                                          ? const Color(0xFF1A447F)
                                          : _statusRitase == "2"
                                          ? Colors.orange
                                          : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _statusRitase == "0" ||
                                            _statusRitase == "1" ||
                                            _statusRitase == "3"
                                        ? 'Mulai Ritase - $_ritase'
                                        : _statusRitase == "2"
                                        ? 'Akhiri Ritase - $_ritase'
                                        : 'Ritase',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Riwayat Ritase
                            GestureDetector(
                              onTap: () async {
                                await _handleGetLmbRitaseList();
                                _showDialogRiwayatRitase();
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10A19D),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Icon(Icons.menu, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Input Reguler',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Card 1
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tiketBeli = '1';
                                });

                                _handleScanTiket();
                              },
                              child: Container(
                                width: 100,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF1A447F),
                                    width: 1,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        color: Color(0xFF1A447F),
                                        size: 50,
                                      ),
                                      SizedBox(height: 10),
                                      Expanded(
                                        child: Text(
                                          'Scan Tiket',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Card 2
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tiketBeli = '0';
                                });
                                _inputKodeTiket();
                              },
                              child: Container(
                                width: 100,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF1A447F),
                                    width: 1,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        color: Color(0xFF1A447F),
                                        size: 50,
                                      ),
                                      SizedBox(height: 10),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Input Kode Tiket',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
              ),
              const SizedBox(height: 10),
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
                            _manifestTotalData.isNotEmpty
                                ? _manifestTotalData.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 1,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => DetailRitaseAkap(
                                                  ritaseValue: item.ritase,
                                                  idLmbValue:
                                                      widget
                                                          .lmbDriverNew
                                                          .id_lmb,
                                                  bisValue: item.bis,
                                                ),
                                          ),
                                        ).then((refresh) {
                                          if (refresh == true) {
                                            _initData();
                                          }
                                        });
                                      },
                                      child: Card(
                                        color:
                                            item.active == '2'
                                                ? const Color.fromARGB(
                                                  255,
                                                  167,
                                                  211,
                                                  151,
                                                )
                                                : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    '${item.ritase}',
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
                                                      '${item.bis}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'Tervalidasi : ${item.total_validasi}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'Belum Validasi : ${int.parse(item.total_manifest ?? '0') - int.parse(item.total_validasi ?? '0')}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Text(
                                                        'Total PNP',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        '${item.total_manifest}',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _showDialogKonfirmasiHapusManifest(
                                                        item.bis,
                                                        item.ritase,
                                                        item.active,
                                                        _verifikasi = "0",
                                                      );
                                                      print(
                                                        'Hapus Manifest ${item.bis} - ${item.ritase} - ${item.active}}',
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList()
                                : [
                                  const Center(
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
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
  }
}

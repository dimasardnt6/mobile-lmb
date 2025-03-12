import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lmb_online/models/armada/list_armada_by_lmb_model.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';
import 'package:lmb_online/models/lmb/lmb_ritase_list_model.dart';
import 'package:lmb_online/models/operasi/reguler_komersil/komersil_total_model.dart';
import 'package:lmb_online/services/ap2/validation_tiket_ap2.dart';
import 'package:lmb_online/services/armada/get_list_armada_by_lmb.dart';
import 'package:lmb_online/services/armada/put_armada_by_ritase.dart';
import 'package:lmb_online/services/lmb/get_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/get_lmb_ritase_list.dart';
import 'package:lmb_online/services/lmb/post_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/validation.dart';
import 'package:lmb_online/services/operasi/reguler_komersil/get_komersil_total.dart';
import 'package:lmb_online/views/pengemudi/lmb/detail_ritase.dart';
import 'package:lmb_online/views/scan/scan_tiket.dart';
import 'package:lmb_online/views/scan/scan_tiket_ap2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LmbScanTiketPm extends StatefulWidget {
  final LmbDriverNewData lmbDriverNew;

  const LmbScanTiketPm({Key? key, required this.lmbDriverNew})
    : super(key: key);

  @override
  State<LmbScanTiketPm> createState() => _LmbScanTiketPmState();
}

class _LmbScanTiketPmState extends State<LmbScanTiketPm> {
  final GlobalKey<FormState> _formKeyKm = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyCatatan = GlobalKey<FormState>();
  ValidationTiket validation_tiket = ValidationTiket();
  ValidationTiketAp2 validation_tiket_ap2 = ValidationTiketAp2();
  PutArmadaByRitase putArmadaByRitase = PutArmadaByRitase();
  GetKomersilTotal get_komersil_total = GetKomersilTotal();
  GetListArmadaByLmb getListArmadaByLmb = GetListArmadaByLmb();
  GetLmbRitaseList getLmbRitaseList = GetLmbRitaseList();
  GetLmbRitase getLmbRitase = GetLmbRitase();
  PostLmbRitase postLmbRitase = PostLmbRitase();

  TextEditingController _kodeTiketController = TextEditingController();
  TextEditingController _kmAwalController = TextEditingController();
  TextEditingController _kmAkhirController = TextEditingController();
  TextEditingController _catatanController = TextEditingController();

  bool _isExpanded = false;
  String? _inputKmValidation;
  String? _inputCatatanValidation;

  // Tiket Damri
  String _tiketBeli = '0';
  String _isTrayekValid = "0";
  // Jika Scan
  String? _scannedValue;
  // Jika Input Manual
  String? _kdTiketValue;
  // End Tiket Damri

  int value_tiket = 0;
  int _ritase = 1;

  List<KomersilTotalData> _komersilTotalData = [];
  List<ListArmadaByLmbData> _listArmadaByLmb = [];
  List<LmbRitaseListData> _lmbRitaseDataList = [];

  // Edit Armada By Ritase
  late TextEditingController _ritaseController;
  String _newValueRitase = '';
  String _valueRitaseKomersil = '';

  String _valueKdArmada = "";

  // Selected Armada
  String _selectedKdArmada = "";
  String _selectedIdLMB = "";
  // End Edit Armada By Ritase

  // Cek Ritase Saat ini
  String _statusRitase = "";
  // End Cek Ritase Saat ini

  // Mulai dan Akhiri Ritase
  String _kmAwalValue = "";
  String _kmAkhirValue = "";
  String _catatanValue = "";
  String _statusValue = "";
  // End Mulai dan Akhiri Ritase

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
      _ritaseController = TextEditingController();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();
    setState(() {
      _komersilTotalData = [];
    });
    await _handleGetLmbRitase();
    await _handleGetKomersilTotal();
    await _handleGetListArmadaByLmb();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handlePutArmadaByRitase() async {
    String? id_lmb_lama = widget.lmbDriverNew.id_lmb;
    String? id_lmb_baru =
        (_selectedIdLMB.isNotEmpty)
            ? _selectedIdLMB
            : widget.lmbDriverNew.id_lmb;
    String? ritase_lama = _valueRitaseKomersil;
    String? ritase_baru = _newValueRitase;

    print(' id lmb lama : $id_lmb_lama');
    print(' id lmb baru : $id_lmb_baru');
    print(' ritase lama : $ritase_lama');
    print(' ritase baru : $ritase_baru');

    try {
      var response = await putArmadaByRitase.putArmadaByRitase(
        id_lmb_lama!,
        id_lmb_baru!,
        ritase_lama!,
        ritase_baru!,
      );

      if (response.code == 202) {
        initState();
      } else {
        print(response.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengubah data : ${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  // Fungsi untuk memanggil halaman scan tiket
  Future<void> _handleScanTiket() async {
    if (_tiketBeli == '1') {
      _scanTiket();
    } else if (_tiketBeli == '2') {
      _scanTiketAp2();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak Bisa Scan Tiket"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanTiket() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanTiket()),
    );
    if (result != null) {
      setState(() {
        _scannedValue = result;
      });
      _handleValidation();
    }
  }

  Future<void> _scanTiketAp2() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanTiketAp2()),
    );
    if (result != null) {
      setState(() {
        _scannedValue = result;
      });
      _handleValidation();
    }
  }

  void _addRitase() {
    if (_statusRitase == "2") return;

    setState(() {
      _ritase++;
    });
  }

  void _subRitase() {
    if (_statusRitase == "2") return;

    setState(() {
      if (_ritase > 1) {
        _ritase--;
      }
    });
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
        _initData();
        print(response.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal melakukan aksi ritase : ${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetKomersilTotal() async {
    final String? id_lmb = widget.lmbDriverNew.id_lmb;

    try {
      var response = await get_komersil_total.getKomersilTotal(id_lmb!);

      if (response.code == 200 && response.data != null) {
        setState(() {
          _komersilTotalData = response.data!;
        });
        print("Data Total Komersil: $_komersilTotalData");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetListArmadaByLmb() async {
    final String? id_bu = widget.lmbDriverNew.id_bu;
    final String? tgl_awal = widget.lmbDriverNew.tgl_awal;

    try {
      var response = await getListArmadaByLmb.getListArmadaByLmb(
        id_bu!,
        tgl_awal!,
      );

      if (response.code == 200) {
        setState(() {
          _listArmadaByLmb = response.data!;
          final matchingArmada =
              _listArmadaByLmb
                  .where((item) => item.id_lmb == widget.lmbDriverNew.id_lmb)
                  .toList();
          if (matchingArmada.isNotEmpty) {
            _valueKdArmada = matchingArmada.first.kd_armada!;
          }
        });
      } else {
        print(response.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mendapatkan data : ${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleValidation() async {
    // _showLoadingDialog();
    if (_tiketBeli == '1') {
      await _validationTiket();
    } else if (_tiketBeli == '2') {
      await _validationTiketAp2();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak Bisa Validasi Tiket"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Scan tiket validation Post method
  Future<void> _validationTiket() async {
    final prefs = await SharedPreferences.getInstance();

    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String? id_trayek = widget.lmbDriverNew.id_trayek;
    // kd tiket bisa dari scaned value atau input manual
    if (_scannedValue == null) {
      _kdTiketValue = _kodeTiketController.text;
    } else {
      _kdTiketValue = _scannedValue;
    }
    final String? kd_tiket = _kdTiketValue;
    final String? cuser = prefs.getString('user_id');
    final String? tgl_lmb = widget.lmbDriverNew.tgl_awal;
    final String? ritase = '$_ritase';
    final String? tiket_beli = _tiketBeli;
    final String? isTrayekValid = _isTrayekValid;
    final String? token = prefs.getString('token');

    print('id_lmb: $id_lmb');
    print('id_trayek: $id_trayek');
    print('kd_tiket: $kd_tiket');
    print('kode_tiket_manual : $_kdTiketValue');
    print('cuser: $cuser');
    print('tgl_lmb: $tgl_lmb');
    print('ritase: $ritase');
    print('tiket_beli: $tiket_beli');
    print('isTrayekValid: $isTrayekValid');
    print('token: $token');
    print('hasil scan : $_scannedValue');

    try {
      var response = await validation_tiket.postValidation(
        id_lmb!,
        id_trayek!,
        kd_tiket!,
        cuser!,
        tgl_lmb!,
        ritase!,
        tiket_beli!,
        isTrayekValid!,
        token!,
      );

      print('hasil response validation $response');

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
        _dialogFailed(response.message, response.code);
        _initData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _validationTiketAp2() async {
    final prefs = await SharedPreferences.getInstance();

    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String? id_trayek = widget.lmbDriverNew.id_trayek;
    // kd tiket bisa dari scaned value atau input manual
    if (_scannedValue == null) {
      _kdTiketValue = _kodeTiketController.text;
    } else {
      _kdTiketValue = _scannedValue;
    }
    final String? kd_tiket = _kdTiketValue;
    final String? cuser = prefs.getString('user_id');
    final String? tgl_lmb = widget.lmbDriverNew.tgl_awal;
    final String? ritase = '$_ritase';
    final String? tiket_beli = _tiketBeli;
    final String? isTrayekValid = _isTrayekValid;
    final String? token = prefs.getString('token');

    print('id_lmb: $id_lmb');
    print('id_trayek: $id_trayek');
    print('kd_tiket: $kd_tiket');
    print('kode_tiket_manual : $_kdTiketValue');
    print('cuser: $cuser');
    print('tgl_lmb: $tgl_lmb');
    print('ritase: $ritase');
    print('tiket_beli: $tiket_beli');
    print('isTrayekValid: $isTrayekValid');
    print('token: $token');
    print('hasil scan : $_scannedValue');

    try {
      var response = await validation_tiket_ap2.postValidation(
        id_lmb!,
        id_trayek!,
        kd_tiket!,
        cuser!,
        tgl_lmb!,
        ritase!,
        tiket_beli!,
        isTrayekValid!,
        token!,
      );

      print('code : $response.code');

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
        _dialogFailed(response.message, response.code);
        _initData();
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
        });
      } else {
        print(response.message);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetLmbRitase() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;

    try {
      var response = await getLmbRitase.getLmbRitase(id_lmb!, token!);

      if (response.code == 200) {
        print('Get LMB RITASE : ${response.data!}');
        setState(() {
          _kmAkhirValue = response.data!.km_akhir;
          _kmAwalValue = response.data!.km_awal;
          // jika status ritase 3 maka + value ritase 1 dari data.ritase
          _ritase =
              (response.data!.status == "3")
                  ? int.parse(response.data!.ritase!) + 1
                  : int.parse(response.data!.ritase!);

          print('ritase saat ini : $_ritase');
          _statusRitase = response.data!.status;
          print('Status Ritase : $_statusRitase');
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

  void _showDialogRiwayatRitase() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children:
                          _lmbRitaseDataList.isNotEmpty
                              ? _lmbRitaseDataList.map((item) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showDialogEditRiwayatRitase();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2.5,
                                    ),
                                    child: Card(
                                      // white
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Ritase',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${item.ritase}',
                                                  style: TextStyle(
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
                                                Text(
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
                                                Text(
                                                  'KM Mulai',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${item.km_awal}',
                                                  style: TextStyle(
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
                                                Text(
                                                  'Waktu Akhir',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
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
                                                Text(
                                                  'KM Akhir',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${item.km_akhir}',
                                                  style: TextStyle(
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
                              }).toList()
                              : [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Center(
                                    child: Text('Belum Ada Riwayat Ritase'),
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
  }

  void _showDialogEdit() {
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
                                _inputKmValidation = "";
                                _selectedIdLMB = "";
                                _selectedKdArmada = "";
                                _valueRitaseKomersil = "";
                                _newValueRitase = "";
                                _ritaseController.text = "";
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
                                  'Armada',
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
                                  child: GestureDetector(
                                    onTap: () {
                                      _handleGetListArmadaByLmb();
                                      Navigator.pop(context);
                                      _showDialogPilihArmada();
                                    },
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      // rounded and border
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(13),
                                        child: Text(
                                          _selectedKdArmada.isNotEmpty
                                              ? _selectedKdArmada
                                              : (_valueKdArmada.isEmpty
                                                  ? 'Pilih Armada'
                                                  : _valueKdArmada),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Ritase',
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
                                      width: 2,
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
                                      keyboardType: TextInputType.number,
                                      controller: _ritaseController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(
                                          left: 20,
                                        ),
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
                                      setStateDialog(() {
                                        if (_ritaseController.text
                                            .trim()
                                            .isEmpty) {
                                          _inputKmValidation =
                                              'Field tidak boleh kosong';
                                        } else {
                                          _inputKmValidation = null;
                                        }
                                      });

                                      if (_inputKmValidation != null) return;

                                      _newValueRitase = _ritaseController.text;
                                      await _handlePutArmadaByRitase();
                                      print(
                                        'value new armada : $_selectedKdArmada',
                                      );
                                      print(
                                        'id lmb : ${widget.lmbDriverNew.id_lmb}',
                                      );
                                      print(
                                        'ritase simpan : ${_newValueRitase}',
                                      );
                                      setState(() {
                                        _inputKmValidation = "";
                                        _selectedKdArmada = "";
                                        _selectedIdLMB = "";
                                        _valueRitaseKomersil = "";
                                        _ritaseController.text = "";
                                        _newValueRitase = "";
                                        _komersilTotalData = [];
                                      });
                                      Navigator.pop(context);
                                      _initData();
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

  void _showDialogPilihArmada() {
    // Controller untuk search bar
    TextEditingController _searchController = TextEditingController();
    // Inisialisasi filtered data dengan semua data awal
    List<ListArmadaByLmbData> _filteredArmada = List.from(_listArmadaByLmb);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Jika data belum tersedia, tampilkan loading indicator
            if (_listArmadaByLmb.isEmpty) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: Colors.transparent,
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              );
            }
            // Jika data sudah tersedia, tampilkan dialog dengan daftar data
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
                                _selectedKdArmada = "";
                                _selectedIdLMB = "";
                                _ritaseController.text = "";
                              });
                              Navigator.pop(context);
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
                                      _filteredArmada =
                                          _listArmadaByLmb.where((item) {
                                            return item.kd_armada!
                                                    .toLowerCase()
                                                    .contains(query) ||
                                                item.id_lmb!
                                                    .toLowerCase()
                                                    .contains(query);
                                          }).toList();
                                    } else {
                                      _filteredArmada = List.from(
                                        _listArmadaByLmb,
                                      );
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children:
                            _filteredArmada.isNotEmpty
                                ? _filteredArmada.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 5,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedKdArmada = item.kd_armada!;
                                          _selectedIdLMB = item.id_lmb!;
                                          print(
                                            'VALUE NEW ARMADA $_selectedKdArmada',
                                          );
                                          print(
                                            'VALUE NEW ID LMB $_selectedIdLMB',
                                          );
                                        });
                                        Navigator.pop(context);
                                        _showDialogEdit();
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
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Kode Armada',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF1A447F,
                                                          ),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      Text(
                                                        'ID LMB',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF1A447F,
                                                          ),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.kd_armada!,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        item.id_lmb!,
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
                                }).toList()
                                : [
                                  const Center(
                                    child: Text('Data tidak ditemukan'),
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
                              setStateDialog(() {
                                _kodeTiketController.clear();
                                _tiketBeli = '0';
                                value_tiket = 0;
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
                                  child: TextField(
                                    controller: _kodeTiketController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.only(
                                        left: 20,
                                      ),
                                      hintText: 'Kode Tiket',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _handleValidation();

                                      setState(() {
                                        _tiketBeli = '0';
                                        _kodeTiketController.clear();
                                        value_tiket = 0;
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

  void _showDialogEditRiwayatRitase() {
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
                                // _inputKmValidation = "";
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
                                    key: _formKeyKm,
                                    child: TextFormField(
                                      controller: _kmAwalController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(
                                          left: 20,
                                        ),
                                        hintText: 'km ritase terakhir : ',
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
                                    child: TextFormField(
                                      controller: _kmAwalController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(
                                          left: 20,
                                        ),
                                        hintText: 'km ritase terakhir : ',
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
                                      // setStateDialog(() {
                                      //   if (_kmAwalController.text
                                      //       .trim()
                                      //       .isEmpty) {
                                      //     _inputKmValidation =
                                      //         'Field tidak boleh kosong';
                                      //   } else {
                                      //     _inputKmValidation = null;
                                      //   }
                                      // });

                                      // if (_inputKmValidation != null) return;

                                      // await _handlePostLmbRitase(
                                      //   "2",
                                      //   _kmAwalController.text,
                                      // );

                                      // setState(() {
                                      //   _inputKmValidation = "";
                                      //   _kmAwalValue = "";
                                      //   _kmAwalController.clear();
                                      // });
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

  // dialog success
  void _dialogSuccess({String? header, String? tittle, String? action}) {
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
                              _kodeTiketController.clear();
                              _kdTiketValue = null;
                            });
                            if (action == "mulai ritase" ||
                                action == "akhiri ritase") {
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
                          child: Center(
                            child: Text(
                              action == "mulai ritase" ||
                                      action == "akhiri ritase"
                                  ? 'Tutup'
                                  : 'Scan',
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
                            print(_tiketBeli);
                            Navigator.pop(context);
                            if (code == 434) {
                              _inputKodeTiket();
                            } else {
                              setState(() {
                                _kodeTiketController.clear();
                                _kdTiketValue = null;
                              });
                              _handleScanTiket();
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
                              code == 434 ? 'Lihat Tiket' : 'Scan',
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
        title: const Text(
          'INPUT REGULER',
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _initData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _initData();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '${widget.lmbDriverNew.id_lmb}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '${widget.lmbDriverNew.kd_armada}',
                                      style: TextStyle(
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
                      ],
                    ),
                    trailing: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 32,
                    ),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isExpanded = expanded;
                      });
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // Tanggal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '${widget.lmbDriverNew.tgl_awal}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 90),
                            // Nomor Armada
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nomor Armada',
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
                                      'assets/images/ic_bus_side.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.lmbDriverNew.plat_armada}',
                                      style: TextStyle(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // Nama Supir
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Driver 1',
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
                                      '${widget.lmbDriverNew.nm_driver1}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 65),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Driver 2',
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
                                      widget.lmbDriverNew.nm_driver2 == null
                                          ? '-'
                                          : '${widget.lmbDriverNew.nm_driver2}',
                                      style: TextStyle(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_route.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '${widget.lmbDriverNew.nm_trayek}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // Nama Supir
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Layanan',
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
                                      'assets/images/ic_card.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.lmbDriverNew.nm_layanan}',
                                      style: TextStyle(
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
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              // Aktifitas Ritase
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
              const SizedBox(height: 10),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Card 1
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _tiketBeli = '1';
                              });

                              print('tiket beli : $_tiketBeli');

                              _handleScanTiket();
                            },
                            child: Container(
                              width: 100,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          // Card 2
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _tiketBeli = '2';
                              });

                              print('tiket beli : $_tiketBeli');

                              _handleScanTiket();
                            },
                            child: Container(
                              width: 100,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      color: Color(0xFF1A447F),
                                      size: 50,
                                    ),
                                    SizedBox(height: 10),
                                    Expanded(
                                      child: Text(
                                        'Scan Tiket AP2',
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
                          // Card 3
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
                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children:
                            _komersilTotalData.isNotEmpty
                                ? _komersilTotalData.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => DetailRitase(
                                                  ritaseValue: item.ritase,
                                                  idLmbValue:
                                                      widget
                                                          .lmbDriverNew
                                                          .id_lmb,
                                                  idBuValue:
                                                      widget.lmbDriverNew.id_bu,
                                                  tglAwalValue:
                                                      widget
                                                          .lmbDriverNew
                                                          .tgl_awal,
                                                ),
                                          ),
                                        ).then((refresh) {
                                          if (refresh == true) {
                                            _initData();
                                          }
                                        });
                                      },
                                      child: Card(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
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
                                                    item.ritase,
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
                                                      item.nm_trayek_detail,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      item.catatan ??
                                                          'Tidak ada catatan',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                    item.total,
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
                                                  setState(() {
                                                    _ritaseController.text =
                                                        item.ritase;
                                                    _valueRitaseKomersil =
                                                        item.ritase;
                                                  });
                                                  _showDialogEdit();
                                                },
                                                child: Icon(
                                                  Icons.note_alt_outlined,
                                                  color: const Color(
                                                    0xFF1A447F,
                                                  ),
                                                  size: 35,
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lmb_online/models/armada/get_list_armada_by_lmb_model.dart';
import 'package:lmb_online/models/lmb/get_lmb_driver_new_model.dart';
import 'package:lmb_online/models/lmb/get_lmb_ritase_list_model.dart';
import 'package:lmb_online/models/operasi/reguler_komersil/komersil_total_model.dart';
import 'package:lmb_online/services/ap2/validation_tiket_ap2.dart';
import 'package:lmb_online/services/armada/get_list_armada_by_lmb.dart';
import 'package:lmb_online/services/armada/put_armada_by_ritase.dart';
import 'package:lmb_online/services/lmb/delete_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/get_lmb_ritase_list.dart';
import 'package:lmb_online/services/lmb/post_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/put_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/validation.dart';
import 'package:lmb_online/services/operasi/reguler_komersil/get_komersil_total.dart';
import 'package:lmb_online/views/pengemudi/cek_tiket.dart';
import 'package:lmb_online/views/pengemudi/reguler/detail_ritase.dart';
import 'package:lmb_online/views/widget/detail_lmb_card.dart';
import 'package:lmb_online/views/widget/scan_barcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TiketPm extends StatefulWidget {
  final LmbDriverNewData lmbDriverNew;

  const TiketPm({Key? key, required this.lmbDriverNew}) : super(key: key);

  @override
  State<TiketPm> createState() => _TiketPmState();
}

class _TiketPmState extends State<TiketPm> {
  final GlobalKey<FormState> _formKeyKm = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyCatatan = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKdTiket = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKmMulai = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKmAkhir = GlobalKey<FormState>();

  ValidationTiket validation_tiket = ValidationTiket();
  ValidationTiketAp2 validation_tiket_ap2 = ValidationTiketAp2();
  PutArmadaByRitase putArmadaByRitase = PutArmadaByRitase();
  GetKomersilTotal get_komersil_total = GetKomersilTotal();
  GetListArmadaByLmb getListArmadaByLmb = GetListArmadaByLmb();
  GetLmbRitaseList getLmbRitaseList = GetLmbRitaseList();
  PostLmbRitase postLmbRitase = PostLmbRitase();
  PutLmbRitase putLmbRitase = PutLmbRitase();
  DeleteLmbRitase deleteLmbRitase = DeleteLmbRitase();

  TextEditingController _kodeTiketController = TextEditingController();
  TextEditingController _kmAwalController = TextEditingController();
  TextEditingController _kmAkhirController = TextEditingController();
  TextEditingController _catatanController = TextEditingController();
  TextEditingController _kmAwalEditController = TextEditingController();
  TextEditingController _kmAkhirEditController = TextEditingController();

  String? _inputKmValidation;
  String? _inputCatatanValidation;
  String? _inputKdTiketValidation;
  String? _inputKmAwalValidation;
  String? _inputKmAkhirValidation;

  // Tiket Damri
  String _tiketBeli = '0';
  String _isTrayekValid = "0";
  // Jika Scan
  // String? _scannedValue;
  // Jika Input Manual
  String? _kdTiketValue;
  // End Tiket Damri

  int value_tiket = 1;
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
  // End Mulai dan Akhiri Ritase

  // Edit Riwayat RITASE
  String _kmAwalEditValue = "";
  String _kmAkhirEditValue = "";
  // Edit Riwayat RITASE

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
    await _handleGetLmbRitaseList();
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
        ritase_lama,
        ritase_baru,
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanBarcode(tiketBeliValue: _tiketBeli),
      ),
    );
    if (result != null) {
      setState(() {
        _kdTiketValue = result;
      });
      print('HASIL SCAN KD TIKET : $_kdTiketValue');
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

  // Scan tiket validation Post method
  Future<void> _validationTiket() async {
    final prefs = await SharedPreferences.getInstance();

    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String? id_trayek = widget.lmbDriverNew.id_trayek;
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
    print('hasil scan : $_kdTiketValue');

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
        setState(() {
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
                                          _validationTiket();
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
                                      await _validationTiket();

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
                          child: Center(
                            child: Text(
                              action != "validasi tiket" ? 'Tutup' : 'Scan',
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
                            // jika action validasi tiket maka tampilkan 'Hasil Validasi'
                            // jika action ritase maka tampikan 'Gagal'
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
                            print(_tiketBeli);
                            Navigator.pop(context);
                            if (action == 'validasi tiket') {
                              if (code == 434) {
                                print('SCAN VALUE = $_kdTiketValue');
                                print('KDTIKET VALUE = $_kdTiketValue');
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
              // Aktifitas Ritase
              //  AktifitasRitaseCard(
              //   ritase: '$_ritase',
              //   statusRitase: '$_statusRitase',
              //   kmAwalValue: '$_kmAwalValue',
              //   kmAkhirValue: '$_kmAkhirValue',
              //   mulaiRitase: () => _showDialogMulaiRitase(context),
              //   akhiriRitase: () => _showDialogAkhiriRitase(context),
              //   riwayatRitase: () => _showDialogRiwayatRitase(context),
              //   getLmbRitaseList: _handleGetLmbRitaseList,
              // ),
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
                                _tiketBeli = '1';
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
                                      vertical: 1,
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
                                                      item.catatan ?? '',
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
                                              const SizedBox(width: 2),
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
                                              const SizedBox(width: 2),
                                              item.active == '1'
                                                  ? GestureDetector(
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
                                                  )
                                                  : const SizedBox(width: 10),
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

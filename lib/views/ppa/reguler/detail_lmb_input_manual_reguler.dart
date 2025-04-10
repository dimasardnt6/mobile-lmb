import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lmb_online/models/lmb/get_lmb_admin_model.dart';
import 'package:lmb_online/models/lmb/get_lmb_manual_model.dart';
import 'package:lmb_online/models/operasi/reguler_komersil/komersil_total_model.dart';
import 'package:lmb_online/models/trayek/get_trayek_detail_model.dart';
import 'package:lmb_online/services/lmb/delete_manual_reguler.dart';
import 'package:lmb_online/services/lmb/get_lmb_manual.dart';
import 'package:lmb_online/services/lmb/get_lmb_ritase_list.dart';
import 'package:lmb_online/services/lmb/post_lmb_manual.dart';
import 'package:lmb_online/services/lmb/post_lmb_ritase.dart';
import 'package:lmb_online/services/operasi/reguler_komersil/get_komersil_total.dart';
import 'package:lmb_online/services/ppa/verifikasi_ppa.dart';
import 'package:lmb_online/services/trayek/get_trayek_detail.dart';
import 'package:lmb_online/views/pengemudi/widget/detail_lmb_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailLmbInputManualReguler extends StatefulWidget {
  final GetLmbAdminData lmbData;

  const DetailLmbInputManualReguler({Key? key, required this.lmbData})
    : super(key: key);

  @override
  State<DetailLmbInputManualReguler> createState() =>
      _DetailLmbInputManualRegulerState();
}

class _DetailLmbInputManualRegulerState
    extends State<DetailLmbInputManualReguler> {
  final GlobalKey<FormState> _formKeyPenumpang = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyInputPenumpang = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyCatatanVerifikasi = GlobalKey<FormState>();

  GetKomersilTotal get_komersil_total = GetKomersilTotal();
  GetLmbRitaseList getLmbRitaseList = GetLmbRitaseList();
  PostLmbRitase postLmbRitase = PostLmbRitase();
  GetTrayekDetail getTrayekDetail = GetTrayekDetail();
  GetLmbManual getLmbManual = GetLmbManual();
  PostLmbManual postLmbManual = PostLmbManual();
  VerifikasiPpa verifikasiPpa = VerifikasiPpa();
  DeleteManualReguler deleteManualReguler = DeleteManualReguler();

  List<KomersilTotalData> _komersilTotalData = [];
  List<GetTrayekDetailData> _listTrayekData = [];
  List<GetLmbManualData> _listLmbManualData = [];

  TextEditingController _ritaseController = TextEditingController();
  TextEditingController _penumpangController = TextEditingController();

  int value_tiket = 0;

  // Pilih Trayek
  String _selectedKdTrayek = '';
  String _selectedNmTrayek = '';
  int _ritaseValue = 1;
  int _penumpangValue = 1;

  String? _inputTrayekValidation;
  String? _inputPenumpangValidation;
  String? _inputTotalPenumpangValidation;
  // Pilih Trayek

  // Cek Ritase Saat ini
  String _statusRitase = "";
  // End Cek Ritase Saat ini

  // Input Jumlah Penumpang
  TextEditingController _inputPenumpangController = TextEditingController();
  TextEditingController _catatanVerifikasiController = TextEditingController();

  String? _inputCatatanVerifikasiValidation;

  String? _inputPenumpangValue = '';
  String? _inputCatatanVerifikasi = '';
  // Input Jumlah Penumpang

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
      _ritaseController.clear();
      _penumpangController.clear();
      _inputTotalPenumpangValidation = null;
      _inputTrayekValidation = null;
      _inputPenumpangValidation = null;
      _komersilTotalData = [];
    });

    await _handleGetLmbManual();
    await _handleGetKomersilTotal();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
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
      _ritaseValue++;
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
      if (_ritaseValue > 1) {
        _ritaseValue--;
      }
    });
  }

  Future<void> _handleVerifikasiPpa() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? level = prefs.getString('id_level');
    final String? id_lmb = widget.lmbData.id_lmb;
    final String? ritase = _ritaseValue.toString();
    final String? user = prefs.getString('user_id');
    final String? pnp = _inputPenumpangValue;
    final String? status = '5';
    final String? catatan = _inputCatatanVerifikasi;

    print('id_lmb : $id_lmb');
    print('ritase : $ritase');
    print('user : $user');
    print('pnp : $pnp');
    print('status : $status');
    print('catatan : $catatan');
    print('token : $token');

    try {
      var response = await verifikasiPpa.verifikasiPpa(
        id_lmb!,
        ritase!,
        user!,
        pnp!,
        status!,
        catatan!,
        level!,
        token!,
      );

      if (response.code == 201) {
        Navigator.pop(context);
        _dialogSuccess(
          header: "Hasil Verifikasi",
          tittle: "Data Berhasil Diverifikasi",
        );
        _initData();
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
        _initData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleDeleteManualReguler(String id_lmb_reguler_apps) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbData.id_lmb;
    final String id_lmb_reguler_apps_value = id_lmb_reguler_apps;

    print('id_lmb delete: $id_lmb');
    print('id_lmb_reguler_apps delete: $id_lmb_reguler_apps_value');

    try {
      var response = await deleteManualReguler.deleteManualReguler(
        id_lmb!,
        id_lmb_reguler_apps_value,
        token!,
      );

      if (response.code == 200) {
        _listLmbManualData.removeWhere(
          (item) => item.id_lmb_reguler_apps == id_lmb_reguler_apps_value,
        );
        Navigator.pop(context);
        _dialogSuccess(
          header: "Delete Data Manual Reguler",
          tittle: response.message,
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handlePostLmbManual() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbData.id_lmb;
    final String? id_trayek = widget.lmbData.id_trayek;
    final String? id_trayek_detail = _selectedKdTrayek;
    final String? tot_pnp = _penumpangValue.toString();
    final String? tgl_lmb = widget.lmbData.tgl_awal;
    final String? jenis = widget.lmbData.kode_layanan;
    final String? ritase = _ritaseValue.toString();
    final String? kd_armada = widget.lmbData.kd_armada;
    final String? id_bu = widget.lmbData.id_bu;
    final String? cuser = prefs.getString('user_id');

    print('id_lmb view: $id_lmb');
    print('id_trayek view: $id_trayek');
    print('id_trayek_detail view: $id_trayek_detail');
    print('tot_pnp view: $tot_pnp');
    print('tgl_lmb view: $tgl_lmb');
    print('jenis view: $jenis');
    print('ritase view: $ritase');
    print('kd_armada view: $kd_armada');
    print('id_bu view: $id_bu');
    print('cuser view: $cuser');
    print('token view: $token');

    try {
      var response = await postLmbManual.postLmbManual(
        id_lmb!,
        id_trayek!,
        id_trayek_detail!,
        tot_pnp!,
        tgl_lmb!,
        jenis!,
        ritase!,
        kd_armada!,
        id_bu!,
        cuser!,
        token!,
      );

      if (response.code == 201) {
        Navigator.pop(context);
        _dialogSuccess(
          header: 'Berhasil',
          tittle: 'Data LMB manual berhasil ditambahkan',
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      Navigator.pop(context);
      _dialogFailed('Terjadi kesalahan saat menambahkan data LMB manual', 500);
    }
  }

  Future<void> _handleGetLmbManual() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbData.id_lmb;

    try {
      var response = await getLmbManual.getLmbManual(id_lmb!, token!);

      if (response.code == 200 && response.data != null) {
        setState(() {
          _ritaseValue =
              (response.data![0].active == "2")
                  ? int.parse(response.data![0].ritase ?? '0') + 1
                  : int.parse(response.data![0].ritase ?? '0');

          if (_ritaseValue == 0) {
            _ritaseValue = 1;
          }

          // int currentRitase =
          //     int.tryParse(response.data?[0].ritase ?? '0') ?? 0;
          // _ritaseValue = currentRitase == 0 ? 1 : currentRitase + 1;

          // _ritaseController = TextEditingController(text: '$_ritaseValue');

          _listLmbManualData = response.data!;
        });
        print("Data LMB Manual: $_listLmbManualData");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Terjadi kesalahan saat mengambil data LMB manual",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGetKomersilTotal() async {
    final String? id_lmb = widget.lmbData.id_lmb;

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

  Future<void> _handleGetTrayekDetail() async {
    String? id_trayek = widget.lmbData.id_trayek;

    try {
      var response = await getTrayekDetail.getTrayekDetail(id_trayek!);

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listTrayekData = response.data!;
        });
        print("Data Trayek: $_listTrayekData");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Terjadi kesalahan saat mengambil data trayek"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDialogKonfimasiVerifikasiPpa() {
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
                                  'Apakah Anda Yakin Ingin Menyimpan Data Ritase ke ${_ritaseController.text} ?',
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
                                            _inputTotalPenumpangValidation = "";
                                            _inputCatatanVerifikasiValidation =
                                                "";
                                            _inputPenumpangValue = "";
                                            _inputPenumpangController.clear();
                                            _inputCatatanVerifikasi = "";
                                            _catatanVerifikasiController
                                                .clear();
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
                                          setState(() {
                                            _inputPenumpangValue =
                                                _inputPenumpangController.text;
                                            _inputCatatanVerifikasi =
                                                _catatanVerifikasiController
                                                    .text;
                                          });

                                          await _handleVerifikasiPpa();

                                          setState(() {
                                            _inputTotalPenumpangValidation = "";
                                            _inputCatatanVerifikasiValidation =
                                                "";
                                            _inputPenumpangValue = "";
                                            _inputPenumpangController.clear();
                                            _inputCatatanVerifikasi = "";
                                            _catatanVerifikasiController
                                                .clear();
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

  void _showDialogInputJumlahPenumpang() {
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
                                'Input Jumlah Penumpang',
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
                                _inputTotalPenumpangValidation = "";
                                _inputCatatanVerifikasiValidation = "";
                                _inputPenumpangValue = "";
                                _inputPenumpangController.clear();
                                _inputCatatanVerifikasi = "";
                                _catatanVerifikasiController.clear();
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
                                  'Jumlah Penumpang',
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
                                    key: _formKeyInputPenumpang,
                                    child: TextField(
                                      controller: _inputPenumpangController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(
                                          left: 20,
                                        ),
                                        hintText: 'ex : 1234',
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
                                    _inputTotalPenumpangValidation ?? "",
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
                                    key: _formKeyCatatanVerifikasi,
                                    child: TextField(
                                      controller: _catatanVerifikasiController,
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
                                    _inputCatatanVerifikasiValidation ?? "",
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
                                        _inputTotalPenumpangValidation =
                                            _inputPenumpangController.text
                                                    .trim()
                                                    .isEmpty
                                                ? 'Field tidak boleh kosong'
                                                : null;

                                        _inputCatatanVerifikasiValidation =
                                            _catatanVerifikasiController.text
                                                    .trim()
                                                    .isEmpty
                                                ? 'Field tidak boleh kosong'
                                                : null;
                                      });

                                      if (_inputTotalPenumpangValidation !=
                                              null ||
                                          _inputCatatanVerifikasiValidation !=
                                              null)
                                        return;

                                      Navigator.pop(context);
                                      _showDialogKonfimasiVerifikasiPpa();

                                      // setState(() {
                                      //   _inputPenumpangValue =
                                      //       _inputPenumpangController.text;
                                      //   _inputCatatanVerifikasi =
                                      //       _catatanVerifikasiController.text;
                                      // });

                                      // await _handleVerifikasiPpa();

                                      // setState(() {
                                      //   _inputTotalPenumpangValidation = "";
                                      //   _inputCatatanVerifikasiValidation = "";
                                      //   _inputPenumpangValue = "";
                                      //   _inputPenumpangController.clear();
                                      //   _inputCatatanVerifikasi = "";
                                      //   _catatanVerifikasiController.clear();
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

  void _showDialogKonfirmasiHapusDataReguler(String? id_lmb_reguler_apps) {
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
                                  'Apakah Anda Yakin Ingin Menghapus Data Manual Reguler?',
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
                                          await _handleDeleteManualReguler(
                                            id_lmb_reguler_apps!,
                                          );
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

  void _showDialogPilihTrayek() {
    // Controller untuk search bar
    TextEditingController _searchController = TextEditingController();
    // Inisialisasi filtered data dengan semua data awal
    List<GetTrayekDetailData> _filteredTrayek = List.from(_listTrayekData);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MediaQuery.removeViewInsets(
          removeBottom: true,
          context: context,
          child: StatefulBuilder(
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
                                  'Pilih Trayek',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedKdTrayek = "";
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
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 5),
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: 'Cari Data ...',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    String query =
                                        _searchController.text.toLowerCase();
                                    setState(() {
                                      if (query.isNotEmpty) {
                                        _filteredTrayek =
                                            _listTrayekData.where((item) {
                                              return item.nm_trayek_detail!
                                                      .toLowerCase()
                                                      .contains(query) ||
                                                  item.id_trayek_detail!
                                                      .toLowerCase()
                                                      .contains(query);
                                            }).toList();
                                      } else {
                                        _filteredTrayek = List.from(
                                          _listTrayekData,
                                        );
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1A447F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Cari',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // List Item
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child:
                            _filteredTrayek.isNotEmpty
                                ? ListView.builder(
                                  itemCount: _filteredTrayek.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredTrayek[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 5,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedKdTrayek =
                                                item.id_trayek_detail!;
                                            _selectedNmTrayek =
                                                item.nm_trayek_detail!;
                                          });
                                          print(
                                            "Selected Trayek: $_selectedKdTrayek",
                                          );
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
                                                    Row(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Container(
                                                              width: 15,
                                                              height: 15,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      50,
                                                                    ),
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
                                                              height: 15,
                                                              color:
                                                                  const Color(
                                                                    0xFF1A447F,
                                                                  ),
                                                            ),
                                                            Container(
                                                              width: 15,
                                                              height: 15,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    const Color(
                                                                      0xFF1A447F,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      50,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item.nm_trayek_detail !=
                                                                          null &&
                                                                      item.nm_trayek_detail!
                                                                          .contains(
                                                                            '-',
                                                                          )
                                                                  ? item
                                                                      .nm_trayek_detail!
                                                                      .split(
                                                                        '-',
                                                                      )[0]
                                                                  : item.nm_trayek_detail ??
                                                                      '',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            Text(
                                                              item.nm_trayek_detail !=
                                                                          null &&
                                                                      item.nm_trayek_detail!
                                                                          .contains(
                                                                            '-',
                                                                          )
                                                                  ? item
                                                                      .nm_trayek_detail!
                                                                      .split(
                                                                        '-',
                                                                      )[1]
                                                                  : '',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          'KM Baku',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Text(
                                                          item.km ?? '',
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
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
                            'Gagal',
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
                            // _kodeTiketController.clear();
                            // _kdTiketValue = null;
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
      resizeToAvoidBottomInset: false,
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
                id_lmb: widget.lmbData.id_lmb ?? '',
                kd_armada: widget.lmbData.kd_armada ?? '',
                tgl_awal: widget.lmbData.tgl_awal ?? '',
                plat_armada: widget.lmbData.plat_armada ?? '',
                nm_driver1: widget.lmbData.nm_driver1 ?? '',
                nm_driver2: widget.lmbData.nm_driver2 ?? '',
                nm_trayek: widget.lmbData.nm_trayek ?? '',
                nm_layanan: widget.lmbData.nm_layanan ?? '',
              ),
              Card(
                // input ritase
                margin: const EdgeInsets.symmetric(horizontal: 10),
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
                                  '$_ritaseValue',
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
              const SizedBox(height: 20),
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
                        Text(
                          'Input Reguler',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pilih Trayek',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: const Color.fromARGB(255, 1, 43, 80),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              _showLoadingDialog();

                              await _handleGetTrayekDetail();

                              Navigator.pop(context);

                              _showDialogPilihTrayek();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 1, 43, 80),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(13),
                                child: Text(
                                  _selectedNmTrayek.isNotEmpty
                                      ? _selectedNmTrayek
                                      : 'Pilih Trayek',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
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
                            _inputTrayekValidation ?? "",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total PNP',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 1, 43, 80),
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Form(
                                    key: _formKeyPenumpang,
                                    child: TextFormField(
                                      focusNode: FocusNode(
                                        canRequestFocus: false,
                                      ),
                                      controller: _penumpangController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'ex:1',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _inputPenumpangValidation ?? "",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _inputTrayekValidation =
                                    _selectedKdTrayek.isEmpty
                                        ? 'Field tidak boleh kosong'
                                        : null;

                                _inputPenumpangValidation =
                                    _penumpangController.text.trim().isEmpty
                                        ? 'Field tidak boleh kosong'
                                        : null;
                              });

                              if (_inputPenumpangValidation != null ||
                                  _inputTrayekValidation != null)
                                return;

                              _showLoadingDialog();

                              setState(() {
                                _penumpangValue = int.parse(
                                  _penumpangController.text,
                                );
                              });

                              await _handlePostLmbManual();

                              setState(() {
                                _penumpangController.clear();
                                _penumpangValue = 0;
                                _ritaseValue = 0;
                                _selectedKdTrayek = '';
                                _selectedNmTrayek = '';
                              });

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
                ),
              ),
              const SizedBox(height: 20),
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
                            _listLmbManualData.isNotEmpty
                                ? _listLmbManualData.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 1,
                                    ),
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
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  item.ritase!,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
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
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        item.nm_trayek_detail!,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      item.active == '1'
                                                          ? GestureDetector(
                                                            onTap: () {
                                                              _showDialogKonfirmasiHapusDataReguler(
                                                                item.id_lmb_reguler_apps,
                                                              );
                                                              print(
                                                                'id_lmb_reguler_apps: ${item.id_lmb_reguler_apps}',
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 30,
                                                            ),
                                                          )
                                                          : const Text(
                                                            '',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                    ],
                                                  ),
                                                  Text(
                                                    'Total PNP : ${item.jml_penumpang}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.35,
                                                        child: Text(
                                                          'Input : ${item.nm_user}',
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item.cdate} WIB',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic,
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
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/ic_data_null.svg',
                                        // lebar full layar
                                        width:
                                            MediaQuery.of(context).size.width,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () async {
            _showDialogInputJumlahPenumpang();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1A447F),
              borderRadius: BorderRadius.circular(50),
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
            child: const Center(
              child: Text(
                'Setujui',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

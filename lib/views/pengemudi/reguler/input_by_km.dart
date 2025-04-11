import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lmb_online/models/lmb/get_lmb_driver_new_model.dart';
import 'package:lmb_online/models/lmb/get_lmb_ritase_list_model.dart';
import 'package:lmb_online/models/operasi/regular_perkotaan/get_reguler_model.dart';
import 'package:lmb_online/models/trayek/get_trayek_bko_model.dart';
import 'package:lmb_online/models/trayek/get_trayek_detail_model.dart';
import 'package:lmb_online/services/lmb/delete_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/get_lmb_manual.dart';
import 'package:lmb_online/services/lmb/get_lmb_ritase_list.dart';
import 'package:lmb_online/services/lmb/post_lmb_manual.dart';
import 'package:lmb_online/services/lmb/post_lmb_ritase.dart';
import 'package:lmb_online/services/lmb/put_lmb_ritase.dart';
import 'package:lmb_online/services/operasi/reguler_perkotaan/delete_reguler.dart';
import 'package:lmb_online/services/operasi/reguler_perkotaan/get_reguler.dart';
import 'package:lmb_online/services/operasi/reguler_perkotaan/post_reguler.dart';
import 'package:lmb_online/services/trayek/get_trayek_bko.dart';
import 'package:lmb_online/services/trayek/get_trayek_detail.dart';
import 'package:lmb_online/views/widget/detail_lmb_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputByKm extends StatefulWidget {
  final LmbDriverNewData lmbDriverNew;

  const InputByKm({Key? key, required this.lmbDriverNew}) : super(key: key);

  @override
  State<InputByKm> createState() => _InputByKmState();
}

class _InputByKmState extends State<InputByKm> {
  final GlobalKey<FormState> _formKeyTotalPenumpang = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKm = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyCatatan = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKmMulai = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKmAkhir = GlobalKey<FormState>();

  PostLmbRitase postLmbRitase = PostLmbRitase();
  GetTrayekDetail getTrayekDetail = GetTrayekDetail();
  GetLmbManual getLmbManual = GetLmbManual();
  PostLmbManual postLmbManual = PostLmbManual();
  GetLmbRitaseList getLmbRitaseList = GetLmbRitaseList();
  GetTrayekBko getTrayekBko = GetTrayekBko();
  PostReguler postReguler = PostReguler();
  GetReguler getReguler = GetReguler();
  PutLmbRitase putLmbRitase = PutLmbRitase();
  DeleteLmbRitase deleteLmbRitase = DeleteLmbRitase();
  DeleteReguler deleteReguler = DeleteReguler();

  List<GetTrayekDetailData> _listTrayekData = [];
  List<LmbRitaseListData> _lmbRitaseDataList = [];
  List<GetTrayekBkoData> _lisTrayekBkoData = List<GetTrayekBkoData>.empty(
    growable: true,
  );
  List<GetRegulerData> _listRegulerData = [];

  TextEditingController _ritaseController = TextEditingController();
  TextEditingController _kmOperasionalController = TextEditingController();
  TextEditingController _kmAwalController = TextEditingController();
  TextEditingController _kmAkhirController = TextEditingController();
  TextEditingController _catatanController = TextEditingController();
  TextEditingController _kmAwalEditController = TextEditingController();
  TextEditingController _kmAkhirEditController = TextEditingController();

  String? _inputKmAwalValidation;
  String? _inputKmAkhirValidation;

  int value_tiket = 0;

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

  // Pilih Trayek
  String _selectedKdTrayek = '';
  String _selectedKmOperasional = '';
  String _selectedNmTrayek = '';
  int _ritaseValue = 1;
  double _kmOperasionalValue = 1;

  String? _inputTrayekValidation;
  String? _inputKmOperasionalValidation;
  // Pilih Trayek

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
      _ritaseController.clear();
      // _kmOperasionalController.clear();
      _inputKmOperasionalValidation = null;
      _inputTrayekValidation = null;
      _lmbRitaseDataList = [];
      _lisTrayekBkoData = [];
      _listTrayekData = [];
    });

    await _handleGetReguler();
    await _handleGetLmbRitaseList();

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
        _dialogSuccess(header: "Edit Ritase", tittle: response.message);
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
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
        _dialogSuccess(header: "Delete Ritase", tittle: response.message);
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleDeleteReguler(String id_lmb_reguler) async {
    final String? id_lmb_reguler_value = id_lmb_reguler;

    print('id_lmb_reguler: $id_lmb_reguler');

    try {
      var response = await deleteReguler.deleteReguler(id_lmb_reguler_value!);

      if (response.code == 201) {
        Navigator.pop(context);
        _dialogSuccess(header: "Delete LMB Reguler", tittle: response.message);
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      _dialogFailed('Terjadi kesalahan saat menghapus data reguler', 500);
    }
  }

  Future<void> _handlePostReguler() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String? id_lmb = widget.lmbDriverNew.id_lmb;
    String? id_trayek_detail = _selectedKdTrayek;
    String? jml_penumpang = _kmOperasionalValue.toString();
    String? nomor_ap3 = 'apps';
    String? waktu = DateFormat('HH:mm:ss').format(now);
    String? ritase = _ritaseValue.toString();
    String? cuser = prefs.getString('user_id');

    // print('POST REGULER ID_LMB : $id_lmb');
    // print('POST REGULER ID_trayek : $id_trayek');
    // print('POST REGULER ID_trayek_detail : $id_trayek_detail');
    // print('POST REGULER ritase : $ritase');
    // print('POST REGULER km_ritase : $km_ritase');
    // print('POST REGULER kode_layanan : $kode_layanan');
    // print('POST REGULER waktu : $waktu');
    // print('POST REGULER cuser : $cuser');

    try {
      var response = await postReguler.postReguler(
        id_trayek_detail,
        id_lmb!,
        ritase,
        jml_penumpang,
        waktu,
        nomor_ap3,
        cuser!,
      );

      print('response postreguler : $response');

      if (response.code == 201) {
        Navigator.pop(context);
        _dialogSuccess(
          header: 'Berhasil',
          tittle: 'Data Reguler Berhasil Ditambahkan',
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      Navigator.pop(context);
      _dialogFailed('Terjadi kesalahan saat menambahkan data reguler', 500);
    }
  }

  Future<List<GetTrayekBkoData>> _handleGetTrayekBko(String searchValue) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_bu = prefs.getString('id_bu');

    try {
      var response = await getTrayekBko.getTrayekBko(
        id_bu!,
        searchValue,
        token!,
      );

      if (response.code == 200) {
        // Kembalikan daftar data, TANPA setState di sini
        return response.data!;
      } else {
        // Jika error code selain 200
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
        return [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat mengambil data Reguler"),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }

  Future<void> _handleGetReguler() async {
    final String? id_lmb = widget.lmbDriverNew.id_lmb;

    try {
      var response = await getReguler.getReguler(id_lmb!);

      if (response.code == 200 && response.data != null) {
        setState(() {
          _listRegulerData = response.data!;
        });
        print("Data REGULER: $_listRegulerData");
      } else {
        _listRegulerData = [];
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
          content: const Text("Terjadi kesalahan saat mengambil data Reguler"),
          backgroundColor: Colors.red,
        ),
      );
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
          _ritaseValue =
              (response.data![0].status == "3")
                  ? int.parse(response.data![0].ritase!) + 1
                  : int.parse(response.data![0].ritase!);

          // Jika ritase == 0, jadikan ritase = 1
          if (_ritaseValue == 0) {
            _ritaseValue = 1;
          }
          _statusRitase = response.data![0].status!;

          print("status ritase : $_statusRitase");
        });
      } else {
        _lmbRitaseDataList = [];
        print(response.message);
        setState(() {
          _statusRitase = "0";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetTrayekDetail() async {
    String? id_trayek = widget.lmbDriverNew.id_trayek;

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

  Future<void> _handlePostLmbRitase(String status, String kmValue) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_lmb = widget.lmbDriverNew.id_lmb;
    final String? ritase = '$_ritaseValue';
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
          tittle: "Berhasil Memulai Ritase $_ritaseValue",
        );
      } else if (response.code == 201 && status == "3") {
        Navigator.pop(context);
        _dialogSuccess(
          header: "Akhiri Ritase",
          tittle: "Berhasil Mengakhiri Ritase $_ritaseValue",
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      print(e);
    }
  }

  void _showDialogPilihTrayek() {
    TextEditingController _searchController = TextEditingController();

    // Salin data awal ke variabel lokal
    List<GetTrayekDetailData> _filteredTrayek = List.from(_listTrayekData);
    List<GetTrayekBkoData> _filteredTrayekBko = List.from(_lisTrayekBkoData);

    bool _isSearchPressed = false;
    bool _isLoading = false; // Tambahkan variabel loading

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MediaQuery.removeViewInsets(
          removeBottom: true,
          context: context,
          child: StatefulBuilder(
            builder: (context, setState) {
              // Method filter trayek
              void filterTrayek(String query) {
                query = query.toLowerCase();
                if (query.isNotEmpty) {
                  _filteredTrayek =
                      _listTrayekData.where((item) {
                        return item.nm_trayek_detail!.toLowerCase().contains(
                              query,
                            ) ||
                            item.id_trayek_detail!.toLowerCase().contains(
                              query,
                            );
                      }).toList();
                } else {
                  _filteredTrayek = List.from(_listTrayekData);
                }
              }

              // Method filter trayek BKO
              void filterTrayekBko(String query) {
                query = query.toLowerCase();
                if (query.isNotEmpty) {
                  _filteredTrayekBko =
                      _lisTrayekBkoData.where((item) {
                        return item.nm_trayek_detail!.toLowerCase().contains(
                              query,
                            ) ||
                            item.id_trayek_detail!.toLowerCase().contains(
                              query,
                            );
                      }).toList();
                } else {
                  _filteredTrayekBko = List.from(_lisTrayekBkoData);
                }
              }

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
                                  _searchController.clear();
                                  _isSearchPressed = false;
                                  _filteredTrayek = [];
                                  _filteredTrayekBko = [];
                                  _selectedKdTrayek = '';
                                });
                                Navigator.pop(context);
                                // _initData();
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
                                  onChanged: (value) {
                                    setState(() {
                                      _isSearchPressed = false;
                                      filterTrayek(value);
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() => _isLoading = true);

                                    await Future.delayed(
                                      const Duration(milliseconds: 500),
                                    );

                                    final query = _searchController.text.trim();
                                    final bkoData = await _handleGetTrayekBko(
                                      query,
                                    );

                                    setState(() {
                                      _isSearchPressed = true;

                                      _lisTrayekBkoData = bkoData;
                                      filterTrayekBko(query);
                                    });

                                    setState(() => _isLoading = false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A447F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
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

                      // List Item / Loading
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _isSearchPressed
                                ? _filteredTrayekBko.isNotEmpty
                                    ? ListView.builder(
                                      itemCount: _filteredTrayekBko.length,
                                      itemBuilder: (context, index) {
                                        final item = _filteredTrayekBko[index];
                                        return _buildItemTrayek(
                                          item.id_trayek_detail!,
                                          item.nm_trayek_detail!,
                                          item.km,
                                          setState,
                                        );
                                      },
                                    )
                                    : const Center(
                                      child: Text('Data tidak ditemukan'),
                                    )
                                : _filteredTrayek.isNotEmpty
                                ? ListView.builder(
                                  itemCount: _filteredTrayek.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredTrayek[index];
                                    return _buildItemTrayek(
                                      item.id_trayek_detail!,
                                      item.nm_trayek_detail!,
                                      item.km,
                                      setState,
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

  Widget _buildItemTrayek(
    String idTrayek,
    String nmTrayek,
    String? km,
    void Function(void Function()) setState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedKdTrayek = idTrayek;
            _selectedKmOperasional = km!;
            _selectedNmTrayek = nmTrayek;

            _kmOperasionalController.text = _selectedKmOperasional;
            print('KD TRAYEK: $_selectedKdTrayek');
          });
          Navigator.pop(context);
          _initData();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: const Color(0xFF1A447F),
                                  width: 2,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 15,
                              color: const Color(0xFF1A447F),
                            ),
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A447F),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nmTrayek.contains('-')
                                  ? nmTrayek.split('-')[0]
                                  : nmTrayek,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              nmTrayek.contains('-')
                                  ? nmTrayek.split('-')[1]
                                  : '',
                              style: const TextStyle(
                                color: Colors.black,
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
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          km ?? '',
                          style: const TextStyle(
                            color: Colors.black,
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
                                'Mulai Ritase - $_ritaseValue',
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
                                'Akhiri Ritase - $_ritaseValue',
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

  void _showDialogKonfirmasiHapusDataReguler(
    String ritase,
    String id_lmb_reguler,
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
                                  'Apakah Anda Yakin Ingin Menghapus Data Reguler Ritase $ritase ?',
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
                                          await _handleDeleteReguler(
                                            id_lmb_reguler,
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
              const SizedBox(height: 10),
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
              // Aktifitas Ritase
              Card(
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
                                        ? 'Mulai Ritase - $_ritaseValue'
                                        : _statusRitase == "2"
                                        ? 'Akhiri Ritase - $_ritaseValue'
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
                                  _selectedKdTrayek.isNotEmpty
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
                                'KM Operasional',
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
                                    key: _formKeyTotalPenumpang,
                                    child: TextFormField(
                                      controller: _kmOperasionalController,
                                      keyboardType: TextInputType.number,
                                      focusNode: FocusNode(
                                        canRequestFocus: false,
                                      ),
                                      autofocus: false,
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
                                  _inputKmOperasionalValidation ?? "",
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

                                _inputKmOperasionalValidation =
                                    _kmOperasionalController.text.trim().isEmpty
                                        ? 'Field tidak boleh kosong'
                                        : null;
                              });

                              if (_inputKmOperasionalValidation != null ||
                                  _inputTrayekValidation != null)
                                return;

                              _showLoadingDialog();

                              setState(() {
                                _kmOperasionalValue = double.parse(
                                  _kmOperasionalController.text,
                                );
                              });

                              await _handlePostReguler();

                              setState(() {
                                _kmOperasionalController.clear();
                                _kmOperasionalValue = 0;
                                _selectedKdTrayek = '';
                                _selectedNmTrayek = '';
                                _selectedKmOperasional = '';
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children:
                            _listRegulerData.isNotEmpty
                                ? _listRegulerData.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: Card(
                                      color: Colors.white,
                                      // item.active == '2'
                                      //     ? const Color.fromARGB(
                                      //       255,
                                      //       167,
                                      //       211,
                                      //       151,
                                      //     )
                                      //     : Colors.white,
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
                                                  item.ritase,
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
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.4,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item.nm_trayek_detail,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              'KM Operasi : ${item.km_ritase}',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Input : ${item.nm_user}',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 12,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          // item.active == '1'
                                                          //     ? GestureDetector(
                                                          //       onTap: () {

                                                          //       },
                                                          //       child: Icon(
                                                          //         Icons
                                                          //             .delete,
                                                          //         color: const Color(
                                                          //           0xFF1A447F,
                                                          //         ),
                                                          //         size: 35,
                                                          //       ),
                                                          //     )
                                                          //     : const SizedBox(
                                                          //       width: 10,
                                                          //     ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              _showDialogKonfirmasiHapusDataReguler(
                                                                item.ritase,
                                                                item.id_lmb_reguler,
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 30,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${item.waktu}',
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
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
    );
  }
}

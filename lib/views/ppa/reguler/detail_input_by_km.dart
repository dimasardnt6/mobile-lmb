import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lmb_online/models/lmb/get_lmb_admin_model.dart';
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

class DetailInputByKm extends StatefulWidget {
  final GetLmbAdminData lmbData;

  const DetailInputByKm({Key? key, required this.lmbData}) : super(key: key);

  @override
  State<DetailInputByKm> createState() => _DetailInputByKmState();
}

class _DetailInputByKmState extends State<DetailInputByKm> {
  final GlobalKey<FormState> _formKeyTotalPenumpang = GlobalKey<FormState>();

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
  List<GetTrayekBkoData> _lisTrayekBkoData = List<GetTrayekBkoData>.empty(
    growable: true,
  );
  List<GetRegulerData> _listRegulerData = [];

  TextEditingController _ritaseController = TextEditingController();
  TextEditingController _kmOperasionalController = TextEditingController();

  int value_tiket = 0;

  // Cek Ritase Saat ini
  String _statusRitase = "";
  // End Cek Ritase Saat ini

  // Pilih Trayek
  String _selectedKdTrayek = '';
  String _selectedKmOperasional = '';
  String _selectedNmTrayek = '';
  int _ritaseValue = 1;
  double _kmOperasionalValue = 1;

  String? _inputTrayekValidation;
  String? _inputKmOperasionalValidation;
  // Pilih Trayek

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
      _inputKmOperasionalValidation = null;
      _inputTrayekValidation = null;
      _lisTrayekBkoData = [];
      _listTrayekData = [];
    });

    await _handleGetReguler();

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
    String? id_lmb = widget.lmbData.id_lmb;
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
    final String? id_lmb = widget.lmbData.id_lmb;

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
                id_lmb: widget.lmbData.id_lmb ?? '',
                kd_armada: widget.lmbData.kd_armada ?? '',
                tgl_awal: widget.lmbData.tgl_awal ?? '',
                plat_armada: widget.lmbData.plat_armada ?? '',
                nm_driver1: widget.lmbData.nm_driver1 ?? '',
                nm_driver2: widget.lmbData.nm_driver2 ?? '',
                nm_trayek: widget.lmbData.nm_trayek ?? '',
                nm_layanan: widget.lmbData.nm_layanan ?? '',
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

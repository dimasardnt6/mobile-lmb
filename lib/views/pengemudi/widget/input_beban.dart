import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_online/models/beban/get_beban_model.dart';
import 'package:lmb_online/models/beban/get_item_beban_model.dart';
import 'package:lmb_online/models/beban/get_komponen_beban_model.dart';
import 'package:lmb_online/models/lmb/get_lmb_admin_model.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';
import 'package:lmb_online/services/beban/delete_beban.dart';
import 'package:lmb_online/services/beban/get_beban.dart';
import 'package:lmb_online/services/beban/get_item_beban.dart';
import 'package:lmb_online/services/beban/get_komponen_beban.dart';
import 'package:lmb_online/services/beban/post_beban.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputBeban extends StatefulWidget {
  final LmbDriverNewData? lmbDriverNew;
  final GetLmbAdminData? lmbData;

  const InputBeban({Key? key, this.lmbDriverNew, this.lmbData})
    : super(key: key);

  @override
  State<InputBeban> createState() => _InputBebanState();
}

class _InputBebanState extends State<InputBeban> {
  PostBeban postBeban = PostBeban();
  GetBeban getBeban = GetBeban();
  GetKomponenBeban getKomponenBeban = GetKomponenBeban();
  GetItemBeban getItemBeban = GetItemBeban();
  DeleteBeban deleteBeban = DeleteBeban();

  // Input Beban
  final GlobalKey<FormState> _formKeyJumlahBeban = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyHargaBeban = GlobalKey<FormState>();

  TextEditingController _jumlahBebanController = TextEditingController();
  TextEditingController _hargaBebanController = TextEditingController();

  List<GetBebanData> _listBebanData = [];
  List<GetKomponenBebanData> _listKomponenBebanData = [];
  List<GetItemBebanData> _listItemBebanData = [];

  String? _pilihKomponenValidation;
  String? _pilihItemValidation;
  String? _inputJumlahBebanValidation;
  String? _inputHargaBebanValidation;

  String? _selectedKomponen = '';
  String? _selectedItem = '';
  String? _valueJumlah = '';
  String? _valueHarga = '';
  int _unitPrice = 0;
  int _totalBeban = 0;
  // Input Beban

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
      _pilihItemValidation = '';
      _pilihKomponenValidation = '';
      _inputHargaBebanValidation = '';
      _inputJumlahBebanValidation = '';
    });

    await _handleGetKomponenBeban();
    await _handleGetBeban();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handlePostBeban() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id_level = prefs.getString('id_level');
    String? id_lmb =
        (id_level == '5')
            ? widget.lmbDriverNew?.id_lmb
            : widget.lmbData?.id_lmb;
    String? id_komponen = _selectedKomponen;
    String? id_item_teknik = _selectedItem;
    String? jumlah_beban = _valueJumlah;
    String? harga_beban = _valueHarga;
    String? cuser = prefs.getString('user_id');

    print('POST BEBAN ID_LMB : $id_lmb');
    print('POST BEBAN ID_KOMPONEN : $id_komponen');
    print('POST BEBAN ID_ITEM_TEKNIK : $id_item_teknik');
    print('POST BEBAN JUMLAH BEBAN : $jumlah_beban');
    print('POST BEBAN HARGA BEBAN : $harga_beban');

    print('POST BEBAN cuser : $cuser');

    try {
      var response = await postBeban.postBeban(
        id_lmb!,
        id_komponen!,
        id_item_teknik!,
        jumlah_beban!,
        harga_beban!,
        cuser!,
        token!,
      );

      print('response postBeban : $response');

      if (response.code == 201) {
        Navigator.pop(context);
        _dialogSuccess(
          header: 'Berhasil',
          tittle: 'Data Beban Berhasil Ditambahkan',
        );
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      Navigator.pop(context);
      _dialogFailed('Terjadi kesalahan saat menambahkan data beban', 500);
    }
  }

  Future<void> _handleDeleteBeban(String id_lmb_beban) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    String? id_level = prefs.getString('id_level');
    String? id_lmb =
        (id_level == '5')
            ? widget.lmbDriverNew?.id_lmb
            : widget.lmbData?.id_lmb;
    final String id_lmb_beban_value = id_lmb_beban;
    final String? cuser = prefs.getString('user_id');

    print('id_lmb delete: $id_lmb');
    print('id_lmb_beban delete: $id_lmb_beban');
    print('cuser: $cuser');

    try {
      var response = await deleteBeban.deleteBeban(
        id_lmb!,
        id_lmb_beban_value,
        cuser!,
        token!,
      );
      print('response code : ${response.code}');

      if (response.code == 201) {
        _listBebanData.removeWhere(
          (item) => item.id_lmb_beban == id_lmb_beban_value,
        );
        Navigator.pop(context);
        _dialogSuccess(header: "Delete Beban", tittle: response.message);
      } else {
        Navigator.pop(context);
        _dialogFailed(response.message, response.code);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleGetBeban() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    String? id_level = prefs.getString('id_level');
    String? id_lmb =
        (id_level == '5')
            ? widget.lmbDriverNew?.id_lmb
            : widget.lmbData?.id_lmb;

    print('id_lmb : $id_lmb');
    print('token : $token');

    try {
      var response = await getBeban.getBeban(id_lmb!, token!);

      if (response.code == 200) {
        setState(() {
          _listBebanData = response.data!;
        });
      } else {
        print('Error: ${response.message}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat mengambil data Reguler"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGetKomponenBeban() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    print('token : $token');

    try {
      var response = await getKomponenBeban.getKomponenBeban(token!);

      if (response.code == 200) {
        setState(() {
          _listKomponenBebanData = response.data!;
        });
      } else {
        print('Error: ${response.message}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat mengambil data komponen beban"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGetItemBeban(String? id_kategori_item_teknik) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? id_kategori_item_teknik_value = id_kategori_item_teknik;

    print('token : $token');
    print('id_kategori_item_teknik : $id_kategori_item_teknik');

    try {
      var response = await getItemBeban.getItemBeban(
        token!,
        id_kategori_item_teknik_value!,
      );

      if (response.code == 200) {
        setState(() {
          _listItemBebanData = response.data!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat mengambil data item beban"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDialogKonfirmasiHapusDataReguler(String? id_lmb_beban) {
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
                                  'Apakah Anda Yakin Ingin Menghapus Data Beban?',
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
                                          await _handleDeleteBeban(
                                            id_lmb_beban!,
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
                        Text(
                          'Input Beban',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Pilih Komponen',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              width: 2,
                              color: const Color.fromARGB(255, 1, 43, 80),
                            ),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value:
                                _listKomponenBebanData.any(
                                      (item) =>
                                          item.id_komponen == _selectedKomponen,
                                    )
                                    ? _selectedKomponen
                                    : null,
                            hint: const Text(
                              'Pilih Komponen',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            underline: const SizedBox(),
                            items:
                                _listKomponenBebanData.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.id_komponen,
                                    child: Text('${item.nm_komponen ?? '-'}'),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                // Reset semua nilai terkait
                                _selectedKomponen = newValue;
                                _selectedItem = '';
                                _jumlahBebanController.clear();
                                _hargaBebanController.clear();
                                _pilihItemValidation = '';
                                _inputJumlahBebanValidation = '';
                                _inputHargaBebanValidation = '';

                                // Reset nilai unitPrice dan totalBeban
                                _unitPrice = 0;
                                _totalBeban = 0;

                                print('SELECTED KOMPONEN : $_selectedKomponen');
                                final komponen = _listKomponenBebanData
                                    .firstWhere(
                                      (item) => item.id_komponen == newValue,
                                    );
                                if (komponen.id_kategori_item_teknik != "0") {
                                  _handleGetItemBeban(
                                    komponen.id_kategori_item_teknik,
                                  );
                                  _initData();
                                  print(
                                    'SELECTED id_kategori : ${komponen.id_kategori_item_teknik}',
                                  );
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _pilihKomponenValidation ?? "",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        // Tampilkan dropdown "Pilih Item" jika id_kategori_item_teknik bukan "0"
                        if (_selectedKomponen != null &&
                            _listKomponenBebanData
                                    .firstWhere(
                                      (item) =>
                                          item.id_komponen == _selectedKomponen,
                                      orElse:
                                          () => GetKomponenBebanData(
                                            id_komponen: '',
                                            nm_komponen: '',
                                            id_kategori_item_teknik: '0',
                                          ),
                                    )
                                    .id_kategori_item_teknik !=
                                "0") ...[
                          const Text(
                            'Pilih Item',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                width: 2,
                                color: const Color.fromARGB(255, 1, 43, 80),
                              ),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value:
                                  _listItemBebanData.any(
                                        (item) => item.id_item == _selectedItem,
                                      )
                                      ? _selectedItem
                                      : null,
                              hint: const Text(
                                'Pilih Item',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              underline: const SizedBox(),
                              items:
                                  _listItemBebanData.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item.id_item,
                                      child: Text('${item.nm_item ?? '-'}'),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedItem = newValue;
                                  print('SELECTED ITEM : $_selectedItem');
                                  // Cari item yang dipilih berdasarkan id_item
                                  final selectedItem = _listItemBebanData
                                      .firstWhere(
                                        (item) => item.id_item == newValue,
                                      );
                                  // Simpan harga dan set harga ke controller
                                  _unitPrice =
                                      int.tryParse(selectedItem.harga!) ?? 0;
                                  _hargaBebanController.text =
                                      _unitPrice.toString();
                                  print('Unit Price : $_unitPrice');
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _pilihItemValidation ?? "",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                        const Text(
                          'Jumlah Beban',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              width: 2,
                              color: const Color.fromARGB(255, 1, 43, 80),
                            ),
                          ),
                          child: Form(
                            key: _formKeyJumlahBeban,
                            child: TextField(
                              focusNode: FocusNode(canRequestFocus: false),
                              controller: _jumlahBebanController,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              onChanged: (value) {
                                setState(() {
                                  if (value.trim().isEmpty) {
                                    // Jika jumlah beban kosong, gunakan harga default
                                    _hargaBebanController.text =
                                        _unitPrice.toString();
                                    _totalBeban = _unitPrice;
                                  } else {
                                    int jumlah = int.tryParse(value) ?? 0;
                                    _totalBeban = jumlah * _unitPrice;
                                    _hargaBebanController.text =
                                        _totalBeban.toString();
                                  }
                                  print(
                                    'Jumlah: $value, Total Harga: $_totalBeban',
                                  );
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(left: 20),
                                hintText: "Jumlah Beban",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _inputJumlahBebanValidation ?? "",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Harga Beban',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              width: 2,
                              color: const Color.fromARGB(255, 1, 43, 80),
                            ),
                          ),
                          child: Form(
                            key: _formKeyHargaBeban,
                            child: TextField(
                              focusNode: FocusNode(canRequestFocus: false),
                              controller: _hargaBebanController,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(left: 20),
                                hintText: "Harga Beban",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _inputHargaBebanValidation ?? "",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _pilihKomponenValidation =
                                    _selectedKomponen!.isEmpty
                                        ? 'Field tidak boleh kosong'
                                        : null;
                                _inputJumlahBebanValidation =
                                    _jumlahBebanController.text.trim().isEmpty
                                        ? 'Field tidak boleh kosong'
                                        : null;
                                _inputHargaBebanValidation =
                                    _hargaBebanController.text.trim().isEmpty
                                        ? 'Field tidak boleh kosong'
                                        : null;
                              });

                              if (_pilihKomponenValidation != null ||
                                  _inputJumlahBebanValidation != null ||
                                  _inputHargaBebanValidation != null)
                                return;

                              _showLoadingDialog();

                              setState(() {
                                _valueJumlah = _jumlahBebanController.text;
                                _valueHarga = _hargaBebanController.text;
                              });

                              await _handlePostBeban();

                              setState(() {
                                _valueJumlah = '';
                                _valueHarga = '';
                                _jumlahBebanController.clear();
                                _hargaBebanController.clear();
                                _pilihKomponenValidation = '';
                                _pilihItemValidation = '';
                                _inputJumlahBebanValidation = '';
                                _inputHargaBebanValidation = '';
                                _selectedItem = '';
                                _selectedKomponen = '';
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
                    Text(
                      'Data Beban',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children:
                          _listBebanData.isNotEmpty
                              ? _listBebanData.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.nm_komponen}${(item.nm_item == null || item.nm_item!.isEmpty) ? '' : ' - ${item.nm_item}'}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 10),
                                              Text(
                                                'Jumlah Beban : ${item.jumlah_beban}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Nominal Beban : Rp. ${item.nominal_beban}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _showDialogKonfirmasiHapusDataReguler(
                                                item.id_lmb_beban,
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
                                        'Tidak ada data beban',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

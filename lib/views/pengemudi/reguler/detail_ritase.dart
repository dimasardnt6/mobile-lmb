import 'package:flutter/material.dart';
import 'package:lmb_online/models/armada/list_armada_by_lmb_model.dart';
import 'package:lmb_online/models/lmb/detail_ritase_model.dart';
import 'package:lmb_online/services/armada/get_list_armada_by_lmb.dart';
import 'package:lmb_online/services/armada/put_armada_by_id.dart';
import 'package:lmb_online/services/lmb/get_detail_ritase.dart';

class DetailRitase extends StatefulWidget {
  final String? ritaseValue;
  final String? idLmbValue;
  final String? idBuValue;
  final String? tglAwalValue;

  const DetailRitase({
    Key? key,
    required this.ritaseValue,
    required this.idLmbValue,
    required this.idBuValue,
    required this.tglAwalValue,
  }) : super(key: key);

  @override
  State<DetailRitase> createState() => _DetailRitaseState();
}

class _DetailRitaseState extends State<DetailRitase> {
  GetDetailRitase getDetailRitase = GetDetailRitase();
  GetListArmadaByLmb getListArmadaByLmb = GetListArmadaByLmb();
  PutArmadaById putArmadaById = PutArmadaById();

  List<DetailRitaseData> _detailRitaseList = [];
  List<ListArmadaByLmbData> _listArmadaByLmb = [];

  late TextEditingController _ritaseController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _inputValidation;

  String _valueArmada = "";
  String _valueIdLmbRegulerApps = "";
  String _newValueRitase = "";

  // Selected Armada
  String _selectedKdArmada = "";
  String _selectedIdLMB = "";

  @override
  void initState() {
    super.initState();
    // _showLoadingDialog();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ritaseController = TextEditingController(text: widget.ritaseValue ?? '');
      _initData();
    });
  }

  Future<void> _initData() async {
    _showLoadingDialog();

    await _handleDetailRitase();
    await _handleGetListArmadaByLmb();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handlePutArmadaById() async {
    final String id_lmb =
        (_selectedIdLMB.isNotEmpty)
            ? _selectedIdLMB
            : (widget.idLmbValue ?? 'default_value');

    final String? ritase = _newValueRitase;
    final String? id_lmb_reguler_apps = _valueIdLmbRegulerApps;

    print(' id lmb : $id_lmb');
    print('ritase handle :  $ritase');
    print('lmb regular apps $id_lmb_reguler_apps');

    try {
      print("Call Data" + id_lmb_reguler_apps! + ',' + id_lmb + ',' + ritase!);
      var response = await putArmadaById.putArmadaById(
        id_lmb_reguler_apps,
        id_lmb,
        ritase,
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

  Future<void> _handleGetListArmadaByLmb() async {
    final String? id_bu = widget.idBuValue;
    final String? tgl_awal = widget.tglAwalValue;

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
                  .where((item) => item.id_lmb == widget.idLmbValue)
                  .toList();
          if (matchingArmada.isNotEmpty) {
            _valueArmada = matchingArmada.first.kd_armada!;
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

  Future<void> _handleDetailRitase() async {
    final String? ritase = widget.ritaseValue;
    final String? id_lmb = widget.idLmbValue;

    try {
      var response = await getDetailRitase.getDetailRitase(id_lmb!, ritase!);

      if (response.code == 200) {
        print(response.data);
        setState(() {
          _detailRitaseList = response.data!;
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
                                _inputValidation = "";
                                _selectedKdArmada = "";
                                _selectedIdLMB = "";
                                _ritaseController.text = widget.ritaseValue!;
                                _valueIdLmbRegulerApps = "";
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
                                _inputValidation = "";
                                _selectedIdLMB = "";
                                _selectedKdArmada = "";
                                _ritaseController.text = widget.ritaseValue!;
                                _valueIdLmbRegulerApps = "";
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
                                              : (_valueArmada.isEmpty
                                                  ? 'Pilih Armada'
                                                  : _valueArmada),
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
                                    key: _formKey,
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
                                    _inputValidation ?? "",
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
                                          _inputValidation =
                                              'Field tidak boleh kosong';
                                        } else {
                                          _inputValidation = null;
                                        }
                                      });

                                      if (_inputValidation != null) return;

                                      _newValueRitase = _ritaseController.text;
                                      await _handlePutArmadaById();
                                      print(
                                        'id lmb reguler apps : $_valueIdLmbRegulerApps',
                                      );
                                      print(
                                        'value new armada : $_selectedKdArmada',
                                      );
                                      print('id lmb : ${widget.idLmbValue}');
                                      print('ritase simpan : $_newValueRitase');
                                      setState(() {
                                        _inputValidation = "";
                                        _ritaseController.text = "";
                                        _newValueRitase = "";
                                        _valueIdLmbRegulerApps = "";
                                        _detailRitaseList = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 248, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A447F),
        title: const Text(
          'Detail Ritase',
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
                _detailRitaseList.isNotEmpty
                    ? _detailRitaseList.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
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
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: const Color(0xFF1A447F),
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
                                        ],
                                      ),
                                    ],
                                  ),
                                  item.active == '1'
                                      ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _valueIdLmbRegulerApps =
                                                item.id_lmb_reguler_apps!;
                                            _ritaseController.text =
                                                widget.ritaseValue!;
                                          });
                                          print(_valueIdLmbRegulerApps);
                                          _showDialogEdit();
                                        },
                                        child: Icon(
                                          Icons.note_alt_outlined,
                                          color: const Color(0xFF1A447F),
                                          size: 45,
                                        ),
                                      )
                                      : const SizedBox(width: 10),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Text(
                                      'Rp. ${(double.parse(item.harga!).toStringAsFixed(0))}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.nm_user}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
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

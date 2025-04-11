import 'package:flutter/material.dart';
import 'package:lmb_online/models/lmb/get_lmb_admin_model.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';
import 'package:lmb_online/views/pengemudi/reguler/input_by_km.dart';
import 'package:lmb_online/views/pengemudi/reguler/input_manual_reguler.dart';
import 'package:lmb_online/views/pengemudi/reguler/manual_km.dart';
import 'package:lmb_online/views/pengemudi/reguler/tiket_akap.dart';
import 'package:lmb_online/views/ppa/reguler/detail_input_by_km.dart';
import 'package:lmb_online/views/ppa/reguler/detail_lmb_akap.dart';
import 'package:lmb_online/views/ppa/reguler/detail_lmb_input_manual_reguler.dart';
import 'package:lmb_online/views/ppa/reguler/detail_lmb_pm.dart';
import 'package:lmb_online/views/ppa/reguler/detail_manual_km.dart';
import 'package:lmb_online/views/widget/input_beban.dart';
import 'package:lmb_online/views/pengemudi/reguler/tiket_pm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabBarDetailLmb extends StatefulWidget {
  final LmbDriverNewData? lmbDriverNew;
  final GetLmbAdminData? lmbData;

  const TabBarDetailLmb({Key? key, this.lmbDriverNew, this.lmbData})
    : super(key: key);

  @override
  State<TabBarDetailLmb> createState() => _TabBarDetailLmbState();
}

class _TabBarDetailLmbState extends State<TabBarDetailLmb> {
  String id_level = "";

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id_level = prefs.getString('id_level')?.trim() ?? "";
      print('id_level: $id_level');
      print('WIDGET DATA ${widget.lmbData}');
      print('WIDGET DATA DRIVER ${widget.lmbDriverNew}');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (id_level.isEmpty) {
      return Scaffold(
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
          bottom: const TabBar(
            dividerColor: Color(0xFF1A447F),
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            indicatorColor: Colors.amber,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [Tab(text: 'REGULER'), Tab(text: 'INPUT BEBAN')],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Tab bar 1: Pilih widget berdasarkan id_level
            if (id_level == "5")
              if (widget.lmbDriverNew!.tipe_lmb_online == "1" &&
                  widget.lmbDriverNew!.id_segment_transaksi == "2")
                TiketPm(lmbDriverNew: widget.lmbDriverNew!)
              else if (widget.lmbDriverNew!.tipe_lmb_online == "1" &&
                  widget.lmbDriverNew!.id_segment_transaksi == "1")
                TiketAkap(lmbDriverNew: widget.lmbDriverNew!)
              else if (widget.lmbDriverNew!.tipe_lmb_online == "0")
                InputManualReguler(lmbDriverNew: widget.lmbDriverNew!)
              else if (widget.lmbDriverNew!.tipe_lmb_online == "2")
                InputByKm(lmbDriverNew: widget.lmbDriverNew!)
              else if (widget.lmbDriverNew!.tipe_lmb_online == "3")
                ManualKm(lmbDriverNew: widget.lmbDriverNew!)
              else
                const Center(
                  child: Text(
                    "Kondisi tidak dikenali",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
            else if (id_level == "14")
              if (widget.lmbData!.tipe_lmb_online == "1" &&
                  widget.lmbData!.id_segment_transaksi == "2")
                DetailLmbPm(lmbData: widget.lmbData!)
              else if (widget.lmbData!.tipe_lmb_online == "1" &&
                  widget.lmbData!.id_segment_transaksi == "1")
                DetailLmbAkap(lmbData: widget.lmbData!)
              else if (widget.lmbData!.tipe_lmb_online == "0")
                DetailLmbInputManualReguler(lmbData: widget.lmbData!)
              else if (widget.lmbData!.tipe_lmb_online == "2")
                DetailInputByKm(lmbData: widget.lmbData!)
              else if (widget.lmbData!.tipe_lmb_online == "3")
                DetailManualKm(lmbData: widget.lmbData!)
              else
                const Center(
                  child: Text(
                    "Kondisi tidak dikenali",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
            else
              Container(),
            // Tab bar 2
            InputBeban(lmbDriverNew: widget.lmbDriverNew),
          ],
        ),
      ),
    );
  }
}

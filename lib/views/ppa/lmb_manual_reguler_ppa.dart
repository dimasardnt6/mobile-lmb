import 'package:flutter/material.dart';
import 'package:lmb_online/models/lmb/get_lmb_admin_model.dart';
import 'package:lmb_online/views/pengemudi/widget/input_beban.dart';
import 'package:lmb_online/views/ppa/reguler/detail_lmb_input_manual_reguler.dart';

class LmbManualRegulerPpa extends StatefulWidget {
  final GetLmbAdminData lmbData;

  const LmbManualRegulerPpa({Key? key, required this.lmbData})
    : super(key: key);
  // const LmbManualRegulerPpa({Key? key}) : super(key: key);

  @override
  State<LmbManualRegulerPpa> createState() => _LmbManualRegulerPpaState();
}

class _LmbManualRegulerPpaState extends State<LmbManualRegulerPpa> {
  @override
  Widget build(BuildContext context) {
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
          bottom: TabBar(
            dividerColor: const Color(0xFF1A447F),
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
            DetailLmbInputManualReguler(lmbData: widget.lmbData),
            InputBeban(lmbData: widget.lmbData),
          ],
        ),
      ),
    );
  }
}

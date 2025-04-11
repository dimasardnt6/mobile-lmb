import 'package:flutter/material.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';
import 'package:lmb_online/views/widget/input_beban.dart';
import 'package:lmb_online/views/pengemudi/lmb/reguler/tiket_pm.dart';

class LmbPemaduModa extends StatefulWidget {
  final LmbDriverNewData lmbDriverNew;

  const LmbPemaduModa({Key? key, required this.lmbDriverNew}) : super(key: key);
  // const LmbPemaduModa({Key? key}) : super(key: key);

  @override
  State<LmbPemaduModa> createState() => _LmbPemaduModaState();
}

class _LmbPemaduModaState extends State<LmbPemaduModa> {
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
            TiketPm(lmbDriverNew: widget.lmbDriverNew),
            InputBeban(lmbDriverNew: widget.lmbDriverNew),
          ],
        ),
      ),
    );
  }
}

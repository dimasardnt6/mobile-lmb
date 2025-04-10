import 'package:flutter/material.dart';
import 'package:lmb_online/models/lmb/lmb_driver_new_model.dart';
import 'package:lmb_online/views/pengemudi/widget/input_beban.dart';
import 'package:lmb_online/views/pengemudi/lmb/reguler/input_by_km.dart';

class LmbInputByKm extends StatefulWidget {
  final LmbDriverNewData lmbDriverNew;

  const LmbInputByKm({Key? key, required this.lmbDriverNew}) : super(key: key);
  // const LmbInputByKm({Key? key}) : super(key: key);

  @override
  State<LmbInputByKm> createState() => _LmbInputByKmState();
}

class _LmbInputByKmState extends State<LmbInputByKm> {
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
            InputByKm(lmbDriverNew: widget.lmbDriverNew),
            InputBeban(lmbDriverNew: widget.lmbDriverNew),
          ],
        ),
      ),
    );
  }
}

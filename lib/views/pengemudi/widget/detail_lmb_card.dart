import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_online/views/pengemudi/lmb/reguler/lihat_laporan.dart';
import 'package:lmb_online/services/endpoint.dart';

class DetailLmbCard extends StatefulWidget {
  final String id_lmb;
  final String kd_armada;
  final String tgl_awal;
  final String plat_armada;
  final String nm_driver1;
  final String? nm_driver2;
  final String nm_trayek;
  final String nm_layanan;

  const DetailLmbCard({
    Key? key,
    required this.id_lmb,
    required this.kd_armada,
    required this.plat_armada,
    required this.nm_driver1,
    this.nm_driver2,
    required this.nm_trayek,
    required this.nm_layanan,
    required this.tgl_awal,
  }) : super(key: key);
  @override
  State<DetailLmbCard> createState() => _DetailLmbCardState();
}

class _DetailLmbCardState extends State<DetailLmbCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No LMB',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_lmb.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.id_lmb}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kode Armada',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_bus_front.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.kd_armada}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 32,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  // Tanggal
                  Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_calendar.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.tgl_awal}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Nomor Armada
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nomor Armada',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_bus_side.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.plat_armada}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  // Nama Supir
                  Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Driver 1',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_driver.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.nm_driver1}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Driver 2',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_driver.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.nm_driver2 == null
                                  ? '-'
                                  : '${widget.nm_driver2}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trayek',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_route.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${widget.nm_trayek}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Layanan',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_card.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.nm_layanan}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        String? id_lmb = widget.id_lmb;
                        if (id_lmb.isNotEmpty) {
                          String encoded = base64Encode(utf8.encode(id_lmb));
                          String url =
                              '${Endpoints.slipLaporan}/laporan_lmb_online/cetak_laporan_lmb/?v=$encoded';
                          print('URL LAPORAN : $url');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LihatLaporan(url: url),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A447F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.file_open_rounded, color: Colors.white),
                          Text(
                            'Lihat Laporan',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
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
  }
}

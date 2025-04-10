import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LihatLaporan extends StatefulWidget {
  final String url;

  const LihatLaporan({Key? key, required this.url}) : super(key: key);

  @override
  State<LihatLaporan> createState() => _LihatLaporanState();
}

class _LihatLaporanState extends State<LihatLaporan> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _loadFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A447F),
        title: const Text(
          'Laporan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _loadFailed
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/ic_data_error.svg',
                      width: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "URL tidak bisa dibuka",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : SfPdfViewer.network(
                widget.url,
                key: _pdfViewerKey,
                onDocumentLoadFailed: (details) {
                  setState(() {
                    _loadFailed = true;
                  });
                },
              ),
    );
  }
}

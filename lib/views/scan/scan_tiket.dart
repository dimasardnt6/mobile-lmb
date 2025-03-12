import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanTiket extends StatefulWidget {
  const ScanTiket({Key? key}) : super(key: key);

  @override
  State<ScanTiket> createState() => _ScanTiketState();
}

class _ScanTiketState extends State<ScanTiket> {
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A447F),
        title: const Text(
          'Scan Tiket',
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
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  setState(() {
                    scanResult = rawValue;
                  });
                  Navigator.pop(context, rawValue);
                }
              }
            },
          ),

          _QROverlay(),

          /// 3. Tampilkan hasil scan
          if (scanResult != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                color: Colors.white70,
                padding: const EdgeInsets.all(8),
                child: Text('Hasil scan: $scanResult'),
              ),
            ),
        ],
      ),
    );
  }
}

class _QROverlay extends StatelessWidget {
  const _QROverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        const boxSize = 350.0;
        final verticalMargin = (height - boxSize) / 2;
        final horizontalMargin = (width - boxSize) / 2;

        return Stack(
          children: [
            /// Bagian atas di luar kotak scan
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: verticalMargin,
              child: Container(color: Colors.black45),
            ),

            /// Bagian bawah di luar kotak scan
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: verticalMargin,
              child: Container(color: Colors.black45),
            ),

            /// Bagian kiri di luar kotak scan
            Positioned(
              top: verticalMargin,
              left: 0,
              width: horizontalMargin,
              height: boxSize,
              child: Container(color: Colors.black45),
            ),

            /// Bagian kanan di luar kotak scan
            Positioned(
              top: verticalMargin,
              right: 0,
              width: horizontalMargin,
              height: boxSize,
              child: Container(color: Colors.black45),
            ),

            /// Bingkai kotak scan di tengah
            Positioned(
              top: verticalMargin,
              left: horizontalMargin,
              width: boxSize,
              height: boxSize,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Positioned(top: 0, left: 0, child: _cornerWidget()),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Transform.rotate(
                        angle: 90 * 3.14159 / 180,
                        child: _cornerWidget(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Transform.rotate(
                        angle: 270 * 3.14159 / 180,
                        child: _cornerWidget(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Transform.rotate(
                        angle: 180 * 3.14159 / 180,
                        child: _cornerWidget(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cornerWidget() {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white, width: 4),
          left: BorderSide(color: Colors.white, width: 4),
        ),
      ),
    );
  }
}

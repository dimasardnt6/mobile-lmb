import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanBarcode extends StatefulWidget {
  final String tiketBeliValue;

  const ScanBarcode({Key? key, required this.tiketBeliValue}) : super(key: key);

  @override
  State<ScanBarcode> createState() => _ScanBarcodeState();
}

class _ScanBarcodeState extends State<ScanBarcode> {
  String? scanResult;
  bool _isFlashOn = false;
  final MobileScannerController _mobileScannerController =
      MobileScannerController();

  // Fungsi untuk toggle flash
  void _toggleFlash() {
    _mobileScannerController.toggleTorch();
    setState(() {
      print('TIKET BELI ${widget.tiketBeliValue}');
      _isFlashOn = !_isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A447F),
        title: Text(
          widget.tiketBeliValue == "1"
              ? 'SCAN TIKET'
              : widget.tiketBeliValue == "2"
              ? 'SCAN TIKET AP2'
              : widget.tiketBeliValue == "3"
              ? 'SCAN TIKET'
              : 'SCAN KODE ARMADA',
          style: const TextStyle(
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
            controller: _mobileScannerController,
            onDetect: (capture) {
              if (scanResult != null) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  setState(() {
                    scanResult = rawValue;
                  });
                  print('HASIL SCAN $scanResult');
                  Navigator.pop(context, rawValue);
                  break;
                }
              }
            },
          ),
          // Overlay scan dengan button flash yang sudah terintegrasi
          _QROverlay(toggleFlash: _toggleFlash, isFlashOn: _isFlashOn),
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
  final VoidCallback toggleFlash;
  final bool isFlashOn;

  const _QROverlay({
    Key? key,
    required this.toggleFlash,
    required this.isFlashOn,
  }) : super(key: key);

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
            // Area atas di luar kotak scan
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: verticalMargin,
              child: Container(color: Colors.black45),
            ),
            // Area bawah tombol flash
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: verticalMargin,
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      isFlashOn ? Icons.flashlight_off : Icons.flashlight_on,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: toggleFlash,
                  ),
                ),
              ),
            ),
            // Area kiri di luar kotak scan
            Positioned(
              top: verticalMargin,
              left: 0,
              width: horizontalMargin,
              height: boxSize,
              child: Container(color: Colors.black45),
            ),
            // Area kanan di luar kotak scan
            Positioned(
              top: verticalMargin,
              right: 0,
              width: horizontalMargin,
              height: boxSize,
              child: Container(color: Colors.black45),
            ),
            // Bingkai kotak scan di tengah
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

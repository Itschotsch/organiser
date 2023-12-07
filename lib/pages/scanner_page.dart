import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? controller;
  String? qrid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Permission.camera.request(),
              builder: (context, snapshot) {
                if (snapshot.data == PermissionStatus.granted) {
                  // Permission granted, so show the QR scanner:
                  return QRView(
                    key: qrKey,
                    overlay: QrScannerOverlayShape(
                      borderRadius: 10,
                      borderColor: Theme.of(context).colorScheme.primary,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 300,
                    ),
                    onQRViewCreated: (controller) {
                      this.controller = controller;
                      controller.scannedDataStream.listen((scanData) {
                        if (qrid != null) {
                          // Already scanned a QR code, so ignore this one:
                          return;
                        }
                        qrid = scanData.code;
                        // Pop the page, and pass the QRID back to the previous page:
                        Navigator.pop(context, qrid);
                      });
                    },
                  );
                } else {
                  // Permission not granted, so show a message:
                  return const Center(
                    child: Text("Camera permission not granted."),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     // Go back to the previous page, and pass the QRID back to it:
                //     Navigator.pop(context, "1234567890");
                //   },
                //   child: const Text("Use QRID"),
                // ),
                // Cancel button
                IconButton(
                  onPressed: () {
                    // Go back to the previous page, and pass the QRID back to it:
                    Navigator.pop(context, null);
                  },
                  icon: const Icon(Icons.cancel),
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () async {
                    await controller?.toggleFlash();
                    setState(() {});
                  },
                  icon: FutureBuilder(
                    future: controller?.getFlashStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return const Icon(Icons.flash_on);
                      } else {
                        return const Icon(Icons.flash_off);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () async {
                    await controller?.flipCamera();
                    setState(() {});
                  },
                  icon: FutureBuilder(
                    future: controller?.getCameraInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.data == CameraFacing.back) {
                        return const Icon(Icons.camera_rear);
                      } else {
                        return const Icon(Icons.camera_front);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      }
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

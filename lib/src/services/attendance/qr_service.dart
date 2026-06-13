import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_image_decoder.dart';
import '../../models/attendance/attendance_session_model.dart';

class QrService {
  QrService() : _scannerController = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
  );

  final MobileScannerController _scannerController;
  final ImagePicker _imagePicker = ImagePicker();

  void dispose() => _scannerController.dispose();

  String generatePayload(ScannedSessionData session) => session.toQrPayload();

  Future<String?> decodeFromImagePath(String imagePath) async {
    final capture = await _scannerController.analyzeImage(imagePath);
    if (capture?.barcodes.isNotEmpty == true) {
      return capture!.barcodes.first.rawValue;
    }
    return null;
  }

  Future<String?> decodeFromBytes(Uint8List bytes) =>
      QrImageDecoder.decode(bytes);

  Future<String?> scanFromGallery() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    if (kIsWeb) {
      String? raw;
      final path = picked.path;
      if (path.isNotEmpty) {
        raw = await decodeFromImagePath(path);
      }
      if (raw == null || raw.trim().isEmpty) {
        final bytes = await picked.readAsBytes();
        raw = await decodeFromBytes(bytes);
      }
      return raw;
    }

    final path = picked.path;
    if (path.isEmpty) return null;
    return decodeFromImagePath(path);
  }
}

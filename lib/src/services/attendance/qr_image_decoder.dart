import 'dart:typed_data';

import 'qr_image_decoder_stub.dart'
    if (dart.library.html) 'qr_image_decoder_web.dart';

abstract class QrImageDecoder {
  static Future<String?> decode(Uint8List bytes) => decodeQrFromImage(bytes);
}

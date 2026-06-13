import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

@JS('BarcodeDetector')
extension type _BarcodeDetector._(JSObject _) implements JSObject {
  external factory _BarcodeDetector(JSObject options);
  external JSPromise<JSArray<_BarcodeResult>> detect(web.HTMLImageElement image);
}

extension type _BarcodeResult._(JSObject _) implements JSObject {
  external JSString get rawValue;
}

Future<String?> decodeQrFromImage(Uint8List bytes) async {
  final ctor = globalContext.getProperty<JSAny?>('BarcodeDetector'.toJS);
  if (ctor == null) return null;

  try {
    final options = {'formats': ['qr_code']}.jsify()! as JSObject;
    final detector = _BarcodeDetector(options);

    final blobParts = <JSAny>[bytes.toJS].toJS;
    final blob = web.Blob(blobParts);
    final imageUrl = web.URL.createObjectURL(blob);
    final image = web.HTMLImageElement();

    final loadCompleter = Completer<void>();
    final loadListener = ((web.Event _) => loadCompleter.complete()).toJS;
    image.addEventListener('load', loadListener);
    image.src = imageUrl;

    try {
      await loadCompleter.future.timeout(const Duration(seconds: 10));
      final results = await detector.detect(image).toDart;
      if (results.length == 0) return null;
      return results.toDart.first.rawValue.toDart;
    } finally {
      image.removeEventListener('load', loadListener);
      web.URL.revokeObjectURL(imageUrl);
    }
  } catch (_) {
    return null;
  }
}

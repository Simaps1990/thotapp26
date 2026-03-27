import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

abstract interface class WebDocumentOpenerImpl {
  /// IMPORTANT (Safari): keep the `window.open(...)` call in the same user
  /// gesture tick. Even an `await` (microtask) before `window.open` can cause
  /// Safari to open a blank tab or fail with `WebKitBlobResourceError 1`.
  static Future<void> openDataUrlInNewTab(String dataUrl, {String windowName = '_blank'}) {
    try {
      final objectUrl = createObjectUrlFromDataUrlSync(dataUrl);
      web.window.open(objectUrl, windowName);

      // Safari: don't revoke immediately, give it time to load.
      Timer(const Duration(minutes: 2), () {
        try {
          web.URL.revokeObjectURL(objectUrl);
        } catch (e) {
          debugPrint('Failed to revoke object URL: $e');
        }
      });

      return Future.value();
    } catch (e) {
      return Future.error(e);
    }
  }

  static String createObjectUrlFromDataUrlSync(String dataUrl) {
    final trimmed = dataUrl.trim();
    if (!trimmed.startsWith('data:')) {
      throw ArgumentError('Expected a data: URL');
    }

    final commaIndex = trimmed.indexOf(',');
    if (commaIndex <= 0 || commaIndex >= trimmed.length - 1) {
      throw const FormatException('Invalid data URL');
    }

    final meta = trimmed.substring(5, commaIndex); // after "data:"
    final payload = trimmed.substring(commaIndex + 1);

    final isBase64 = meta.toLowerCase().contains(';base64');
    if (!isBase64) {
      throw UnsupportedError('Only base64 data URLs are supported');
    }

    final mime = meta.split(';').first.trim().isEmpty ? 'application/octet-stream' : meta.split(';').first.trim();

    Uint8List bytes;
    try {
      bytes = base64Decode(payload);
    } catch (e) {
      debugPrint('Failed to base64Decode data URL payload: $e');
      rethrow;
    }

    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: mime),
    );
    final objectUrl = web.URL.createObjectURL(blob);

    return objectUrl;
  }

  static Future<String> createObjectUrlFromDataUrl(String dataUrl) {
    try {
      return Future.value(createObjectUrlFromDataUrlSync(dataUrl));
    } catch (e) {
      return Future.error(e);
    }
  }
}

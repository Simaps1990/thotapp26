import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

abstract interface class WebTextExporterImpl {
  static Future<void> downloadTextFile({required String filename, required String content}) {
    try {
      final normalizedName =
          filename.trim().isEmpty ? 'export.txt' : filename.trim();
      final bytes = utf8.encode(content);
      final blob = web.Blob(
        [bytes.toJS].toJS,
        web.BlobPropertyBag(type: 'text/plain;charset=utf-8'),
      );
      final url = web.URL.createObjectURL(blob);

      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = normalizedName
        ..style.display = 'none';

      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      // Give the browser a tick before revoking.
      Timer(const Duration(seconds: 2), () {
        try {
          web.URL.revokeObjectURL(url);
        } catch (e) {
          debugPrint('Failed to revoke text export URL: $e');
        }
      });

      return Future.value();
    } catch (e) {
      debugPrint('Failed to download text file: $e');
      return Future.error(e);
    }
  }
}

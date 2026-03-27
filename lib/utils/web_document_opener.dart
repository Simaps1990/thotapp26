import 'package:thot/utils/web_document_opener_stub.dart'
    if (dart.library.html) 'package:thot/utils/web_document_opener_web.dart';

/// Cross-platform helper to open a web-only data URL (base64) as a Blob URL.
///
/// On Safari, opening very large `data:` URLs (especially PDFs) often fails with
/// `WebKitBlobResourceError 1`. Converting to a `blob:` URL avoids that.
abstract interface class WebDocumentOpener {
  /// Opens a base64 `data:` URL (e.g. `data:application/pdf;base64,...`) in a
  /// new tab/window.
  static Future<void> openDataUrlInNewTab(String dataUrl, {String windowName = '_blank'}) =>
      WebDocumentOpenerImpl.openDataUrlInNewTab(dataUrl, windowName: windowName);

  /// Converts a base64 `data:` URL to a `blob:` object URL and returns it.
  ///
  /// This is useful on Safari/iOS where opening or sharing large `data:` URLs
  /// can fail. The returned URL is only valid in the current browser context.
  static Future<String> createObjectUrlFromDataUrl(String dataUrl) =>
      WebDocumentOpenerImpl.createObjectUrlFromDataUrl(dataUrl);
}

/// Non-web stub (Android/iOS/desktop). Kept separate via conditional imports.
abstract interface class WebDocumentOpenerImpl {
  static Future<void> openDataUrlInNewTab(String dataUrl, {String windowName = '_blank'}) async {
    throw UnsupportedError('WebDocumentOpener is only available on web');
  }

  static Future<String> createObjectUrlFromDataUrl(String dataUrl) async {
    throw UnsupportedError('WebDocumentOpener is only available on web');
  }
}

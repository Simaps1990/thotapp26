/// Non-web stub (Android/iOS/desktop). Kept separate via conditional imports.
abstract interface class WebTextExporterImpl {
  static Future<void> downloadTextFile({required String filename, required String content}) async {
    throw UnsupportedError('WebTextExporter is only available on web');
  }
}

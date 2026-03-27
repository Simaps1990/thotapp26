import 'package:thot/utils/web_text_exporter_stub.dart' if (dart.library.html) 'package:thot/utils/web_text_exporter_web.dart';

/// Cross-platform helper to export a text payload as a downloadable `.txt` file.
///
/// On non-web platforms this is unsupported (sharing/copying should be used
/// instead).
abstract interface class WebTextExporter {
  static Future<void> downloadTextFile({required String filename, required String content}) =>
      WebTextExporterImpl.downloadTextFile(filename: filename, content: content);
}

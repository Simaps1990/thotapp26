import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persists user-picked images into the app's sandbox so they survive
/// system cache cleanup, app restarts, and OS updates.
///
/// Why: ImagePicker on iOS returns paths inside `tmp/` which is regularly
/// purged by the OS. Using these paths directly leads to "broken image"
/// states days/weeks later. This helper copies the file into a stable
/// location under `Documents/photos/` and returns the new path.
abstract final class ImageStorage {
  static const String _photosSubdir = 'photos';

  /// Copies the file at [sourcePath] into the app sandbox and returns the
  /// new absolute path. If [sourcePath] is null/empty, already inside the
  /// sandbox photos dir, or a `data:` URL, it is returned unchanged.
  /// Returns null if the source file is missing.
  static Future<String?> persistFromPath(String? sourcePath) async {
    if (sourcePath == null || sourcePath.trim().isEmpty) return sourcePath;
    if (kIsWeb) return sourcePath;
    if (sourcePath.startsWith('data:')) return sourcePath;

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docsDir.path}/$_photosSubdir');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      if (sourcePath.startsWith(photosDir.path)) return sourcePath;

      final source = File(sourcePath);
      if (!await source.exists()) return null;

      final basename = sourcePath.split(Platform.pathSeparator).last;
      final ext = _extension(basename);
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final target = File('${photosDir.path}/img_$stamp$ext');

      await source.copy(target.path);
      return target.path;
    } catch (e) {
      debugPrint('[ImageStorage] persistFromPath failed: $e');
      return sourcePath;
    }
  }

  /// Deletes a previously-persisted image (only files inside the sandbox
  /// photos dir are touched).
  static Future<void> deletePersisted(String? path) async {
    if (path == null || path.isEmpty || kIsWeb) return;
    if (path.startsWith('data:')) return;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docsDir.path}/$_photosSubdir');
      if (!path.startsWith(photosDir.path)) return;
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('[ImageStorage] deletePersisted failed: $e');
    }
  }

  /// Wipes the entire sandbox photos dir. Used by "delete all data".
  static Future<void> wipeAll() async {
    if (kIsWeb) return;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docsDir.path}/$_photosSubdir');
      if (await photosDir.exists()) {
        await photosDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[ImageStorage] wipeAll failed: $e');
    }
  }

  /// Wipes the user_documents dir (PDFs uploaded by the user). Used by
  /// "delete all data".
  static Future<void> wipeUserDocuments() async {
    if (kIsWeb) return;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final userDocsDir = Directory('${docsDir.path}/user_documents');
      if (await userDocsDir.exists()) {
        await userDocsDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[ImageStorage] wipeUserDocuments failed: $e');
    }
  }

  static String _extension(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0 || i == name.length - 1) return '.jpg';
    return name.substring(i).toLowerCase();
  }
}

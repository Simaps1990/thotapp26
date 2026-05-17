import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show debugPrint, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/image_storage.dart';

/// Result of a native picker action.
///
/// One of [path], [bytes] is non-null on success.
/// On cancellation, all fields are null.
class PickedFile {
  final String? path;
  final Uint8List? bytes;
  final String? name;
  final bool isImage;

  const PickedFile._({this.path, this.bytes, this.name, required this.isImage});

  static const PickedFile cancelled = PickedFile._(isImage: false);
  bool get isCancelled => path == null && bytes == null;
}

/// Modes of the unified native picker.
enum PickerMode {
  /// "Take photo" + "Choose photo" + "Cancel".
  photoOnly,

  /// "Take photo" + "Choose photo" + "Choose document" + "Cancel".
  photoOrDocument,
}

/// Native, OS-style picker that asks the user where the file should come
/// from. iOS shows a Cupertino action sheet; Android shows a Material
/// modal bottom sheet.
abstract final class NativePicker {
  /// Opens the picker. Returns [PickedFile.cancelled] if the user dismisses.
  /// On non-cancellation, the file is already persisted in the sandbox
  /// (for images) and the path/bytes are ready to be stored.
  static Future<PickedFile> pick(
    BuildContext context, {
    required PickerMode mode,
  }) async {
    final strings = AppStrings.of(context);

    final source = await _askSource(context, strings, mode);
    if (source == null) return PickedFile.cancelled;

    switch (source) {
      case _PickSource.camera:
        return _pickFromCamera();
      case _PickSource.gallery:
        return _pickFromGallery();
      case _PickSource.document:
        return _pickDocument();
    }
  }

  // --- internal ---

  static Future<_PickSource?> _askSource(
    BuildContext context,
    AppStrings strings,
    PickerMode mode,
  ) async {
    final isIOS = Platform.isIOS;

    if (isIOS) {
      return showCupertinoModalPopup<_PickSource?>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(ctx).pop(_PickSource.camera),
              child: Text(strings.pickerActionTakePhoto),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(ctx).pop(_PickSource.gallery),
              child: Text(strings.pickerActionChoosePhoto),
            ),
            if (mode == PickerMode.photoOrDocument)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(ctx).pop(_PickSource.document),
                child: Text(strings.pickerActionChooseDocument),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.pickerActionCancel),
          ),
        ),
      );
    }

    // Android / Material
    return showModalBottomSheet<_PickSource?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(strings.pickerActionTakePhoto),
              onTap: () => Navigator.of(ctx).pop(_PickSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(strings.pickerActionChoosePhoto),
              onTap: () => Navigator.of(ctx).pop(_PickSource.gallery),
            ),
            if (mode == PickerMode.photoOrDocument)
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(strings.pickerActionChooseDocument),
                onTap: () => Navigator.of(ctx).pop(_PickSource.document),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Future<PickedFile> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera);
      if (file == null) return PickedFile.cancelled;
      final persisted = await ImageStorage.persistFromPath(file.path);
      return PickedFile._(path: persisted, name: file.name, isImage: true);
    } catch (e) {
      debugPrint('[NativePicker] camera failed: $e');
      return PickedFile.cancelled;
    }
  }

  static Future<PickedFile> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return PickedFile.cancelled;
      final persisted = await ImageStorage.persistFromPath(file.path);
      return PickedFile._(path: persisted, name: file.name, isImage: true);
    } catch (e) {
      debugPrint('[NativePicker] gallery failed: $e');
      return PickedFile.cancelled;
    }
  }

  static Future<PickedFile> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return PickedFile.cancelled;
      final f = result.files.single;
      final isImage = [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'heic',
      ].contains((f.extension ?? '').toLowerCase());
      return PickedFile._(
        path: f.path,
        name: f.name,
        isImage: isImage,
      );
    } catch (e) {
      debugPrint('[NativePicker] document failed: $e');
      return PickedFile.cancelled;
    }
  }
}

enum _PickSource { camera, gallery, document }

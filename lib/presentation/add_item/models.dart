part of '../add_item_screen.dart';

class _ItemDocumentDraft {
  _ItemDocumentDraft({required this.name, required this.type, required this.file});

  String name;
  String type;
  PlatformFile file;

  ItemDocument toItemDocument() {
    return ItemDocument(
      path: file.path ?? '',
      name: name.trim().isEmpty ? file.name : name.trim(),
      type: type.trim().isEmpty ? 'Document' : type.trim(),
    );
  }
}

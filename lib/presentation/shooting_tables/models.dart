part of '../shooting_tables_screen.dart';

class _AccessoryPickerResult {
  final Set<String> accessoryIds;
  final List<String> customAccessoryNames;

  const _AccessoryPickerResult({
    required this.accessoryIds,
    required this.customAccessoryNames,
  });
}

enum _TableSort { updatedAt, name, distance }

enum _CorrectionDirection { left, right, up, down }


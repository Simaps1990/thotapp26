import 'package:flutter/services.dart';
import 'package:thot/l10n/app_strings.dart';

/// Returns null (valid) or a localized error string.
class ThotValidators {
  /// Accepts empty (field optional). Rejects non-numeric and negative.
  static String? positiveDouble(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value.trim().replaceAll(',', '.'));
    if (n == null) return strings.fieldInvalidNumber;
    if (n < 0) return strings.fieldMustBePositive;
    return null;
  }

  /// Accepts empty. Rejects non-integer and negative.
  static String? positiveInt(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) return null;
    final n = int.tryParse(value.trim());
    if (n == null) return strings.fieldMustBeInteger;
    if (n < 0) return strings.fieldMustBePositive;
    return null;
  }

  /// Rejects empty, non-numeric, and negative.
  static String? requiredPositiveDouble(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) return strings.fieldRequired;
    return positiveDouble(value, strings);
  }

  /// Accepts empty. Rejects non-numeric and out of 0-100 range.
  static String? humidityRange(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) return null;
  final n = double.tryParse(
    value.trim().replaceAll(',', '.').replaceAll('%', ''),
  );
    if (n == null) return strings.fieldInvalidNumber;
    if (n < 0 || n > 100) return strings.fieldMustBeBetween0And100;
    return null;
  }

  /// Accepts empty. Rejects non-numeric (allows negative for temperature).
  static String? anyDouble(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value.trim().replaceAll(',', '.'));
    if (n == null) return strings.fieldInvalidNumber;
    return null;
  }
}

/// Input formatters for numeric fields.
class ThotInputFormatters {
  /// Allows digits, comma and period for decimal numbers.
  static TextInputFormatter get decimal =>
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

  /// Allows only digits for integers.
  static TextInputFormatter get integer =>
      FilteringTextInputFormatter.digitsOnly;
}

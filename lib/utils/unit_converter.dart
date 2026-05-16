/// Unit conversion + formatting helper for THOT.
///
/// Two construction modes:
///
/// 1. Legacy: `UnitConverter(useMetric)` — single bool flips ALL units
///    metric/imperial. Kept for backward compat with existing call sites.
/// 2. Granular: `UnitConverter.granular(weight, distance, velocity, useMetric)`
///    — respects per-unit preferences set in Settings (weightUnit /
///    distanceUnit / velocityUnit dropdowns).
///
/// Temperature & wind speed currently follow `useMetric` only because
/// the app does not expose granular settings for those yet.

class UnitConverter {
  /// Legacy global flag. True = metric, false = imperial.
  final bool useMetric;

  /// Granular preferences. When null, falls back to `useMetric` for that
  /// dimension. Strings are kept loose ('meter'/'yard', 'gram'/'grain'/
  /// 'ounce', 'metersPerSecond'/'feetPerSecond') to avoid pulling the
  /// model enum here and creating a circular dependency.
  final String? _weightUnit;
  final String? _distanceUnit;
  final String? _velocityUnit;

  UnitConverter(this.useMetric)
      : _weightUnit = null,
        _distanceUnit = null,
        _velocityUnit = null;

  /// Granular converter. Pass enum.name values from the provider:
  ///   - weightUnit:  'gram' | 'grain' | 'ounce'
  ///   - distanceUnit:'meter' | 'yard'
  ///   - velocityUnit:'metersPerSecond' | 'feetPerSecond'
  UnitConverter.granular({
    required this.useMetric,
    String? weightUnit,
    String? distanceUnit,
    String? velocityUnit,
  })  : _weightUnit = weightUnit,
        _distanceUnit = distanceUnit,
        _velocityUnit = velocityUnit;

  // ── Distance ──────────────────────────────────────────────────────

  /// True if distances should be rendered in yards.
  bool get _useYards {
    if (_distanceUnit != null) return _distanceUnit == 'yard';
    return !useMetric;
  }

  String formatDistance(int meters) {
    if (_useYards) {
      final yards = (meters * _kMetersToYards).round();
      return '$yards yd';
    }
    return '$meters m';
  }

  int parseDistance(String distanceStr) {
    final numStr = distanceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = int.tryParse(numStr) ?? 0;

    final lower = distanceStr.toLowerCase();
    final hasYd = lower.contains('yd');
    final hasM = RegExp(r'\bm\b|meter|mètre').hasMatch(lower);

    // Explicit unit in the string always wins.
    if (hasYd) return (value / _kMetersToYards).round();
    if (hasM) return value;

    // No explicit unit: interpret according to the user's preference.
    if (_useYards) return (value / _kMetersToYards).round();
    return value;
  }

  String get distanceUnit => _useYards ? 'yd' : 'm';

  // ── Weight ────────────────────────────────────────────────────────

  /// 'gram' (default), 'grain' or 'ounce'.
  String get _activeWeightUnit {
    if (_weightUnit != null) return _weightUnit!;
    return useMetric ? 'gram' : 'ounce';
  }

  String formatWeight(double grams) {
    switch (_activeWeightUnit) {
      case 'grain':
        return '${(grams * _kGramsToGrains).toStringAsFixed(1)} gr';
      case 'ounce':
        return '${(grams * _kGramsToOunces).toStringAsFixed(2)} oz';
      case 'gram':
      default:
        return '${grams.toStringAsFixed(1)} g';
    }
  }

  String get weightUnit {
    switch (_activeWeightUnit) {
      case 'grain':
        return 'gr';
      case 'ounce':
        return 'oz';
      case 'gram':
      default:
        return 'g';
    }
  }

  // ── Velocity ──────────────────────────────────────────────────────

  /// 'metersPerSecond' (default) or 'feetPerSecond'.
  String get _activeVelocityUnit {
    if (_velocityUnit != null) return _velocityUnit!;
    return useMetric ? 'metersPerSecond' : 'feetPerSecond';
  }

  String formatVelocity(double mps) {
    if (_activeVelocityUnit == 'feetPerSecond') {
      return '${(mps * _kMpsToFps).toStringAsFixed(0)} fps';
    }
    return '${mps.toStringAsFixed(0)} m/s';
  }

  String get velocityUnit =>
      _activeVelocityUnit == 'feetPerSecond' ? 'fps' : 'm/s';

  // ── Temperature ───────────────────────────────────────────────────
  // Temperature is still tied to `useMetric` because there's no
  // dedicated dropdown yet.

  String formatTemperature(double celsius) {
    if (useMetric) {
      return '${celsius.toInt()}°C';
    }
    final fahrenheit = (celsius * 9 / 5 + 32).round();
    return '$fahrenheit°F';
  }

  String parseTemperatureString(String tempStr) =>
      formatTemperature(parseTemperature(tempStr));

  double parseTemperature(String tempStr) {
    final numStr = tempStr.replaceAll(RegExp(r'[^0-9.\-]'), '');
    final value = double.tryParse(numStr) ?? 20;
    final lower = tempStr.toLowerCase();
    if (lower.contains('°f') || lower.contains(' f') || lower.endsWith('f')) {
      return (value - 32) * 5 / 9;
    }
    return value;
  }

  String get temperatureUnit => useMetric ? '°C' : '°F';

  // ── Wind speed ────────────────────────────────────────────────────

  String formatWindSpeed(double kmh) {
    if (useMetric) {
      return '${kmh.toInt()} km/h';
    }
    final mph = (kmh * _kKmhToMph).round();
    return '$mph mph';
  }

  String parseWindSpeedString(String windStr) =>
      formatWindSpeed(parseWindSpeed(windStr));

  double parseWindSpeed(String windStr) {
    final numStr = windStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numStr) ?? 0;
    if (windStr.toLowerCase().contains('mph')) {
      return value / _kKmhToMph;
    }
    return value;
  }

  String get windSpeedUnit => useMetric ? 'km/h' : 'mph';

  // ── Pressure ──────────────────────────────────────────────────────

  String formatPressure(double hPa) {
    if (useMetric) {
      return '${hPa.toInt()} hPa';
    }
    final inHg = (hPa * _kHpaToInHg).toStringAsFixed(2);
    return '$inHg inHg';
  }

  String parsePressureString(String pressureStr) =>
      formatPressure(parsePressure(pressureStr));

  double parsePressure(String pressureStr) {
    final numStr = pressureStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numStr) ?? 1013;
    if (pressureStr.toLowerCase().contains('inhg')) {
      return value / _kHpaToInHg;
    }
    return value;
  }

  String get pressureUnit => useMetric ? 'hPa' : 'inHg';
}

// ── Conversion constants ────────────────────────────────────────────
// Centralised so a future fix (e.g. higher precision) lands in one
// place instead of scattered magic numbers.

const double _kMetersToYards = 1.09361;
const double _kKmhToMph = 0.621371;
const double _kHpaToInHg = 0.02953;
const double _kMpsToFps = 3.28084;
const double _kGramsToGrains = 15.4324;
const double _kGramsToOunces = 0.035274;

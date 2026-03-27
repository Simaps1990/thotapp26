class UnitConverter {
  final bool useMetric;

  UnitConverter(this.useMetric);

  // Distance conversions
  String formatDistance(int meters) {
    if (useMetric) {
      return '${meters}m';
    } else {
      // Convert meters to yards
      final yards = (meters * 1.09361).round();
      return '${yards}yd';
    }
  }

  int parseDistance(String distanceStr) {
    // Remove unit and parse number
    final numStr = distanceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = int.tryParse(numStr) ?? 0;
    
    if (distanceStr.toLowerCase().contains('yd')) {
      // Convert yards to meters
      return (value / 1.09361).round();
    }
    return value;
  }

  // Weight conversions
  String formatWeight(double grams) {
    if (useMetric) {
      return '${grams.toInt()}g';
    } else {
      // Convert grams to ounces
      final ounces = (grams * 0.035274).toStringAsFixed(2);
      return '${ounces}oz';
    }
  }

  double parseWeight(String weightStr) {
    final numStr = weightStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numStr) ?? 0;
    
    if (weightStr.toLowerCase().contains('oz')) {
      // Convert ounces to grams
      return value / 0.035274;
    }
    return value;
  }

  // Temperature conversions
  String formatTemperature(double celsius) {
    if (useMetric) {
      return '${celsius.toInt()}°C';
    } else {
      // Convert Celsius to Fahrenheit
      final fahrenheit = (celsius * 9 / 5 + 32).round();
      return '$fahrenheit°F';
    }
  }

  String parseTemperatureString(String tempStr) {
    // Extract just the number from strings like "22°C"
    final numStr = tempStr.replaceAll(RegExp(r'[^0-9.-]'), '');
    final value = double.tryParse(numStr) ?? 20;
    return formatTemperature(value);
  }

  double parseTemperature(String tempStr) {
    final numStr = tempStr.replaceAll(RegExp(r'[^0-9.-]'), '');
    final value = double.tryParse(numStr) ?? 20;
    
    if (tempStr.contains('°F') || tempStr.toLowerCase().contains('f')) {
      // Convert Fahrenheit to Celsius
      return (value - 32) * 5 / 9;
    }
    return value;
  }

  // Wind speed conversions
  String formatWindSpeed(double kmh) {
    if (useMetric) {
      return '${kmh.toInt()} km/h';
    } else {
      // Convert km/h to mph
      final mph = (kmh * 0.621371).round();
      return '$mph mph';
    }
  }

  String parseWindSpeedString(String windStr) {
    final numStr = windStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numStr) ?? 0;
    return formatWindSpeed(value);
  }

  double parseWindSpeed(String windStr) {
    final numStr = windStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numStr) ?? 0;
    
    if (windStr.toLowerCase().contains('mph')) {
      // Convert mph to km/h
      return value / 0.621371;
    }
    return value;
  }

  // Pressure conversions
  String formatPressure(double hPa) {
    if (useMetric) {
      return '${hPa.toInt()} hPa';
    } else {
      // Convert hPa to inHg (inches of mercury)
      final inHg = (hPa * 0.02953).toStringAsFixed(2);
      return '$inHg inHg';
    }
  }

  String parsePressureString(String pressureStr) {
    final numStr = pressureStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numStr) ?? 1013;
    return formatPressure(value);
  }

  double parsePressure(String pressureStr) {
    final numStr = pressureStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numStr) ?? 1013;
    
    if (pressureStr.toLowerCase().contains('inhg')) {
      // Convert inHg to hPa
      return value / 0.02953;
    }
    return value;
  }

  // Unit labels for UI
  String get distanceUnit => useMetric ? 'm' : 'yd';
  String get weightUnit => useMetric ? 'g' : 'oz';
  String get temperatureUnit => useMetric ? '°C' : '°F';
  String get windSpeedUnit => useMetric ? 'km/h' : 'mph';
  String get pressureUnit => useMetric ? 'hPa' : 'inHg';
}

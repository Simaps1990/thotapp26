part of '../add_item_screen.dart';

extension _AddItemLocalizedOptions on _AddItemScreenState {
  String get _trackingAccessoryType => _isAccessoryTypeCustom
      ? _typeController.text.trim()
      : _selectedAccessoryType;

  bool _canTrackAccessoryWear(String type) {
    return AccessoryTypeKey.wearEnabled.contains(type);
  }

  bool _canTrackAccessoryCleanliness(String type) {
    return AccessoryTypeKey.cleanlinessEnabled.contains(type);
  }

  bool _canTrackAccessoryBattery(String type) {
    return AccessoryTypeKey.batteryEnabled.contains(type);
  }

  bool _shouldShowTrackingOptions() {
    if (_selectedCategory == 'PLATEFORME' || _selectedCategory == 'CONSOMMABLE') {
      return true;
    }
    if (_selectedCategory != 'ACCESSOIRE') return false;
    final type = _trackingAccessoryType;
    return _canTrackAccessoryBattery(type) ||
        _canTrackAccessoryWear(type) ||
        _canTrackAccessoryCleanliness(type);
  }

  void _applyRecommendedMaintenancePresetIfDefault() {
    if (_selectedCategory != 'PLATEFORME') return;
    if (_cleaningRoundsThresholdController.text.trim().isEmpty) {
      _cleaningRoundsThresholdController.text = '500';
    }
    if (_wearRoundsThresholdController.text.trim().isEmpty) {
      _wearRoundsThresholdController.text = '10000';
    }
  }
}

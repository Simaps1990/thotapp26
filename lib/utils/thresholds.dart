/// Business thresholds used across the app.
/// Replace hardcoded magic numbers in provider/service logic with these.
abstract final class Thresholds {
  /// Maintenance progress at which the UI shows a "soon" warning (0.0–1.0).
  static const double maintenanceWarningRatio = 0.8;

  /// Days without use before a platform/ammo shows the "inactive" badge.
  static const int inactiveDays = 90;

  /// Stock ratio below which the "low stock" badge appears (remaining/initial).
  static const double lowStockRatio = 0.2;

  /// PIN lockout duration after [pinMaxAttempts] failed attempts (minutes).
  static const int pinLockoutMinutes = 30;

  /// Failed PIN attempts before lockout triggers.
  static const int pinMaxAttempts = 5;
}

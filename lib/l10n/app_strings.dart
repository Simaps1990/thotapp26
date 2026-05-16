import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/l10n/app_strings_diagnostic.dart';

part 'app_strings_achievements.dart';
part 'app_strings_home.dart';
part 'app_strings_settings.dart';
part 'app_strings_exercise_steps.dart';
part 'app_strings_sessions.dart';
part 'app_strings_new_session.dart';
part 'app_strings_inventory.dart';
part 'app_strings_tutorial.dart';
part 'app_strings_training_tools.dart';
part 'app_strings_ballistics.dart';
part 'app_strings_reflexes.dart';
part 'app_strings_pro.dart';
part 'app_strings_timer.dart';
part 'app_strings_common.dart';
part 'app_strings_millieme.dart';
part 'app_strings_shooting_tables.dart';
part 'app_strings_navigation.dart';
part 'app_strings_export.dart';
part 'app_strings_standard_drills.dart';
part 'app_strings_templates.dart';
part 'app_strings_home_screen.dart';
part 'app_strings_pin.dart';
part 'app_strings_colorpod.dart';
part 'app_strings_misc.dart';
part 'app_strings_legal.dart';
part 'app_strings_material_types.dart';
part 'app_strings_pdf.dart';

/// Simple in-app string provider for manual i18n.
///
/// We key on languageCode only (fr, en, de, it, es) and fall back to fr.
class AppStrings {
  final String languageCode;

  AppStrings._(this.languageCode);

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('de'),
    Locale('it'),
    Locale('es'),
  ];

  static AppStrings? maybeOf(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings);
  }

  static AppStrings of(BuildContext context) {
    return maybeOf(context) ??
        AppStrings.forLocale(Localizations.localeOf(context));
  }

  static AppStrings forLocale(Locale locale) {
    final code = locale.languageCode;
    final resolved = supportedLocales.any((l) => l.languageCode == code)
        ? code
        : 'en';
    AppStringsDiagnostic.setLanguageCode(resolved);
    return AppStrings._(resolved);
  }

  bool get _isFr => languageCode == 'fr' || languageCode.isEmpty;
  bool get _isEn => languageCode == 'en';
  bool get _isDe => languageCode == 'de';
  bool get _isIt => languageCode == 'it';
  bool get _isEs => languageCode == 'es';

  String _pick({
    required String fr,
    required String en,
    required String de,
    required String it,
    required String es,
  }) {
    if (_isFr) return fr;
    if (_isEn) return en;
    if (_isDe) return de;
    if (_isIt) return it;
    if (_isEs) return es;
    return fr;
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(AppStrings.forLocale(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}

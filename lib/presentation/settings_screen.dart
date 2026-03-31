import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'dart:convert';

import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/utils/web_document_opener.dart';
import 'package:thot/utils/pdf_exporter.dart';
import 'package:thot/utils/pdf_export_options.dart';
import 'package:thot/l10n/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    try {
      return name
          .split(' ')
          .where((n) => n.isNotEmpty)
          .take(2)
          .map((n) => n[0])
          .join('')
          .toUpperCase();
    } catch (e) {
      return "?";
    }
  }

  Future<void> _showContactDialog(BuildContext context) async {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.contactMeLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.handshake_outlined),
              title: Text(strings.contactPartnership),
              onTap: () {
                Navigator.pop(ctx);
                _launchEmail(subject: strings.contactSubjectPartnership);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(strings.contactSupport),
              onTap: () {
                Navigator.pop(ctx);
                _launchEmail(subject: strings.contactSubjectSupport);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.settingsDialogCancel),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail({required String subject}) async {
    const to = 'simapswebdesign@gmail.com';
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        'subject': subject,
      },
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  SwitchThemeData _buildUnifiedSwitchTheme(
    BuildContext context,
    ColorScheme colors,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(alpha: isDark ? 0.45 : 0.35);
        }
        return colors.outline.withValues(alpha: 0.35);
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.onPrimary;
        }
        return isDark
            ? colors.onSurface.withValues(alpha: 0.70)
            : colors.secondary.withValues(alpha: 0.85);
      }),
    );
  }

  List<Widget> _buildHeaderSection({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    return [
      const Gap(AppSpacing.lg),
    ];
  }

  Widget _buildProfileGroup({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required String displayName,
    required String licenseSubtitle,
  }) {
    final strings = AppStrings.of(context);
    return _SettingsGroup(
      title: strings.profileGroupTitle,
      children: [
        _SettingsItem(
          icon: Icons.person_outline_rounded,
          label: displayName,
          subtitle: licenseSubtitle,
          onTap: () => _showEditProfileDialog(context, provider),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.description_outlined,
          label: strings.settingsDocumentsLabel,
          subtitle: strings.settingsDocumentsCount(provider.userDocuments.length),
          onTap: () => _showDocumentsDialog(context, provider),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesGroup({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    final switchTheme = _buildUnifiedSwitchTheme(context, colors);

    return _SettingsGroup(
      title: strings.preferencesGroupTitle,
      children: [
        _SettingsItem(
          icon: Icons.dark_mode_rounded,
          label: strings.darkModeLabel,
          subtitle: strings.darkModeSubtitle,
          trailing: SwitchTheme(
            data: switchTheme,
            child: Switch(
              value: provider.themeMode == ThemeMode.dark,
              onChanged: (val) => provider.toggleTheme(),
              activeColor: colors.primary,
            ),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.language_rounded,
          label: strings.appLanguageLabel,
          subtitle: null,
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              alignment: Alignment.centerRight,
              value: provider.localeCode?.isEmpty == true
                  ? null
                  : provider.localeCode,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.appLanguageSystem),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'fr',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.appLanguageFrench),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'en',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.appLanguageEnglish),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'de',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.appLanguageGerman),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'it',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.appLanguageItalian),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'es',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.appLanguageSpanish),
                  ),
                ),
              ],
              onChanged: (code) {
                provider.setLocaleCode(code);
              },
              icon: Icon(Icons.arrow_drop_down, color: colors.secondary),
              style: textStyles.bodyMedium?.copyWith(color: colors.onSurface),
            ),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.square_foot_rounded,
          label: strings.unitsLabel,
          subtitle: null,
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              value: provider.useMetric,
              items: [
                DropdownMenuItem(
                  value: true,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.unitsMetric),
                  ),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.unitsImperial),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  provider.setUnitSystem(val);
                }
              },
              icon: Icon(Icons.arrow_drop_down, color: colors.secondary),
              style: textStyles.bodyMedium?.copyWith(color: colors.onSurface),
            ),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.calendar_month_rounded,
          label: strings.dateFormatLabel,
          subtitle: null,
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.dateFormatPreference,
              items: [
                DropdownMenuItem(
                  value: 'day_month_year',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.dateFormatDayMonthYear),
                  ),
                ),
                DropdownMenuItem(
                  value: 'month_day_year',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(strings.dateFormatMonthDayYear),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  provider.setDateFormatPreference(val);
                }
              },
              icon: Icon(Icons.arrow_drop_down, color: colors.secondary),
              style: textStyles.bodyMedium?.copyWith(color: colors.onSurface),
            ),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.shield_rounded,
          label: strings.backupLabel,
          subtitle: strings.backupSubtitle,
          trailing: Icon(
            Icons.check_circle_rounded,
            color: colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSection({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    final yearlyPrice = provider.yearlyPrice;
    final monthlyPrice = provider.monthlyPrice;

    String _buildBannerPrice() {
      final hasYearly = yearlyPrice != null && yearlyPrice.trim().isNotEmpty;
      final hasMonthly = monthlyPrice != null && monthlyPrice.trim().isNotEmpty;

      if (hasYearly && hasMonthly) {
        return '$yearlyPrice • $monthlyPrice';
      } else if (hasYearly) {
        return yearlyPrice!.trim();
      } else if (hasMonthly) {
        return monthlyPrice!.trim();
      }

      return strings.premiumBannerPrice;
    }

    if (!provider.isPremium) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3F4A30),
              Color(0xFF6E7C4A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showProModal(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.premiumBannerTitle,
                              style: textStyles.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              _buildBannerPrice(),
                              style: textStyles.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PremiumFeature(strings.proBenefitUnlimitedSessionsTitle),
                        _PremiumFeature(strings.proBenefitUnlimitedEquipmentTitle),
                        _PremiumFeature(strings.proBenefitTimerTitle),
                        _PremiumFeature(strings.proBenefitDiagnosticTitle),
                        _PremiumFeature(strings.proBenefitMilliemeTitle),
                        _PremiumFeature(strings.proBenefitLogbookExportTitle),
                        _PremiumFeature(strings.proBenefitUnlimitedDocumentsTitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: _SettingsGroup(
        title: strings.proGroupTitle,
        children: [
          _SettingsItem(
            icon: Icons.manage_accounts_rounded,
            label: strings.proManageLabel,
            subtitle: strings.proManageSubtitle,
            trailing: Icon(
              Icons.open_in_new_rounded,
              color: colors.secondary,
              size: 20,
            ),
            onTap: () async {
              try {
                await RevenueCatUI.presentCustomerCenter();
              } catch (e) {
                debugPrint('Customer Center unavailable.');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsGroup({
    required BuildContext context,
    required ThotProvider provider,
  }) {
    final strings = AppStrings.of(context);
    final switchTheme = _buildUnifiedSwitchTheme(
      context,
      Theme.of(context).colorScheme,
    );

    return _SettingsGroup(
      title: strings.shortcutsGroupTitle,
      children: [
        _ShortcutToggle(
          iconBuilder: (c) =>
              Icon(Icons.add_circle_outline_rounded, color: c, size: 22),
          label: strings.shortcutNewSession,
          actionId: 'new_session',
          enabled: provider.quickActions.contains('new_session'),
          onChanged: (val) => provider.toggleQuickAction('new_session'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
        const Divider(indent: 48, height: 1),
        _ShortcutToggle(
          iconBuilder: (c) => SvgPicture.asset(
            'assets/images/gun.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
          ),
          label: strings.shortcutNewWeapon,
          actionId: 'new_weapon',
          enabled: provider.quickActions.contains('new_weapon'),
          onChanged: (val) => provider.toggleQuickAction('new_weapon'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
        const Divider(indent: 48, height: 1),
        _ShortcutToggle(
          iconBuilder: (c) => SvgPicture.asset(
            'assets/images/bullet.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
          ),
          label: strings.shortcutNewAmmo,
          actionId: 'new_ammo',
          enabled: provider.quickActions.contains('new_ammo'),
          onChanged: (val) => provider.toggleQuickAction('new_ammo'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
        const Divider(indent: 48, height: 1),
        _ShortcutToggle(
          iconBuilder: (c) =>
              Icon(Icons.inventory_2_rounded, color: c, size: 22),
          label: strings.shortcutNewAccessory,
          actionId: 'new_accessory',
          enabled: provider.quickActions.contains('new_accessory'),
          onChanged: (val) => provider.toggleQuickAction('new_accessory'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
        const Divider(indent: 48, height: 1),
        _ShortcutToggle(
          iconBuilder: (c) => Icon(Icons.dark_mode_rounded, color: c, size: 22),
          label: strings.shortcutToggleTheme,
          actionId: 'toggle_theme',
          enabled: provider.quickActions.contains('toggle_theme'),
          onChanged: (val) => provider.toggleQuickAction('toggle_theme'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
        const Divider(indent: 48, height: 1),
        _ShortcutToggle(
          iconBuilder: (c) =>
              Icon(Icons.medical_services_outlined, color: c, size: 22),
          label: strings.quickActionLabelDiagnostic,
          actionId: 'diagnostic',
          enabled: provider.quickActions.contains('diagnostic'),
          onChanged: (val) => provider.toggleQuickAction('diagnostic'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
        const Divider(indent: 48, height: 1),
        _ShortcutToggle(
          iconBuilder: (c) =>
              Icon(Icons.straighten_rounded, color: c, size: 22),
          label: strings.quickActionLabelMillieme,
          actionId: 'millieme',
          enabled: provider.quickActions.contains('millieme'),
          onChanged: (val) => provider.toggleQuickAction('millieme'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
        const Divider(indent: 48, height: 1),
        _ShortcutToggle(
          iconBuilder: (c) => Icon(Icons.timer_rounded, color: c, size: 22),
          label: strings.shortcutTimer,
          actionId: 'timer',
          enabled: provider.quickActions.contains('timer'),
          onChanged: (val) => provider.toggleQuickAction('timer'),
          maxReached: provider.quickActions.length >= 4,
          switchTheme: switchTheme,
        ),
      ],
    );
  }

  Widget _buildSecurityGroup({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
  }) {
    final strings = AppStrings.of(context);
    final switchTheme = _buildUnifiedSwitchTheme(context, colors);

    return _SettingsGroup(
      title: strings.securityGroupTitle,
      children: [
        _SettingsItem(
          icon: Icons.pin_outlined,
          label: strings.pinCodeLabel,
          subtitle:
              provider.pinEnabled ? strings.statusEnabled : strings.statusDisabled,
          trailing: SwitchTheme(
            data: switchTheme,
            child: Switch(
              value: provider.pinEnabled,
              onChanged: (val) async {
                if (val) {
                  context.push('/set-pin');
                } else {
                  await provider.togglePinEnabled(false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.pinDisabledSnack)),
                    );
                  }
                }
              },
              activeColor: colors.primary,
            ),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.fingerprint_rounded,
          label: strings.biometricLabel,
          subtitle: provider.biometricEnabled
              ? strings.statusEnabled
              : strings.statusDisabled,
          trailing: SwitchTheme(
            data: switchTheme,
            child: Switch(
              value: provider.biometricEnabled,
              onChanged: (val) async {
                if (val && !provider.pinEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.biometricRequiresPinSnack),
                    ),
                  );
                  return;
                }
                await provider.toggleBiometricEnabled(val);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        strings.biometricStatusChangedSnack(val),
                      ),
                    ),
                  );
                }
              },
              activeColor: colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportGroup({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
  }) {
    final strings = AppStrings.of(context);
    return _SettingsGroup(
      title: strings.supportGroupTitle,
      children: [
        _SettingsItem(
          icon: Icons.picture_as_pdf_rounded,
          label: strings.exportPdfLabel,
          subtitle: provider.isPremium
              ? strings.exportPdfSubtitlePremium
              : strings.exportPdfSubtitleProOnly,
          onTap: () => _handleExportPdf(context, provider),
          trailing: provider.isPremium
              ? Icon(
                  Icons.download_rounded,
                  color: colors.primary,
                )
              : GestureDetector(
                  onTap: () => context.push('/pro'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: LightColors.surfaceHighlight,
                        width: 1.35,
                      ),
                    ),
                    child: Text(
                      strings.proBadge,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onPrimary,
                          ),
                    ),
                  ),
                ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.lock_outline_rounded,
          label: strings.dataPrivacyLabel,
          subtitle: strings.dataPrivacySubtitle,
          onTap: () => context.push('/legal'),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.info_outline_rounded,
          label: strings.aboutLabel,
          subtitle: strings.aboutSubtitle,
          onTap: () => context.push('/legal'),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.mail_outline_rounded,
          label: strings.contactMeLabel,
          subtitle: strings.contactMeSubtitle,
          onTap: () => _showContactDialog(context),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Divider(indent: 48, height: 1),
        _SettingsItem(
          icon: Icons.delete_forever_rounded,
          label: strings.settingsDeleteAllDataLabel,
          subtitle: strings.settingsDeleteAllDataSubtitle,
          onTap: () => _confirmDeleteAllLocalData(context, provider),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteAllLocalData(BuildContext context, ThotProvider provider) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.settingsDeleteAllDataTitle),
        content: Text(strings.settingsDeleteAllDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.settingsDialogCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await provider.clearAllLocalData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.settingsDeleteAllDataSuccess)),
                );
              }
            },
            child: Text(strings.settingsDeleteAllDataConfirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    const heroHeight = 208.0;
    const panelTop = 120.0;

    final displayName = provider.userName.trim().isEmpty
        ? strings.settingsAnonymousUser
        : provider.userName;
    final license = provider.licenseNumber.trim();
    final licenseSubtitle = license.isEmpty
        ? strings.settingsLicenseNotProvided
        : strings.settingsLicenseNumber(license);

    return Scaffold(
      backgroundColor: baseBackground,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/carnet.webp', // Use carnet.webp
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.16),
                            Colors.black.withValues(alpha: 0.42),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                top: panelTop - 44,
                child: Text(
                  strings.settingsTitle,
                  style: textStyles.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: AppSpacing.lg,
                top: MediaQuery.of(context).padding.top + 12,
                child: TextButton(
                  onPressed: () => _showEditProfileDialog(context, provider),
                  child: Text(
                    _getInitials(
                      provider.userName.trim().isEmpty
                          ? strings.settingsAnonymousUserUpper
                          : provider.userName,
                    ),
                    style: textStyles.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: panelTop),
                decoration: BoxDecoration(
                  color: baseBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._buildHeaderSection(
                        context: context,
                        provider: provider,
                        colors: colors,
                        textStyles: textStyles,
                      ),
                      _buildProfileGroup(
                        context: context,
                        provider: provider,
                        colors: colors,
                        displayName: displayName,
                        licenseSubtitle: licenseSubtitle,
                      ),
                      const Gap(AppSpacing.lg),
                      _buildPreferencesGroup(
                        context: context,
                        provider: provider,
                        colors: colors,
                        textStyles: textStyles,
                      ),
                      const Gap(AppSpacing.lg),
                      _buildPremiumSection(
                        context: context,
                        provider: provider,
                        colors: colors,
                        textStyles: textStyles,
                      ),
                      _buildShortcutsGroup(
                        context: context,
                        provider: provider,
                      ),
                      const Gap(AppSpacing.lg),
                      _buildSecurityGroup(
                        context: context,
                        provider: provider,
                        colors: colors,
                      ),
                      const Gap(AppSpacing.lg),
                      _buildSupportGroup(
                        context: context,
                        provider: provider,
                        colors: colors,
                      ),
                      const Gap(AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ThotProvider provider) {
    final nameController = TextEditingController(text: provider.userName);
    final licenseController = TextEditingController(text: provider.licenseNumber);
    final emailController = TextEditingController(text: provider.userEmail);

    final strings = AppStrings.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.settingsProfileTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: strings.settingsProfileNameLabel,
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const Gap(16),
            TextField(
              controller: licenseController,
              decoration: InputDecoration(
                labelText: strings.settingsProfileLicenseLabel,
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const Gap(16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: strings.settingsProfileEmailLabel,
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.settingsDialogCancel),
          ),
          FilledButton(
            onPressed: () {
              provider.updateUserProfile(
                name: nameController.text,
                license: licenseController.text,
                email: emailController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.settingsProfileUpdatedSnack)),
              );
            },
            child: Text(strings.settingsDialogSave),
          ),
        ],
      ),
    );
  }

Future<void> _handleExportPdf(
    BuildContext context,
    ThotProvider provider,
  ) async {
    final strings = AppStrings.of(context);

    if (!provider.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.settingsExportPdfProOnly),
          action: SnackBarAction(
            label: strings.settingsViewPro,
            onPressed: () => context.push('/pro'),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final options = await _showExportOptionsDialog(context, provider);
    if (options == null) return;

    if (options.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sélectionnez au moins une section.')),
        );
      }
      return;
    }

    try {
      await PdfExporter.exportAll(provider, options: options);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.settingsExportError(e))),
        );
      }
    }
  }

  Future<PdfExportOptions?> _showExportOptionsDialog(
    BuildContext context,
    ThotProvider provider,
  ) async {
    bool weapons = true;
    bool ammos = true;
    bool accessories = true;
    bool sessions = true;

    return showDialog<PdfExportOptions>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          final colors = Theme.of(ctx).colorScheme;
          final textStyles = Theme.of(ctx).textTheme;

          Widget option(String label, String count, bool value, ValueChanged<bool?> onChanged) {
            return InkWell(
              onTap: () => onChanged(!value),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: value,
                      onChanged: onChanged,
                      activeColor: colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(label, style: textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(count, style: textStyles.labelSmall?.copyWith(color: colors.secondary)),
                    ),
                  ],
                ),
              ),
            );
          }

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, color: colors.primary, size: 22),
                const Gap(10),
                const Text('Exporter le carnet'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sections à inclure :', style: textStyles.labelLarge?.copyWith(color: colors.secondary)),
                const Gap(8),
                option('Armes', '${provider.weapons.length}', weapons,
                    (v) => setLocalState(() => weapons = v ?? weapons)),
                option('Munitions', '${provider.ammos.length}', ammos,
                    (v) => setLocalState(() => ammos = v ?? ammos)),
                option('Matériel', '${provider.accessories.length}', accessories,
                    (v) => setLocalState(() => accessories = v ?? accessories)),
                option('Séances', '${provider.sessions.length}', sessions,
                    (v) => setLocalState(() => sessions = v ?? sessions)),
                const Gap(8),
                TextButton.icon(
                  onPressed: () => setLocalState(() {
                    weapons = true; ammos = true; accessories = true; sessions = true;
                  }),
                  icon: Icon(Icons.select_all_rounded, size: 18, color: colors.primary),
                  label: Text('Tout sélectionner', style: TextStyle(color: colors.primary)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, PdfExportOptions(
                  includeWeapons: weapons,
                  includeAmmos: ammos,
                  includeAccessories: accessories,
                  includeSessions: sessions,
                )),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Exporter'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDocumentsDialog(BuildContext context, ThotProvider provider) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Gap(12),
                        Text(
                          strings.settingsDocumentsTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.userDocuments.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.5),
                              ),
                              const Gap(16),
                              Text(
                                strings.settingsDocumentsEmptyTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                    ),
                              ),
                              const Gap(8),
                              Text(
                                strings.settingsDocumentsEmptySubtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.userDocuments.length,
                        separatorBuilder: (context, index) => const Gap(8),
                        itemBuilder: (context, index) {
                          final doc = provider.userDocuments[index];
                          final isLocked = !provider.isPremium && index >= 1;
                          return _DocumentItem(
                            document: doc,
                            isLocked: isLocked,
                            onDelete: () {
                              provider.deleteUserDocument(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    strings.settingsDocumentDeleted(doc.name),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final colors = Theme.of(context).colorScheme;
                    final textStyles = Theme.of(context).textTheme;
                    final strings = AppStrings.of(context);

                    final reachedLimit =
                        !provider.isPremium && provider.userDocuments.length >= 1;
                    final bgColor =
                        reachedLimit ? colors.surfaceVariant : colors.primary;
                    final fgColor =
                        reachedLimit ? colors.secondary : colors.onPrimary;

                    return FilledButton.icon(
                      onPressed: reachedLimit
                          ? () => context.push('/pro')
                          : () => _pickDocument(context, provider),
                      icon: Icon(
                        Icons.add,
                        color: fgColor,
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            strings.settingsAddDocument,
                            style: textStyles.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: fgColor,
                            ),
                          ),
                          if (reachedLimit) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: LightColors.surfaceHighlight,
                                  width: 1.35,
                                ),
                              ),
                              child: Text(
                                strings.proBadge,
                                style: textStyles.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: bgColor,
                        foregroundColor: fgColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(BuildContext context, ThotProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;

      final String? resolvedPathOrDataUrl;
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) {
          throw Exception('No bytes returned by FilePicker (web)');
        }
        final ext = (file.extension ?? '').toLowerCase();
        final isPdf = ext == 'pdf';
        final mime = isPdf
            ? 'application/pdf'
            : (ext == 'png'
                ? 'image/png'
                : (ext == 'jpg' || ext == 'jpeg')
                    ? 'image/jpeg'
                    : 'application/octet-stream');
        resolvedPathOrDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      } else {
        resolvedPathOrDataUrl = file.path;
      }

      if (resolvedPathOrDataUrl == null ||
          resolvedPathOrDataUrl.trim().isEmpty) {
        throw Exception('No usable file reference from picker');
      }

      if (context.mounted) {
        _showAddDocumentDetailsDialog(
          context,
          provider,
          resolvedPathOrDataUrl,
          file.name,
        );
      }
    } catch (e) {
      if (context.mounted) {
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.settingsPickFileError(e))),
        );
      }
    }
  }

  void _showAddDocumentDetailsDialog(
    BuildContext context,
    ThotProvider provider,
    String filePath,
    String fileName,
  ) {
    final nameController = TextEditingController(text: fileName);
    final strings = AppStrings.of(context);
    String selectedType = strings.settingsDocumentTypeHuntingPermit;
    DateTime? expiryDate;
    int selectedNotifyDays = 0;

    final documentTypes = [
      strings.settingsDocumentTypeHuntingPermit,
      strings.settingsDocumentTypeFftLicense,
      strings.settingsDocumentTypeIdCard,
      strings.settingsDocumentTypeWeaponPermit,
      strings.settingsDocumentTypeMedicalCertificate,
      strings.settingsDocumentTypeOther,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.settingsDocumentDetailsTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: strings.settingsDocumentNameLabel,
                  hintText: strings.settingsDocumentNameHint,
                  prefixIcon: Icon(Icons.edit_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      nameController.clear();
                    },
                  ),
                ),
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: strings.settingsDocumentTypeLabel,
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: documentTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
              const Gap(16),
              Text(
                strings.docExpiryDateLabel,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
              ),
              const Gap(8),
              Row(children: [
                Expanded(
                  child: expiryDate == null
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 20)),
                            );
                            if (picked != null) {
                              setState(() => expiryDate = DateTime(
                                  picked.year, picked.month, picked.day));
                            }
                          },
                          icon: const Icon(Icons.calendar_today_rounded,
                              size: 16),
                          label: Text(strings.selectDateLabel),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 16,
                                color:
                                    Theme.of(context).colorScheme.primary),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                AppDateFormats.formatDateShort(
                                    context, expiryDate!),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                expiryDate = null;
                                selectedNotifyDays = 0;
                              }),
                              child: Icon(Icons.close_rounded,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                            ),
                          ]),
                        ),
                ),
              ]),
              if (expiryDate != null) ...[
                const Gap(16),
                Text(
                  strings.docExpiryNotifyLabel,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                          color:
                              Theme.of(context).colorScheme.secondary),
                ),
                const Gap(8),
                DropdownButtonFormField<int>(
                  value: selectedNotifyDays > 0 ? selectedNotifyDays : 0,
                  decoration: InputDecoration(
                    labelText: strings.docExpiryNotifyDaysLabel,
                  ),
                  items: const [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text('Aucune notification'),
                    ),
                    DropdownMenuItem<int>(
                      value: 7,
                      child: Text('1 semaine avant'),
                    ),
                    DropdownMenuItem<int>(
                      value: 30,
                      child: Text('1 mois avant'),
                    ),
                    DropdownMenuItem<int>(
                      value: 90,
                      child: Text('3 mois avant'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => selectedNotifyDays = v ?? 0);
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.settingsDialogCancel),
            ),
            FilledButton(
              onPressed: () {
                final document = UserDocument(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.isNotEmpty
                      ? nameController.text
                      : fileName,
                  type: selectedType,
                  filePath: filePath,
                  addedDate: DateTime.now(),
                  expiryDate: expiryDate,
                  notifyBeforeDays: selectedNotifyDays,
                );

                provider.addUserDocument(document);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.settingsDocumentAddedSuccess)),
                );
              },
              child: Text(strings.settingsAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: textStyles.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.secondary,
          ),
        ),
        const Gap(4),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: 0.72)
                  : LightColors.surfaceHighlight,
              width: 1.35,
            ),
            boxShadow: AppShadows.cardPremium,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 22),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: textStyles.bodySmall?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ProInlineChip extends StatefulWidget {
  final VoidCallback onTap;
  const _ProInlineChip({required this.onTap});

  @override
  State<_ProInlineChip> createState() => _ProInlineChipState();
}

class _ProInlineChipState extends State<_ProInlineChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      scale: _pressed ? 0.98 : 1.0,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            strings.proBadge,
            style: textStyles.labelMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutToggle extends StatelessWidget {
  final Widget Function(Color color) iconBuilder;
  final String label;
  final String actionId;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool maxReached;
  final SwitchThemeData switchTheme;

  const _ShortcutToggle({
    required this.iconBuilder,
    required this.label,
    required this.actionId,
    required this.enabled,
    required this.onChanged,
    required this.maxReached,
    required this.switchTheme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final canToggle = enabled || !maxReached;
    final iconColor = colors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Center(child: iconBuilder(iconColor)),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              label,
              style: textStyles.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          SwitchTheme(
            data: switchTheme,
            child: Switch(
              value: enabled,
              onChanged: canToggle ? onChanged : null,
              activeColor: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  final String text;

  const _PremiumFeature(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final UserDocument document;
  final bool isLocked;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const _DocumentItem({
    required this.document,
    required this.isLocked,
    required this.onDelete,
    this.onEdit,
  });

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case "Permis de chasse":
        return Icons.badge_outlined;
      case "Licence FFT":
        return Icons.card_membership_outlined;
      case "Carte d'identité":
        return Icons.credit_card_outlined;
      case "Autorisation de port d'arme":
        return Icons.gavel_outlined;
      case "Certificat médical":
        return Icons.medical_services_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  String _humanizeDocumentType(String rawType) {
    final t = rawType.trim();
    if (t.isEmpty) return 'Document';

    if (t.contains('/')) {
      final normalized = t.toLowerCase();
      if (normalized.contains('pdf')) return 'PDF';
      if (normalized.startsWith('image/')) return 'Image';
      if (normalized.contains('json')) return 'JSON';
      if (normalized.contains('text')) return 'Texte';
      return 'Document';
    }

    return t;
  }

  Future<void> _openDocument(BuildContext context) async {
    try {
      final path = document.filePath;
      if (path.trim().isEmpty) throw Exception('Empty filePath');

      if (kIsWeb) {
        if (path.startsWith('data:')) {
          await WebDocumentOpener.openDataUrlInNewTab(
            path,
            windowName: '_blank',
          );
          return;
        }

        if (path.startsWith('blob:') ||
            path.startsWith('http://') ||
            path.startsWith('https://')) {
          final ok = await launchUrl(
            Uri.parse(path),
            mode: LaunchMode.platformDefault,
            webOnlyWindowName: '_blank',
          );
          if (!ok) throw Exception('launchUrl failed (web)');
          return;
        }

        throw Exception('Unsupported document reference on web: $path');
      }

      if (path.startsWith('http://') || path.startsWith('https://')) {
        final ok = await launchUrl(
          Uri.parse(path),
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw Exception('launchUrl failed for http(s)');
        return;
      }

      if (path.startsWith('content://')) {
        final ok = await launchUrl(
          Uri.parse(path),
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw Exception('launchUrl failed for content://');
        return;
      }

      final ok = await launchUrl(
        Uri.file(path),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) throw Exception('launchUrl failed for file');
    } catch (e) {
      debugPrint('Failed to open user document.');
      if (context.mounted) {
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.settingsOpenDocumentFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final typeLabel = _humanizeDocumentType(document.type);
    final subtitle = typeLabel;

    final card = Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: isLocked ? () => context.push('/pro') : () => _openDocument(context),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: colors.outline),
          ),
          child: Opacity(
            opacity: isLocked ? 0.45 : 1,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _getDocumentIcon(document.type),
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Text(
                        subtitle,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isLocked && onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: colors.secondary),
                    onPressed: onEdit,
                  ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(strings.settingsDeleteDocumentTitle),
                        content: Text(
                          strings.settingsDeleteDocumentMessage(document.name),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(strings.settingsDialogCancel),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.error,
                            ),
                            child: Text(strings.delete),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!isLocked) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: LightColors.surfaceHighlight,
                width: 1.35,
              ),
            ),
            child: Text(
              strings.proBadge,
              style: textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
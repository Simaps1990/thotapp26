import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'theme.dart';
import 'nav.dart';
import 'data/thot_provider.dart';
import 'widgets/achievement_toast_layer.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thot/l10n/app_strings.dart';
import 'utils/maintenance_notifications.dart';
import 'package:thot/utils/crash_logger.dart';

void main() {
  CrashLogger.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDateFormatting();

    await _configureRevenueCatSafely();
    await MaintenanceNotifications.init();

    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    runApp(const MyApp());
  });
}

Future<String> _loadRevenueCatApiKey() async {
  if (kIsWeb) return '';

  const channel = MethodChannel('thot/config');

  try {
    final key = await channel.invokeMethod<String>('getRevenueCatApiKey');
    return key?.trim() ?? '';
  } catch (e, st) {
    debugPrint('❌ Failed to load RevenueCat key from iOS: $e');
    debugPrint('$st');
    return '';
  }
}

Future<void> _configureRevenueCatSafely() async {
  if (kIsWeb) return;

  try {
    final revenueCatApiKey = await _loadRevenueCatApiKey();

    if (revenueCatApiKey.isEmpty) {
      debugPrint(
        '⚠️ REVENUECAT_API_KEY not set. Skipping RevenueCat configuration.',
      );
      return;
    }

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
    final configuration = PurchasesConfiguration(revenueCatApiKey);
    await Purchases.configure(configuration);
    debugPrint('✅ RevenueCat configured');
  } catch (e, st) {
    debugPrint('❌ RevenueCat init failed: $e');
    debugPrint('$st');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThotProvider()),
      ],
      child: const _ViewportResyncApp(),
    );
  }
}

class _ViewportResyncApp extends StatefulWidget {
  const _ViewportResyncApp();

  @override
  State<_ViewportResyncApp> createState() => _ViewportResyncAppState();
}

class _ViewportResyncAppState extends State<_ViewportResyncApp>
    with WidgetsBindingObserver {
  int _layoutEpoch = 0;
  String? _lastIntlLocale;
  Size? _lastScreenSize;

  void _forceRelayout() {
    if (!mounted) return;
    setState(() {
      _layoutEpoch++;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    final provider = context.read<ThotProvider>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Flush any pending save before the OS may kill us.
        unawaited(provider.flushPendingSave());
        if (provider.pinEnabled) provider.lockSession();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Ne pas verrouiller sur les system overlays (sélecteur photo, share sheet iOS)
        break;

      case AppLifecycleState.resumed:
        if (provider.pinEnabled && !provider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppRouter.router.go('/lock');
            }
          });
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceRelayout();
    });
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final newSize = view.physicalSize;
    if (_lastScreenSize != null && _lastScreenSize != newSize) {
      _forceRelayout();
    }
    _lastScreenSize = newSize;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThotProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    final appLocale = context.select<ThotProvider, Locale?>(
      (p) => p.appLocale,
    );

    final locale = appLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
    final intlLocale =
        (locale.countryCode == null || locale.countryCode!.isEmpty)
            ? locale.languageCode
            : '${locale.languageCode}_${locale.countryCode}';
    if (_lastIntlLocale != intlLocale) {
      _lastIntlLocale = intlLocale;
      Intl.defaultLocale = intlLocale;
    }

    return KeyedSubtree(
      key: ValueKey(_layoutEpoch),
      child: MaterialApp.router(
        title: 'Thot',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        locale: appLocale,
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          AppStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: AppRouter.router,
        builder: (context, child) {
          const iosElementScale = 0.95;
          final mediaQuery = MediaQuery.of(context);
          final theme = Theme.of(context);

          final appChild = child ?? const SizedBox();
          final shouldScaleIosUi =
              !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

          final scaledAppChild = shouldScaleIosUi
              ? MediaQuery(
                  data: (() {
                    // Honor the user's iOS Dynamic Type preference. We only
                    // nudge the scale down by `iosElementScale` (~0.95) for
                    // visual density, but keep the user's accessibility
                    // preference intact: a user who enabled "Larger Text"
                    // still sees larger text.
                    final userScale = mediaQuery.textScaler.scale(1.0);
                    final effectiveScale =
                        (userScale * iosElementScale).clamp(0.85, 2.0);
                    return mediaQuery.copyWith(
                      textScaler: TextScaler.linear(effectiveScale),
                    );
                  })(),
                  child: Theme(
                    data: theme.copyWith(
                      iconTheme: theme.iconTheme.copyWith(
                        size: (theme.iconTheme.size ?? 24) * iosElementScale,
                      ),
                      primaryIconTheme: theme.primaryIconTheme.copyWith(
                        size:
                            (theme.primaryIconTheme.size ?? 24) * iosElementScale,
                      ),
                    ),
                    child: appChild,
                  ),
                )
              : appChild;

          return AchievementToastLayer(child: scaledAppChild);
        },
      ),
    );
  }
}
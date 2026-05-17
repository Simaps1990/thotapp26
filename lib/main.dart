import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'theme.dart';
import 'nav.dart';
import 'data/thot_provider.dart';
import 'widgets/achievement_toast_layer.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thot/l10n/app_strings.dart';
import 'utils/maintenance_notifications.dart';
import 'package:thot/utils/crash_logger.dart';

void main() {
  CrashLogger.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;

    await initializeDateFormatting();

    await _configureRevenueCatSafely();
    await MaintenanceNotifications.init();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );

    runApp(const MyApp());
  });
}

Future<String> _loadRevenueCatApiKey() async {
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
      providers: [ChangeNotifierProvider(create: (_) => ThotProvider())],
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
  static const MethodChannel _configChannel = MethodChannel('thot/config');
  int _layoutEpoch = 0;
  String? _lastIntlLocale;
  Size? _lastScreenSize;

  void _forceRelayout() {
    if (!mounted) return;
    setState(() {
      _layoutEpoch++;
    });
  }

  Future<void> _openWidgetRoute(String? route) async {
    final value = route?.trim();
    if (value == null || value.isEmpty) return;
    for (var i = 0; i < 20; i++) {
      if (!mounted) return;
      if (context.read<ThotProvider>().isInitialized) break;
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppRouter.router.go(value);
    });
  }

  Future<void> _consumeInitialWidgetRoute() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final route = await _configChannel.invokeMethod<String>(
        'consumeWidgetRoute',
      );
      await _openWidgetRoute(route);
    } catch (_) {}
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
    _configChannel.setMethodCallHandler((call) async {
      if (call.method == 'onWidgetRoute') {
        await _openWidgetRoute(call.arguments as String?);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceRelayout();
      _consumeInitialWidgetRoute();
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
    _configChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThotProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    final appLocale = context.select<ThotProvider, Locale?>((p) => p.appLocale);

    final locale =
        appLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
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
          final brightness = theme.brightness;

          final appChild = child ?? const SizedBox();
          final shouldScaleIosUi =
              defaultTargetPlatform == TargetPlatform.iOS;

          final scaledAppChild = shouldScaleIosUi
              ? MediaQuery(
                  data: (() {
                    // Honor the user's iOS Dynamic Type preference. We only
                    // nudge the scale down by `iosElementScale` (~0.95) for
                    // visual density, but keep the user's accessibility
                    // preference intact: a user who enabled "Larger Text"
                    // still sees larger text.
                    final userScale = mediaQuery.textScaler.scale(1.0);
                    final effectiveScale = (userScale * iosElementScale).clamp(
                      0.85,
                      2.0,
                    );
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
                            (theme.primaryIconTheme.size ?? 24) *
                            iosElementScale,
                      ),
                    ),
                    child: appChild,
                  ),
                )
              : appChild;

          final overlayStyle = brightness == Brightness.dark
              ? const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarIconBrightness: Brightness.light,
                )
              : const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarIconBrightness: Brightness.dark,
                );

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: AchievementToastLayer(child: scaledAppChild),
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

void main() async {
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
}

Future<void> _configureRevenueCatSafely() async {
  if (kIsWeb) return;

  try {
const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');

    if (revenueCatApiKey.trim().isEmpty) {
      debugPrint('⚠️ REVENUECAT_API_KEY not set. Skipping RevenueCat configuration.');
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
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        provider.lockSession();
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
    _forceRelayout();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thotProvider = context.watch<ThotProvider>();

    final locale = thotProvider.appLocale ??
        WidgetsBinding.instance.platformDispatcher.locale;
    final intlLocale = (locale.countryCode == null || locale.countryCode!.isEmpty)
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
        themeMode: thotProvider.themeMode,
        locale: thotProvider.appLocale,
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          AppStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: AppRouter.router,
        builder: (context, child) => AchievementToastLayer(
          key: const GlobalObjectKey('achievement_layer'),
          child: child ?? const SizedBox(),
        ),
      ),
    );
  }
}
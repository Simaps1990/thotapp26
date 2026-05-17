import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/presentation/inventory_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock connectivity_plus : évite MissingPluginException sur HomeScreen
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async => <String>['wifi'],
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Golden Tests', () {
    // HomeScreen nécessite un mock trop profond (TrainingHistory timer 3h).
    // Ces deux tests sont désactivés jusqu'à l'extraction de TrainingHistory
    // dans un service mockable. Voir TODO: extract TrainingHistory for testing.

    testWidgets('InventoryScreen empty golden', (tester) async {
      final provider = ThotProvider();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: [AppStrings.delegate],
          supportedLocales: AppStrings.supportedLocales,
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const InventoryScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(InventoryScreen),
        matchesGoldenFile('goldens/inventory_screen_empty.png'),
      );
    });

    testWidgets('InventoryScreen with items golden', (tester) async {
      final provider = ThotProvider();
      provider.addPlatform(
        Platform(
          id: 'test-1',
          name: 'Glock 17',
          model: 'Gen 5',
          caliber: '9mm',
          serialNumber: 'ABC123',
          weight: 0.63,
          totalRounds: 0,
          lastCleaned: DateTime(2026),
          lastUsed: DateTime(2026),
          roundsAtLastCleaning: 0,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: [AppStrings.delegate],
          supportedLocales: AppStrings.supportedLocales,
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const InventoryScreen(),
          ),
        ),
      );
      await tester.pump();
      // Laisser le timer _scheduleSave (400ms) s'écouler
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(InventoryScreen),
        matchesGoldenFile('goldens/inventory_screen_with_items.png'),
      );
    });
  });
}
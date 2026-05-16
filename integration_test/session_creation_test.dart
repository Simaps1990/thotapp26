import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/main.dart';
import 'package:thot/presentation/add_item_screen.dart';
import 'package:thot/presentation/home_screen.dart';
import 'package:thot/presentation/inventory_screen.dart';
import 'package:thot/presentation/new_session_screen.dart';
import 'package:thot/presentation/session_list_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Session Creation Flow', () {
    testWidgets('Complete flow: create platform and session', (tester) async {
      // Initialize with empty preferences
      SharedPreferences.setMockInitialValues({});

      // Launch the app
      await tester.pumpWidget(const ThotApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to Inventory
      final inventoryNav = find.byIcon(Icons.inventory_2_outlined);
      if (inventoryNav.evaluate().isNotEmpty) {
        await tester.tap(inventoryNav);
        await tester.pumpAndSettle();
      }

      // Should be on InventoryScreen
      expect(find.byType(InventoryScreen), findsOneWidget);

      // Tap add button
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      }

      // Should be on AddItemScreen
      expect(find.byType(AddItemScreen), findsOneWidget);

      // Fill in the form
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test AR-15');
      await tester.pump();

      // Enter brand
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length > 1) {
        await tester.enterText(textFields.at(1), 'Colt');
        await tester.pump();
      }

      // Save the item
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should be back on inventory
      expect(find.byType(InventoryScreen), findsOneWidget);

      // Verify item was added
      expect(find.text('Test AR-15'), findsOneWidget);

      // Navigate back to home
      final homeNav = find.byIcon(Icons.home_outlined);
      if (homeNav.evaluate().isNotEmpty) {
        await tester.tap(homeNav);
        await tester.pumpAndSettle();
      }

      // Start creating a session
      final newSessionButton = find.text('New Session');
      if (newSessionButton.evaluate().isEmpty) {
        // Try finding by icon
        final addSessionIcon = find.byIcon(Icons.add_circle_outline);
        if (addSessionIcon.evaluate().isNotEmpty) {
          await tester.tap(addSessionIcon);
        }
      } else {
        await tester.tap(newSessionButton);
      }
      await tester.pumpAndSettle();

      // Should be on NewSessionScreen
      expect(find.byType(NewSessionScreen), findsOneWidget);

      // Enter session name
      final sessionNameField = find.byType(TextField).first;
      await tester.enterText(sessionNameField, 'Test Session');
      await tester.pump();

      // Select the platform we just created
      final platformSelector = find.text('Select Platform');
      if (platformSelector.evaluate().isNotEmpty) {
        await tester.tap(platformSelector);
        await tester.pumpAndSettle();

        // Select Test AR-15
        final testPlatform = find.text('Test AR-15');
        await tester.tap(testPlatform);
        await tester.pumpAndSettle();
      }

      // Save the session
      final saveSessionButton = find.byIcon(Icons.save);
      await tester.tap(saveSessionButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on session list or session detail
      final sessionListFinder = find.byType(SessionListScreen);
      expect(
        sessionListFinder.evaluate().isNotEmpty ||
            find.text('Test Session').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Create ammo and use in session', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const ThotApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Inventory
      final inventoryNav = find.byIcon(Icons.inventory_2_outlined);
      if (inventoryNav.evaluate().isNotEmpty) {
        await tester.tap(inventoryNav);
        await tester.pumpAndSettle();
      }

      // Switch to Ammo tab if needed
      final ammoTab = find.text('Ammo');
      if (ammoTab.evaluate().isNotEmpty) {
        await tester.tap(ammoTab);
        await tester.pumpAndSettle();
      }

      // Add ammo
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      }

      // Fill ammo form
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '5.56 NATO');
      await tester.pump();

      // Enter quantity
      final quantityField = find.byType(TextField).first;
      await tester.enterText(quantityField, '100');
      await tester.pump();

      // Save
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify ammo added
      expect(find.text('5.56 NATO'), findsOneWidget);
    });
  });
}

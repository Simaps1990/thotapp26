import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';

class ShootingTableQrScannerScreen extends StatefulWidget {
  const ShootingTableQrScannerScreen({super.key});

  @override
  State<ShootingTableQrScannerScreen> createState() =>
      _ShootingTableQrScannerScreenState();
}

class _ShootingTableQrScannerScreenState
    extends State<ShootingTableQrScannerScreen> {
  bool _hasScanned = false;

  void _handleDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .firstOrNull;
    if (code == null) return;
    _hasScanned = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(strings.shootingTableQrScannerTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            children: [
              Text(
                strings.shootingTableQrScannerInstruction,
                textAlign: TextAlign.center,
                style: textStyles.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.7),
                        width: 1.4,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: MobileScanner(onDetect: _handleDetect),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                label: Text(strings.shootingTableQrScannerCancel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

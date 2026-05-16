part of '../shooting_tables_screen.dart';

class _PocketCardOverlay extends StatefulWidget {
  final ShootingAdjustmentTable table;
  final ThotProvider provider;

  const _PocketCardOverlay({required this.table, required this.provider});

  @override
  State<_PocketCardOverlay> createState() => _PocketCardOverlayState();
}

class _PocketCardOverlayState extends State<_PocketCardOverlay> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textStyles = Theme.of(context).textTheme;

    final entries = [...widget.table.entries]
      ..sort((a, b) => a.distance.compareTo(b.distance));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tableDisplayName(widget.table),
                        style: textStyles.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      Text(
                        '${_platformName(widget.provider, widget.table.platformId, customPlatformName: widget.table.customPlatformName)} / ${_ammoName(widget.provider, widget.table.ammoId, strings)}',
                        style: textStyles.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(32),
                      Table(
                        border: TableBorder.all(color: Colors.white),
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Colors.white24),
                            children: [
                              _TableCell('Distance'),
                              _TableCell('Drop'),
                              _TableCell('Dérive'),
                            ],
                          ),
                          ...entries.map((entry) {
                            final distance = widget.provider.useMetric
                                ? '${entry.distance}m'
                                : '${(entry.distance * 1.09361).toStringAsFixed(0)}yd';
                            final drop = widget.provider.useMetric
                                ? '${entry.verticalOffset.toStringAsFixed(1)}cm'
                                : '${(entry.verticalOffset / 2.54).toStringAsFixed(1)}in';
                            final drift = widget.provider.useMetric
                                ? '${entry.horizontalOffset.toStringAsFixed(1)}cm'
                                : '${(entry.horizontalOffset / 2.54).toStringAsFixed(1)}in';
                            return TableRow(
                              children: [
                                _TableCell(distance),
                                _TableCell(drop),
                                _TableCell(drift),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                tooltip: strings.close,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tableDisplayName(ShootingAdjustmentTable table) {
    return table.name.trim().isEmpty ? 'Table sans nom' : table.name;
  }

  String _platformName(
    ThotProvider provider,
    String platformId, {
    String? customPlatformName,
  }) {
    if (customPlatformName != null && customPlatformName.trim().isNotEmpty) {
      return customPlatformName;
    }
    final platform = provider.platforms.firstWhere(
      (p) => p.id == platformId,
      orElse: () => Platform(
        id: '',
        name: 'Inconnu',
        type: '',
        model: '',
        caliber: '',
        serialNumber: '',
        weight: 0,
        totalRounds: 0,
        lastCleaned: DateTime.now(),
      ),
    );
    return platform.name;
  }

  String _ammoName(ThotProvider provider, String? ammoId, AppStrings strings) {
    if (ammoId == null) return strings.shootingTableNoAmmo;
    final ammo = provider.ammos.firstWhere(
      (a) => a.id == ammoId,
      orElse: () => Ammo(
        id: '',
        name: 'Inconnu',
        brand: '',
        caliber: '',
        quantity: 0,
        lowStockThreshold: 0,
      ),
    );
    return ammo.name;
  }
}

class _TableCell extends StatelessWidget {
  final String text;

  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}


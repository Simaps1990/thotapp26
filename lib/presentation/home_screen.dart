import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:thot/data/thot_provider.dart';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/presentation/diagnostic_screen.dart';
import 'package:thot/presentation/millieme_tool_screen.dart';
import 'package:thot/presentation/shooting_timer_screen.dart';
import 'package:thot/presentation/achievements_screen.dart';
import 'package:thot/presentation/statistics_screen.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/exercise_display.dart';
import 'package:thot/data/models.dart';
import 'package:thot/l10n/app_strings.dart';
import '../utils/achievement_definitions.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void _showDiagnosticModal(BuildContext context) {
  final provider = Provider.of<ThotProvider>(context, listen: false);
  if (!provider.isPremium) {
    showProModal(context);
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const DiagnosticScreen(),
  );
}

// ── Modèle d'alerte ──────────────────────────────────────────────────────────

enum _AlertType { wear, fouling, stock, document }

class _MaintenanceAlert {
  final String id;
  /// weaponId, ammoId, or itemId depending on type
  final String itemId;
  final String itemName;
  final _AlertType type;
  /// progress 0.0–1.0 for wear/fouling/stock, daysRemaining for document
  final double progress;
  /// Only for document alerts
  final String? documentName;
  final int? daysRemaining;
  bool isRead;

  _MaintenanceAlert({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.progress,
    this.documentName,
    this.daysRemaining,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemName': itemName,
        'type': type.name,
        'progress': progress,
        if (documentName != null) 'documentName': documentName,
        if (daysRemaining != null) 'daysRemaining': daysRemaining,
        'isRead': isRead,
      };

  factory _MaintenanceAlert.fromJson(Map<String, dynamic> j) =>
      _MaintenanceAlert(
        id: j['id'] as String,
        itemId: j['itemId'] as String? ?? j['weaponId'] as String? ?? '',
        itemName: j['itemName'] as String? ?? j['weaponName'] as String? ?? '',
        type: _AlertType.values.firstWhere((e) => e.name == j['type'],
            orElse: () => _AlertType.wear),
        progress: (j['progress'] as num).toDouble(),
        documentName: j['documentName'] as String?,
        daysRemaining: j['daysRemaining'] as int?,
        isRead: j['isRead'] as bool? ?? false,
      );
}

// ── Écran d'accueil ──────────────────────────────────────────────────────────

void _showMilliemeModal(BuildContext context) {
  final provider = Provider.of<ThotProvider>(context, listen: false);
  if (!provider.isPremium) {
    showProModal(context);
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const MilliemeToolScreen();
    },
  );
}

void _showAchievementsModal(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final baseBackground = Theme.of(context).scaffoldBackgroundColor;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final height = MediaQuery.of(context).size.height * 0.8;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height,
        decoration: BoxDecoration(
          color: baseBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Expanded(child: AchievementsScreen(useSafeArea: false)),
          ],
        ),
      );
    },
  );
}

void _showStatisticsModal(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final baseBackground = Theme.of(context).scaffoldBackgroundColor;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final height = MediaQuery.of(context).size.height * 0.8;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height,
        decoration: BoxDecoration(
          color: baseBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: StatisticsScreen(
                backgroundColor: baseBackground,
                useSafeArea: false,
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showTimerModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ShootingTimerScreen(),
  );
}

enum _PrecisionRange { day, week, month, year, total }

extension on _PrecisionRange {
  String labelForLocale(AppStrings strings) {
    switch (this) {
      case _PrecisionRange.day:
        return strings.precisionFilterDayShort;
      case _PrecisionRange.week:
        return strings.precisionFilterWeekShort;
      case _PrecisionRange.month:
        return strings.precisionFilterMonthShort;
      case _PrecisionRange.year:
        return strings.precisionFilterYearShort;
      case _PrecisionRange.total:
        return strings.precisionFilterTotalShort;
    }
  }

  Duration? get duration {
    switch (this) {
      case _PrecisionRange.day:
        return const Duration(days: 1);
      case _PrecisionRange.week:
        return const Duration(days: 7);
      case _PrecisionRange.month:
        return const Duration(days: 30);
      case _PrecisionRange.year:
        return const Duration(days: 365);
      case _PrecisionRange.total:
        return null;
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _PrecisionRange _precisionRange = _PrecisionRange.month;

  final GlobalKey _bellKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<_MaintenanceAlert> _alerts = [];
  static const _prefKey = 'maintenance_alerts_v1';

  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAlerts();
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && online != _isOnline) setState(() => _isOnline = online);
    } catch (_) {
      if (mounted && _isOnline) setState(() => _isOnline = false);
    }
  }

  Future<void> _syncAlerts() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    final saved = <String, bool>{};
    if (raw != null) {
      try {
        final List decoded = jsonDecode(raw) as List;
        for (final item in decoded) {
          final m = _MaintenanceAlert.fromJson(item as Map<String, dynamic>);
          saved[m.id] = m.isRead;
        }
      } catch (_) {}
    }
    final fresh = <_MaintenanceAlert>[];
    final now = DateTime.now();

    // Wear & fouling alerts (weapons)
    for (final w in provider.weapons) {
      if (w.trackCleanliness && w.cleaningProgress >= 0.8) {
        final id = '${w.id}_fouling';
        fresh.add(_MaintenanceAlert(
          id: id, itemId: w.id, itemName: w.name,
          type: _AlertType.fouling, progress: w.cleaningProgress,
          isRead: saved[id] ?? false,
        ));
      }
      if (w.trackWear && w.revisionProgress >= 0.8) {
        final id = '${w.id}_wear';
        fresh.add(_MaintenanceAlert(
          id: id, itemId: w.id, itemName: w.name,
          type: _AlertType.wear, progress: w.revisionProgress,
          isRead: saved[id] ?? false,
        ));
      }
      // Document expiry alerts for weapons
      for (final doc in w.documents) {
        if (doc.expiryDate != null && doc.notifyBeforeDays > 0) {
          final days = doc.expiryDate!.difference(now).inDays;
          if (days <= doc.notifyBeforeDays) {
            final id = '${w.id}_doc_${doc.name.hashCode}';
            fresh.add(_MaintenanceAlert(
              id: id, itemId: w.id, itemName: w.name,
              type: _AlertType.document, progress: 0,
              documentName: doc.name, daysRemaining: days,
              isRead: saved[id] ?? false,
            ));
          }
        }
      }
    }

    // Stock alerts (ammo)
    for (final a in provider.ammos) {
      if (a.trackStock) {
        final threshold = a.lowStockThreshold.toDouble();
        final rawInitial = a.initialQuantity.toDouble();
        final current = a.quantity.toDouble();
        final double criticality;
        if (rawInitial <= threshold) {
          criticality = current <= threshold ? 1.0 : 0.0;
        } else {
          criticality = (1.0 - ((current - threshold) / (rawInitial - threshold)).clamp(0.0, 1.0)).clamp(0.0, 1.0);
        }
        if (criticality >= 0.8) {
          final id = '${a.id}_stock';
          fresh.add(_MaintenanceAlert(
            id: id, itemId: a.id, itemName: a.name,
            type: _AlertType.stock, progress: criticality,
            isRead: saved[id] ?? false,
          ));
        }
      }
      // Document expiry alerts for ammo
      for (final doc in a.documents) {
        if (doc.expiryDate != null && doc.notifyBeforeDays > 0) {
          final days = doc.expiryDate!.difference(now).inDays;
          if (days <= doc.notifyBeforeDays) {
            final id = '${a.id}_doc_${doc.name.hashCode}';
            fresh.add(_MaintenanceAlert(
              id: id, itemId: a.id, itemName: a.name,
              type: _AlertType.document, progress: 0,
              documentName: doc.name, daysRemaining: days,
              isRead: saved[id] ?? false,
            ));
          }
        }
      }
    }

    // Document expiry alerts for accessories
    for (final acc in provider.accessories) {
      for (final doc in acc.documents) {
        if (doc.expiryDate != null && doc.notifyBeforeDays > 0) {
          final days = doc.expiryDate!.difference(now).inDays;
          if (days <= doc.notifyBeforeDays) {
            final id = '${acc.id}_doc_${doc.name.hashCode}';
            fresh.add(_MaintenanceAlert(
              id: id, itemId: acc.id, itemName: acc.name,
              type: _AlertType.document, progress: 0,
              documentName: doc.name, daysRemaining: days,
              isRead: saved[id] ?? false,
            ));
          }
        }
      }
    }

    // Document expiry alerts for global user documents (settings)
    for (final doc in provider.userDocuments) {
      if (doc.expiryDate != null && doc.notifyBeforeDays > 0) {
        final days = doc.expiryDate!.difference(now).inDays;
        if (days <= doc.notifyBeforeDays) {
          final id = 'global_doc_${doc.id}';
          fresh.add(_MaintenanceAlert(
            id: id,
            itemId: 'global',
            itemName: doc.name,
            type: _AlertType.document,
            progress: 0,
            documentName: doc.name,
            daysRemaining: days,
            isRead: saved[id] ?? false,
          ));
        }
      }
    }

    if (mounted) setState(() => _alerts = fresh);
    await _saveAlerts();
  }

  Future<void> _saveAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(_alerts.map((a) => a.toJson()).toList()));
  }

  int get _unreadCount => _alerts.where((a) => !a.isRead).length;

  void _markRead(String id) {
    setState(() { for (final a in _alerts) { if (a.id == id) a.isRead = true; } });
    _saveAlerts();
    _overlayEntry?.markNeedsBuild();
  }

  void _markAllRead() {
    setState(() { for (final a in _alerts) { a.isRead = true; } });
    _saveAlerts();
    _overlayEntry?.markNeedsBuild();
  }

  void _deleteAlert(String id) {
    setState(() => _alerts.removeWhere((a) => a.id == id));
    _saveAlerts();
    _overlayEntry?.markNeedsBuild();
  }

  void _deleteAllRead() {
    setState(() => _alerts.removeWhere((a) => a.isRead));
    _saveAlerts();
    _overlayEntry?.markNeedsBuild();
  }

  void _togglePanel() {
    if (_overlayEntry != null) { _closePanel(); } else { _openPanel(); }
  }

  void _openPanel() {
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final renderBox = _bellKey.currentContext?.findRenderObject() as RenderBox?;
    double topOffset = 80;
    if (renderBox != null) {
      final pos = renderBox.localToGlobal(Offset.zero);
      topOffset = pos.dy + renderBox.size.height + 8;
    }
    _overlayEntry = OverlayEntry(
      builder: (_) => _NotificationPanel(
        topOffset: topOffset,
        leftOffset: 16,
        width: screenWidth - 32,
        alerts: _alerts,
        onMarkRead: _markRead,
        onMarkAllRead: _markAllRead,
        onDelete: _deleteAlert,
        onDeleteAllRead: _deleteAllRead,
        onNavigate: (itemId) {
          _closePanel();
          context.push('/inventory/detail/$itemId');
        },
        onDismiss: _closePanel,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _closePanel() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  BoxDecoration _hardCardDecoration(ColorScheme colors, {double radius = 16}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: isDark ? null : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
      boxShadow: AppShadows.cardPremium,
    );
  }

  Widget _buildSectionTitle({required String title, required TextTheme textStyles, required ColorScheme colors}) {
    return Text(title, style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: colors.secondary));
  }

  Widget _buildTimerButton({required BuildContext context, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    return _HomeStandardActionCard(leading: Icon(Icons.timer_rounded, color: colors.primary, size: 24), title: strings.homeTimerTitle, subtitle: strings.homeTimerSubtitle, onTap: () => _showTimerModal(context), colors: colors, textStyles: textStyles);
  }

  void _showTemplateModal(BuildContext context) {
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height * 0.85;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: baseBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const _TemplateManagerScreen(),
        );
      },
    );
  }

  Widget _buildTemplateButton({required BuildContext context, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    return _HomeStandardActionCard(
      leading: Icon(Icons.bookmark_rounded, color: colors.primary, size: 24),
      title: strings.homeTemplateTitle,
      subtitle: strings.homeTemplateSubtitle,
      onTap: () => _showTemplateModal(context),
      colors: colors,
      textStyles: textStyles,
    );
  }

  Widget _buildMilliemeButton({required BuildContext context, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context);
    return _HomeStandardActionCard(leading: Icon(Icons.straighten_rounded, color: colors.primary, size: 24), title: strings.milliemeToolTitle, subtitle: strings.milliemeToolSubtitle, onTap: () => _showMilliemeModal(context), showProBadge: !provider.isPremium, colors: colors, textStyles: textStyles);
  }

  Widget _buildDiagnosticButton({required BuildContext context, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context);
    return _HomeStandardActionCard(leading: Icon(Icons.medical_services_outlined, color: colors.primary, size: 24), title: strings.homeDiagnosticTitle, subtitle: strings.homeDiagnosticSubtitle, onTap: () => _showDiagnosticModal(context), showProBadge: !provider.isPremium, colors: colors, textStyles: textStyles);
  }

  List<Widget> _buildHeaderSection({required BuildContext context, required ThotProvider provider, required ColorScheme colors, required TextTheme textStyles}) {
    final brightness = Theme.of(context).brightness;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/LOGO.svg', height: 34,
            colorFilter: ColorFilter.mode(brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn)),
          _ProCornerButton(
            key: _bellKey,
            isPremium: provider.isPremium,
            isOnline: _isOnline,
            unreadCount: _unreadCount,
            onTap: () => showProModal(context),
            onBellTap: _togglePanel,
          ),
        ],
      ),
      const Gap(AppSpacing.lg),
    ];
  }

  Widget _buildAchievementsButton({required BuildContext context, required ThotProvider provider, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    return _HomeStandardActionCard(
      leading: ShaderMask(
        shaderCallback: (bounds) {
          const base = Color(0xFFC2A14A);
          final light = Color.lerp(base, Colors.white, 0.35) ?? base;
          final dark = Color.lerp(base, Colors.black, 0.15) ?? base;
          return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [light, base, dark], stops: const [0.0, 0.55, 1.0]).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
      ),
      title: strings.homeTrophiesTitle,
      subtitle: strings.homeTrophiesUnlocked(unlockedAchievementsCount(provider)),
      onTap: () => _showAchievementsModal(context),
      colors: colors,
      textStyles: textStyles,
    );
  }

  List<Widget> _buildPrecisionChartSection({required ThotProvider provider, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    if (provider.sessions.isEmpty) return const [];
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(strings.homePrecisionTitle, style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary)),
          PopupMenuButton<_PrecisionRange>(
            initialValue: _precisionRange,
            tooltip: strings.homePrecisionFilterTooltip,
            onSelected: (v) => setState(() => _precisionRange = v),
            itemBuilder: (context) => [
              PopupMenuItem(value: _PrecisionRange.day, child: Text(strings.precisionFilterDayLong)),
              PopupMenuItem(value: _PrecisionRange.week, child: Text(strings.precisionFilterWeekLong)),
              PopupMenuItem(value: _PrecisionRange.month, child: Text(strings.precisionFilterMonthLong)),
              PopupMenuItem(value: _PrecisionRange.year, child: Text(strings.precisionFilterYearLong)),
              PopupMenuItem(value: _PrecisionRange.total, child: Text(strings.precisionFilterTotalLong)),
            ],
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_precisionRange.labelForLocale(strings), style: textStyles.labelSmall?.copyWith(color: colors.secondary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: colors.secondary, size: 16),
            ]),
          ),
        ],
      ),
      const Gap(AppSpacing.md),
      Builder(builder: (context) {
        final now = DateTime.now();
        final sessionsWithPrecision = provider.sessions.where((s) => s.exercises.any((e) => e.isPrecisionCounted)).toList()..sort((a, b) => a.date.compareTo(b.date));
        final duration = _precisionRange.duration;
        final filteredSessions = duration == null ? sessionsWithPrecision : sessionsWithPrecision.where((s) => s.date.isAfter(now.subtract(duration))).toList();
        final spots = <FlSpot>[];
        for (int i = 0; i < filteredSessions.length; i++) {
          spots.add(FlSpot(i.toDouble(), filteredSessions[i].averagePrecision));
        }
        final allPrecisions = filteredSessions.map((s) => s.averagePrecision).toList();
        final avgPrecision = allPrecisions.isEmpty ? 0 : allPrecisions.reduce((a, b) => a + b) / allPrecisions.length;
        final maxPrecision = allPrecisions.isEmpty ? 0 : allPrecisions.reduce((a, b) => a > b ? a : b);

        String labelForIndex(int index) {
          if (index < 0 || index >= filteredSessions.length) return '';
          final d = filteredSessions[index].date;
          if (_precisionRange == _PrecisionRange.day) return AppDateFormats.formatTimeShort(context, d);
          if (_precisionRange == _PrecisionRange.total || _precisionRange == _PrecisionRange.year) return AppDateFormats.formatMonthYear(context, d);
          return AppDateFormats.formatDayMonth(context, d);
        }

        return Container(
          height: 220,
          padding: AppSpacing.paddingLg,
          decoration: _hardCardDecoration(colors, radius: 16),
          child: spots.isEmpty
              ? Center(child: Text(allPrecisions.isEmpty ? strings.homePrecisionEmpty : '', style: textStyles.bodyMedium?.copyWith(color: colors.secondary), textAlign: TextAlign.center))
              : Column(children: [
                  Expanded(child: LineChart(LineChartData(
                    gridData: FlGridData(show: false),
                    lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (s) => Colors.grey.shade700,
                      getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem('${spot.y.toStringAsFixed(1)}%\n${labelForIndex(spot.x.toInt())}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))).toList(),
                    )),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= filteredSessions.length) return const SizedBox.shrink();
                        final count = filteredSessions.length;
                        final step = count <= 6 ? 1 : (count / 5).ceil();
                        if (i % step != 0 && i != count - 1) return const SizedBox.shrink();
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(labelForIndex(i), style: textStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis));
                      })),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: colors.primary, barWidth: 3, isStrokeCapRound: true, dotData: FlDotData(show: true), belowBarData: BarAreaData(show: true, color: colors.primary.withValues(alpha: 0.1)))],
                    minY: 0, maxY: 100,
                  ))),
                  const Gap(AppSpacing.md),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Text('${strings.homePrecisionAvgLabel} ${avgPrecision.toStringAsFixed(0)}%', style: textStyles.labelSmall?.copyWith(color: colors.secondary)),
                    Text('${strings.homePrecisionMaxLabel} ${maxPrecision.toStringAsFixed(0)}%', style: textStyles.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.bold)),
                  ]),
                ]),
        );
      }),
    ];
  }

  List<Widget> _buildQuickAccessSection({required BuildContext context, required ThotProvider provider, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    return [
      Text(strings.homeQuickAccessTitle, style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary)),
      const Gap(AppSpacing.md),
      Row(children: [
        for (int i = 0; i < provider.quickActions.length; i++) ...[
          if (i > 0) const Gap(AppSpacing.sm),
          Expanded(child: Builder(builder: (context) {
            final action = _getQuickAction(context, provider.quickActions[i], provider);
            return _QuickActionItem(icon: action['icon'] as Widget, label: action['label'] as String, onTap: action['onTap'] as VoidCallback);
          })),
        ],
      ]),
    ];
  }

  Widget _buildMaintenanceIndicatorsCard({required ThotProvider provider, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    final hasWear = provider.weapons.isNotEmpty && provider.weapons.any((w) => w.trackWear);
    final hasClean = provider.weapons.isNotEmpty && provider.weapons.any((w) => w.trackCleanliness);
    final hasAmmo = provider.ammos.isNotEmpty && provider.ammos.any((a) => a.trackStock);

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: _hardCardDecoration(colors, radius: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: colors.error, size: 20),
          const Gap(AppSpacing.sm),
          Text(strings.homeMaintenanceTitle, style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
        ]),
        const Gap(AppSpacing.sm),
        if (provider.weapons.isEmpty && provider.ammos.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(strings.homeMaintenanceEmpty, style: textStyles.bodyMedium?.copyWith(color: colors.secondary))))
        else ...[
          if (hasWear) ...[
            Builder(builder: (context) {
              final mostWorn = provider.weapons.where((w) => w.trackWear).reduce((a, b) => a.revisionProgress > b.revisionProgress ? a : b);
              return _MaintenanceBar(label: '${strings.homeMaintenanceRevisionLabel}${mostWorn.name}', value: (mostWorn.revisionProgress * 100).round(), valueUnit: "%", progress: mostWorn.revisionProgress.clamp(0.0, 1.0), colors: colors);
            }),
            if (hasClean || hasAmmo) const Gap(AppSpacing.md),
          ],
          if (hasClean) ...[
            Builder(builder: (context) {
              final dirtiest = provider.weapons.where((w) => w.trackCleanliness).reduce((a, b) => a.cleaningProgress > b.cleaningProgress ? a : b);
              return _MaintenanceBar(label: '${strings.homeMaintenanceCleaningLabel}${dirtiest.name}', value: (dirtiest.cleaningProgress * 100).round(), valueUnit: "%", progress: dirtiest.cleaningProgress.clamp(0.0, 1.0), colors: colors);
            }),
            if (hasAmmo) const Gap(AppSpacing.md),
          ],
          if (hasAmmo) ...[
            Builder(builder: (context) {
              final lowestStock = provider.ammos.where((a) => a.trackStock).reduce((a, b) => a.quantity < b.quantity ? a : b);
              final threshold = lowestStock.lowStockThreshold.toDouble();
              final rawInitial = lowestStock.initialQuantity.toDouble();
              final current = lowestStock.quantity.toDouble();
              final double criticality;
              if (rawInitial <= threshold) {
                criticality = current <= threshold ? 1.0 : 0.0;
              } else {
                criticality = (1.0 - ((current - threshold) / (rawInitial - threshold)).clamp(0.0, 1.0)).clamp(0.0, 1.0);
              }
              return _MaintenanceBar(label: '${strings.homeMaintenanceStockLabel}${lowestStock.name}', value: lowestStock.quantity, valueUnit: strings.homeRemainingSuffix, progress: criticality, colors: colors);
            }),
          ],
        ],
      ]),
    );
  }

  List<Widget> _buildLastSessionSection({required BuildContext context, required ThotProvider provider, required ColorScheme colors, required TextTheme textStyles}) {
    if (provider.sessions.isEmpty) return const [];
    final strings = AppStrings.of(context);
    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(strings.homeLastSessionTitle, style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary)),
        TextButton(onPressed: () => StatefulNavigationShell.of(context).goBranch(1), child: Text(strings.homeSeeAll, style: textStyles.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.bold))),
      ]),
      const Gap(AppSpacing.sm),
      _LastSessionCard(session: provider.sessions.first, provider: provider, colors: colors, textStyles: textStyles),
    ];
  }

  List<Widget> _buildStatsOverviewSection({required BuildContext context, required ThotProvider provider, required ColorScheme colors, required TextTheme textStyles}) {
    final strings = AppStrings.of(context);
    final avgShotsPerSession = provider.totalSessions == 0 ? '0' : (provider.totalRoundsFired / provider.totalSessions).toStringAsFixed(0);
    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(strings.homeStatsTitle, style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary)),
        TextButton(onPressed: () => _showStatisticsModal(context), child: Text(strings.homeSeeAll, style: textStyles.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.bold))),
      ]),
      const Gap(AppSpacing.xs),
      Row(children: [
        Expanded(child: _StatCard(title: strings.homeStatSessions, value: "${provider.totalSessions}", colors: colors, textStyles: textStyles)),
        const Gap(AppSpacing.sm),
        Expanded(child: _StatCard(title: strings.homeStatShotsFired, value: "${provider.totalRoundsFired}", colors: colors, textStyles: textStyles)),
        const Gap(AppSpacing.sm),
        Expanded(child: _StatCard(title: strings.homeStatWeapons, value: "${provider.weapons.length}", colors: colors, textStyles: textStyles)),
      ]),
      const Gap(AppSpacing.sm),
      Row(children: [
        Expanded(child: _StatCard(title: strings.statisticsAmmosLabel, value: "${provider.ammos.length}", colors: colors, textStyles: textStyles)),
        const Gap(AppSpacing.sm),
        Expanded(child: _StatCard(title: strings.statisticsAccessoriesLabel, value: "${provider.accessories.length}", colors: colors, textStyles: textStyles)),
        const Gap(AppSpacing.sm),
        Expanded(child: _StatCard(title: strings.statisticsShotsPerSessionLabel, value: avgShotsPerSession, colors: colors, textStyles: textStyles)),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final lastSessionSection = _buildLastSessionSection(context: context, provider: provider, colors: colors, textStyles: textStyles);
    final precisionSection = _buildPrecisionChartSection(provider: provider, colors: colors, textStyles: textStyles);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ..._buildHeaderSection(context: context, provider: provider, colors: colors, textStyles: textStyles),
            ..._buildQuickAccessSection(context: context, provider: provider, colors: colors, textStyles: textStyles),
            const Gap(AppSpacing.md),
            _buildMaintenanceIndicatorsCard(provider: provider, colors: colors, textStyles: textStyles),
            if (lastSessionSection.isNotEmpty) ...[const Gap(AppSpacing.md), ...lastSessionSection],
            const Gap(AppSpacing.md),
            ..._buildStatsOverviewSection(context: context, provider: provider, colors: colors, textStyles: textStyles),
            if (precisionSection.isNotEmpty) ...[const Gap(AppSpacing.lg), ...precisionSection],
            const Gap(AppSpacing.lg),
            _buildSectionTitle(title: strings.homeRewardsSectionTitle, textStyles: textStyles, colors: colors),
            const Gap(AppSpacing.md),
            _buildAchievementsButton(context: context, provider: provider, colors: colors, textStyles: textStyles),
            const Gap(AppSpacing.lg),
            _buildSectionTitle(title: strings.homeToolsSectionTitle, textStyles: textStyles, colors: colors),
            const Gap(AppSpacing.md),
            _buildTimerButton(context: context, colors: colors, textStyles: textStyles),
            const Gap(AppSpacing.md),
            _buildDiagnosticButton(context: context, colors: colors, textStyles: textStyles),
            const Gap(AppSpacing.md),
            _buildMilliemeButton(context: context, colors: colors, textStyles: textStyles),
            const Gap(AppSpacing.md),
            _buildTemplateButton(context: context, colors: colors, textStyles: textStyles),
          ]),
        ),
      ),
    );
  }
}

class _TemplateManagerScreen extends StatefulWidget {
  const _TemplateManagerScreen({super.key});

  @override
  State<_TemplateManagerScreen> createState() => _TemplateManagerScreenState();
}

class _TemplateManagerScreenState extends State<_TemplateManagerScreen> {
  final PageController _pageController = PageController();

  String _searchQuery = '';
  bool _sortByDate = true;
  bool _dateDescending = true;
  bool _sortByName = false;
  int _modeFilterIndex = 0; // 0 = tous, 1 = simples, 2 = détaillés

  ExerciseTemplate? _editingTemplate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shotsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _detailedMode = false;
  final List<ExerciseStep> _steps = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _shotsController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() {});
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _openEditor({ExerciseTemplate? template}) {
    setState(() {
      _editingTemplate = template;
      if (template == null) {
        _nameController.text = '';
        _shotsController.text = '';
        _distanceController.text = '';
        _notesController.text = '';
        _detailedMode = false;
        _steps
          ..clear();
      } else {
        _nameController.text = template.name;
        _shotsController.text = template.shotsFired.toString();
        _distanceController.text = template.distance.toString();
        _notesController.text = template.observations;
        _detailedMode = template.detailedMode;
        _steps
          ..clear()
          ..addAll(template.steps ?? const []);
      }
    });
    _goToPage(1);
  }

  int _computedTotalShots() {
    return _steps
        .where((s) => s.type == StepType.tir && s.shots != null)
        .fold<int>(0, (sum, s) => sum + (s.shots ?? 0));
  }

  int _computedMaxDistance() {
    final distances = _steps.map((s) => s.distanceM).whereType<int>();
    if (distances.isEmpty) return 0;
    return distances.reduce((a, b) => a > b ? a : b);
  }

  Future<void> _addOrEditStep({ExerciseStep? initial}) async {
    final step = await showModalBottomSheet<ExerciseStep>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TemplateStepSheet(initialStep: initial),
    );
    if (!mounted || step == null) return;
    setState(() {
      final idx = _steps.indexWhere((s) => s.id == step.id);
      if (idx >= 0) {
        _steps[idx] = step;
      } else {
        _steps.add(step);
      }
    });
  }

  void _deleteStep(String id) {
    setState(() {
      _steps.removeWhere((s) => s.id == id);
    });
  }

  void _moveStepUp(int index) {
    if (index <= 0) return;
    setState(() {
      final step = _steps.removeAt(index);
      _steps.insert(index - 1, step);
    });
  }

  void _moveStepDown(int index) {
    if (index >= _steps.length - 1) return;
    setState(() {
      final step = _steps.removeAt(index);
      _steps.insert(index + 1, step);
    });
  }

  void _toggleDateSort() {
    setState(() {
      _sortByDate = true;
      _sortByName = false;
      _dateDescending = !_dateDescending;
    });
  }

  void _activateNameSort() {
    setState(() {
      _sortByDate = false;
      _sortByName = true;
    });
  }

  void _cycleModeFilter() {
    setState(() {
      _modeFilterIndex = (_modeFilterIndex + 1) % 3;
    });
  }

  String _modeFilterLabel() {
    switch (_modeFilterIndex) {
      case 1:
        return 'Simples';
      case 2:
        return 'Détaillés';
      default:
        return 'Tous les modes';
    }
  }

  List<ExerciseTemplate> _filteredTemplates(ThotProvider provider) {
    var list = provider.exerciseTemplates.toList();

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.observations.toLowerCase().contains(q))
          .toList();
    }

    if (_modeFilterIndex == 1) {
      list = list.where((t) => !t.detailedMode).toList();
    } else if (_modeFilterIndex == 2) {
      list = list.where((t) => t.detailedMode).toList();
    }

    list.sort((a, b) {
      if (_sortByName) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      final cmp = a.createdAt.compareTo(b.createdAt);
      return _dateDescending ? -cmp : cmp;
    });

    return list;
  }

  Future<void> _saveTemplate(ThotProvider provider) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final shots = _detailedMode
        ? _computedTotalShots()
        : (int.tryParse(_shotsController.text.trim()) ?? 0);
    final distance = _detailedMode
        ? _computedMaxDistance()
        : (int.tryParse(_distanceController.text.trim()) ?? 0);
    final notes = _notesController.text.trim();

    final now = DateTime.now();
    final existing = _editingTemplate;
    final template = ExerciseTemplate(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      name: name,
      createdAt: existing?.createdAt ?? now,
      shotsFired: shots,
      distance: distance,
      detailedMode: _detailedMode,
      steps: _detailedMode ? List<ExerciseStep>.from(_steps) : null,
      observations: notes,
    );

    provider.saveExerciseTemplate(template);
    _goToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildListPage(),
                _buildEditorPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPage() {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final templates = _filteredTemplates(provider);

    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.homeTemplateTitle,
                style: textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openEditor(template: null),
                icon: const Icon(Icons.add, size: 18),
                label: Text(strings.saveAsTemplateButton),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          TextField(
            decoration: InputDecoration(
              hintText: strings.searchEllipsis,
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const Gap(AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(_sortByDate
                    ? (_dateDescending ? 'Date (récentes)' : 'Date (anciennes)')
                    : 'Date'),
                selected: _sortByDate,
                onSelected: (_) => _toggleDateSort(),
              ),
              ChoiceChip(
                label: const Text('Nom'),
                selected: _sortByName,
                onSelected: (_) => _activateNameSort(),
              ),
              ChoiceChip(
                label: Text(_modeFilterLabel()),
                selected: _modeFilterIndex != 0,
                onSelected: (_) => _cycleModeFilter(),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: templates.isEmpty
                ? Center(
                    child: Text(
                      strings.noTemplatesAvailable,
                      style: textStyles.bodyMedium
                          ?.copyWith(color: colors.secondary),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final t = templates[index];
                      final subtitle = t.detailedMode
                          ? '${t.steps?.length ?? 0} étapes · ${AppDateFormats.formatDateShort(context, t.createdAt)}'
                          : '${t.shotsFired} coups · ${t.distance} m · ${AppDateFormats.formatDateShort(context, t.createdAt)}';

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: colors.surface,
                        title: Text(
                          t.name,
                          style: textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: textStyles.bodySmall
                              ?.copyWith(color: colors.secondary),
                        ),
                        onTap: () => _openEditor(template: t),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_rounded, color: colors.error),
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(strings.confirmDeleteTitle),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text(strings.actionCancel),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      provider.deleteExerciseTemplate(t.id);
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text(strings.actionDelete),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPage() {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final isEditing = _editingTemplate != null;
    final distUnit = provider.useMetric ? 'm' : 'yd';

    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => _goToPage(0),
                color: colors.onSurface,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  isEditing ? strings.templateNameDialogTitle : strings.saveAsTemplateButton,
                  style: textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: strings.templateNameDialogTitle,
              hintText: strings.templateNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          if (!_detailedMode)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _shotsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.shotsFiredLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _distanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.shootingDistanceLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${strings.shotsFiredLabel}: ${_computedTotalShots()}',
                      style: textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${strings.shootingDistanceLabel}: ${_computedMaxDistance()} $distUnit',
                      textAlign: TextAlign.end,
                      style: textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Gap(AppSpacing.md),
          SwitchListTile.adaptive(
            value: _detailedMode,
            onChanged: (v) {
              setState(() {
                _detailedMode = v;
              });
            },
            title: Text(
              'Mode détaillé',
              style: (textStyles.bodyMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_detailedMode) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Étapes',
                          style: textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _addOrEditStep(),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(strings.exerciseActionAdd),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    if (_steps.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Text(
                          'Aucune étape',
                          style: textStyles.bodyMedium
                              ?.copyWith(color: colors.secondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...List.generate(_steps.length, (index) {
                        final s = _steps[index];
                        final title = strings.exerciseStepTypeLabel(s.type);
                        final parts = <String>[];
                        if (s.type == StepType.tir && s.shots != null) {
                          parts.add('${s.shots} ${strings.exerciseNarrativeShotsWord}');
                        }
                        if (s.distanceM != null) parts.add('${s.distanceM} $distUnit');
                        if ((s.target ?? '').trim().isNotEmpty) parts.add(s.target!.trim());
                        final subtitle = parts.isEmpty ? '—' : parts.join(' · ');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: colors.outline),
                          ),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    onPressed: index > 0 ? () => _moveStepUp(index) : null,
                                    icon: Icon(
                                      Icons.arrow_upward_rounded,
                                      color: index > 0 ? colors.primary : colors.outline,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    onPressed: index < _steps.length - 1 ? () => _moveStepDown(index) : null,
                                    icon: Icon(
                                      Icons.arrow_downward_rounded,
                                      color: index < _steps.length - 1 ? colors.primary : colors.outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              title,
                              style: textStyles.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: textStyles.bodySmall
                                  ?.copyWith(color: colors.secondary),
                            ),
onTap: () => _addOrEditStep(initial: s),
                            trailing: IconButton(
                              onPressed: () => _deleteStep(s.id),
                              icon: Icon(Icons.delete_rounded, color: colors.error),
                            ),
                          ),
                        );
                      }),
                    const Gap(AppSpacing.md),
                  ],
                  TextField(
                    controller: _notesController,
                    minLines: 4,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: strings.observationsLabel,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _goToPage(0),
                    child: Text(strings.actionCancel),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _saveTemplate(provider),
                    child: Text(strings.saveAsTemplateButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateStepSheet extends StatefulWidget {
  final ExerciseStep? initialStep;

  const _TemplateStepSheet({this.initialStep});

  @override
  State<_TemplateStepSheet> createState() => _TemplateStepSheetState();
}

class _TemplateStepSheetState extends State<_TemplateStepSheet> {
  StepType _type = StepType.tir;
  ShootingPosition? _position;

  final _distanceController = TextEditingController();
  final _shotsController = TextEditingController();
  final _targetController = TextEditingController();
  final _weaponFromController = TextEditingController();
  final _weaponToController = TextEditingController();
  ReloadType? _reloadType;
  MovementType? _movementType;
  final _durationController = TextEditingController();
  final _triggerController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialStep;
    if (initial == null) return;

    _type = initial.type;
    _position = initial.position;
    _reloadType = initial.reloadType;
    _movementType = initial.movementType;

    _distanceController.text = initial.distanceM?.toString() ?? '';
    _shotsController.text = initial.shots?.toString() ?? '';
    _targetController.text = initial.target ?? '';
    _weaponFromController.text = initial.weaponFrom ?? '';
    _weaponToController.text = initial.weaponTo ?? '';
    _durationController.text = initial.durationSeconds?.toString() ?? '';
    _triggerController.text = initial.trigger ?? '';
    _commentController.text = initial.comment ?? '';
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _shotsController.dispose();
    _targetController.dispose();
    _weaponFromController.dispose();
    _weaponToController.dispose();
    _durationController.dispose();
    _triggerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final distUnit = provider.useMetric ? 'm' : 'yd';
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    InputDecoration decoration(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: colors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: colors.primary, width: 1.6),
          ),
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Gap(10),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: colors.outline.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.initialStep == null
                        ? strings.exerciseNewStepTitle
                        : strings.exerciseEditStepTitle,
                    style: textStyles.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Gap(8),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.exerciseStepTypeTitle,
                    style: textStyles.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StepType.values.map((t) {
                      final selected = _type == t;
                      return ChoiceChip(
                        label: Text(strings.exerciseStepTypeLabel(t)),
                        selected: selected,
                        onSelected: (_) => setState(() => _type = t),
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected ? colors.primary : colors.outline,
                          ),
                        ),
                        labelStyle: textStyles.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      );
                    }).toList(),
                  ),
                  const Gap(AppSpacing.md),
                  Text(
                    strings.exerciseStepPositionTitle,
                    style: textStyles.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('·'),
                        selected: _position == null,
                        onSelected: (_) => setState(() => _position = null),
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: _position == null
                                ? colors.primary
                                : colors.outline,
                          ),
                        ),
                      ),
                      ...ShootingPosition.values.map((p) {
                        final selected = _position == p;
                        return ChoiceChip(
                          label: Text(strings.exercisePositionLabel(p)),
                          selected: selected,
                          onSelected: (_) => setState(() => _position = p),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color:
                                  selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const Gap(AppSpacing.md),
                  if (_type == StepType.tir) ...[
                    TextField(
                      controller: _shotsController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldShots}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                          '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.deplacement) ...[
                    Text(
                      strings.exerciseFieldMovementType,
                      style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('·'),
                          selected: _movementType == null,
                          onSelected: (_) => setState(() => _movementType = null),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: _movementType == null
                                  ? colors.primary
                                  : colors.outline,
                            ),
                          ),
                        ),
                        ...MovementType.values.map((t) {
                          final selected = _movementType == t;
                          return ChoiceChip(
                            label: Text(strings.exerciseMovementTypeLabel(t)),
                            selected: selected,
                            onSelected: (_) => setState(() => _movementType = t),
                            selectedColor: colors.primary.withValues(alpha: 0.2),
                            backgroundColor: colors.surface,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: selected ? colors.primary : colors.outline,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.rechargement) ...[
                    Text(
                      strings.exerciseFieldReloadType,
                      style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReloadType.values.map((t) {
                        final selected = _reloadType == t;
                        return ChoiceChip(
                          label: Text(strings.exerciseReloadTypeLabel(t)),
                          selected: selected,
                          onSelected: (_) => setState(() => _reloadType = t),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ] else if (_type == StepType.transition) ...[
                    TextField(
                      controller: _weaponFromController,
                      decoration: decoration(
                          '${strings.exerciseFieldWeaponFrom}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _weaponToController,
                      decoration: decoration(
                          '${strings.exerciseFieldWeaponTo}${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.miseEnJoue) ...[
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                          '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.attente) ...[
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDuration} (s)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _triggerController,
                      decoration: decoration(
                          '${strings.exerciseFieldTrigger}${strings.exerciseOptionalHint}'),
                    ),
                  ] else ...[
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ],
                  const Gap(AppSpacing.md),
                  TextField(
                    controller: _commentController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: decoration(strings.exerciseStepCommentLabel),
                  ),
                  const Gap(AppSpacing.lg),
                  SizedBox(
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.cardPremium,
                      ),
                      child: FilledButton(
                        onPressed: () {
                          final distanceM =
                              int.tryParse(_distanceController.text.trim());
                          final shots =
                              int.tryParse(_shotsController.text.trim());
                          final durationSeconds =
                              int.tryParse(_durationController.text.trim());

                          final step = ExerciseStep(
                            id: widget.initialStep?.id ??
                                DateTime.now()
                                    .microsecondsSinceEpoch
                                    .toString(),
                            type: _type,
                            position: _position,
                            distanceM: distanceM,
                            shots: shots,
                            target: _targetController.text.trim().isEmpty
                                ? null
                                : _targetController.text.trim(),
                            weaponFrom:
                                _weaponFromController.text.trim().isEmpty
                                    ? null
                                    : _weaponFromController.text.trim(),
                            weaponTo: _weaponToController.text.trim().isEmpty
                                ? null
                                : _weaponToController.text.trim(),
                            reloadType: _reloadType,
                            movementType: _movementType,
                            durationSeconds: durationSeconds,
                            trigger: _triggerController.text.trim().isEmpty
                                ? null
                                : _triggerController.text.trim(),
                            comment: _commentController.text.trim().isEmpty
                                ? null
                                : _commentController.text.trim(),
                          );

                          Navigator.of(context).pop(step);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Text(
                          widget.initialStep == null
                              ? strings.exerciseActionAdd
                              : strings.exerciseActionSave,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeStandardActionCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showProBadge;
  final ColorScheme colors;
  final TextTheme textStyles;

  const _HomeStandardActionCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showProBadge = false,
    required this.colors,
    required this.textStyles,
  });

  BoxDecoration _hardCardDecoration(ColorScheme colors, {double radius = 16}) {
    final isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: isDark
          ? null
          : Border.all(
              color: LightColors.surfaceHighlight,
              width: 1.35,
            ),
      boxShadow: AppShadows.cardPremium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: _hardCardDecoration(colors, radius: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    child: Center(child: leading),
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        Text(
                          subtitle,
                          style: textStyles.bodySmall?.copyWith(
                            color: colors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.secondary,
                    size: 20,
                  ),
                ],
              ),
            ),
            if (showProBadge)
              Positioned(
                top: 10,
                right: 10,
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
                    style: textStyles.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _getQuickAction(
  BuildContext context,
  String actionId,
  ThotProvider provider,
) {
  final colors = Theme.of(context).colorScheme;
  final strings = AppStrings.of(context);

  switch (actionId) {
    case 'new_session':
      return {
        'icon': Icon(
          Icons.add_circle_outline_rounded,
          color: colors.primary,
          size: 24,
        ),
        'label': strings.quickActionLabelSession,
        'onTap': () {
          if (!provider.canAddSession()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.getLimitMessage('session'))),
            );
            context.push('/pro');
            return;
          }
          context.push('/sessions/new');
        },
      };

    case 'new_weapon':
      return {
        'icon': SvgPicture.asset(
          'assets/images/gun.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        'label': strings.quickActionLabelWeapon,
        'onTap': () {
          if (!provider.canAddWeapon()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.getLimitMessage('weapon'))),
            );
            context.push('/pro');
            return;
          }
          context.push('/inventory/add?itemType=ARME');
        },
      };

    case 'new_ammo':
      return {
        'icon': SvgPicture.asset(
          'assets/images/bullet.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        'label': strings.quickActionLabelAmmo,
        'onTap': () {
          if (!provider.canAddAmmo()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.getLimitMessage('ammo'))),
            );
            context.push('/pro');
            return;
          }
          context.push('/inventory/add?itemType=MUNITION');
        },
      };

    case 'new_accessory':
      return {
        'icon': Icon(
          Icons.inventory_2_rounded,
          color: colors.primary,
          size: 24,
        ),
        'label': strings.quickActionLabelAccessory,
        'onTap': () {
          if (!provider.canAddAccessory()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.getLimitMessage('accessory'))),
            );
            context.push('/pro');
            return;
          }
          context.push('/inventory/add?itemType=ACCESSOIRE');
        },
      };

    case 'toggle_theme':
      return {
        'icon': Icon(Icons.dark_mode_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelTheme,
        'onTap': () => provider.toggleTheme(),
      };

    case 'view_weapons':
      return {
        'icon': Icon(
          Icons.inventory_2_rounded,
          color: colors.primary,
          size: 24,
        ),
        'label': strings.quickActionLabelWeapon,
        'onTap': () => StatefulNavigationShell.of(context).goBranch(2),
      };

    case 'view_ammo':
      return {
        'icon': SvgPicture.asset(
          'assets/images/bullet.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        'label': 'Munitions',
        'onTap': () => StatefulNavigationShell.of(context).goBranch(2),
      };

    case 'view_accessories':
      return {
        'icon': Icon(
          Icons.inventory_2_rounded,
          color: colors.primary,
          size: 24,
        ),
        'label': 'Accessoires',
        'onTap': () => StatefulNavigationShell.of(context).goBranch(2),
      };

    case 'view_sessions':
      return {
        'icon': Icon(Icons.history_rounded, color: colors.primary, size: 24),
        'label': 'Séances',
        'onTap': () => StatefulNavigationShell.of(context).goBranch(1),
      };

    case 'settings':
      return {
        'icon': Icon(Icons.settings_rounded, color: colors.primary, size: 24),
        'label': 'Paramètres',
        'onTap': () => context.go('/settings'),
      };

    case 'diagnostic':
      return {
        'icon': Icon(
          Icons.medical_services_outlined,
          color: colors.primary,
          size: 24,
        ),
        'label': strings.quickActionLabelDiagnostic,
        'onTap': () => _showDiagnosticModal(context),
      };

    case 'timer':
      return {
        'icon': Icon(Icons.timer_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelTimer,
        'onTap': () => _showTimerModal(context),
      };

    case 'millieme':
      return {
        'icon': Icon(Icons.straighten_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelMillieme,
        'onTap': () => _showMilliemeModal(context),
      };

    default:
      return {
        'icon':
            Icon(Icons.help_outline_rounded, color: colors.primary, size: 24),
        'label': 'Action',
        'onTap': () {},
      };
  }
}

class _QuickActionItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Theme.of(context).brightness == Brightness.dark
                ? null
                : Border.all(
                    color: LightColors.surfaceHighlight,
                    width: 1.35,
                  ),
            boxShadow: AppShadows.cardPremium,
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: LightColors.primaryText),
              child: IconTheme.merge(
                data: const IconThemeData(color: LightColors.icon),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const Gap(AppSpacing.xs),
                    Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaintenanceBar extends StatelessWidget {
  final String label;
  final int value;
  final String valueUnit;
  final double progress;
  final ColorScheme colors;

  const _MaintenanceBar({
    required this.label,
    required this.value,
    required this.valueUnit,
    required this.progress,
    required this.colors,
  });

  Color _getProgressColor(double progress) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    if (normalizedProgress <= 0.33) {
      return const Color(0xFF3A7D44);
    } else if (normalizedProgress <= 0.66) {
      return const Color(0xFFC2A14A);
    } else {
      return const Color(0xFFD64545);
    }
  }

  @override
  Widget build(BuildContext context) {
    final barColor = _getProgressColor(progress);
    final valueColor = barColor;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTextStyle.merge(
      style: TextStyle(color: colors.onSurface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$value$valueUnit",
                style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: colors.outline.withValues(alpha: 0.2),
            color: barColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final ColorScheme colors;
  final TextTheme textStyles;

  const _StatCard({
    required this.title,
    required this.value,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Theme.of(context).brightness == Brightness.dark
            ? null
            : Border.all(
                color: LightColors.surfaceHighlight,
                width: 1.35,
              ),
        boxShadow: AppShadows.cardPremium,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onSurface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: (textStyles.labelSmall ?? const TextStyle()).copyWith(
                color: colors.secondary,
              ),
            ),
            const Gap(AppSpacing.xs),
            Text(
              value,
              style: (textStyles.titleMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastSessionCard extends StatelessWidget {
  final session;
  final ThotProvider provider;
  final ColorScheme colors;
  final TextTheme textStyles;

  const _LastSessionCard({
    required this.session,
    required this.provider,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final accuracy = session.averagePrecision.toStringAsFixed(0);
    final hasPrecision = session.hasCountedPrecision;

    String weaponName = "—";
    String ammoName = "—";
    if (session.exercises.isNotEmpty) {
      final firstEx = session.exercises.first;
      weaponName = weaponDisplayName(provider, firstEx);
      ammoName = ammoDisplayName(provider, firstEx);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '/sessions/exercises?sessionId=${Uri.encodeComponent(session.id)}',
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Theme.of(context).brightness == Brightness.dark
                ? null
                : Border.all(
                    color: LightColors.surfaceHighlight,
                    width: 1.35,
                  ),
            boxShadow: AppShadows.cardPremium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: 14,
                              color: colors.secondary,
                            ),
                            const Gap(4),
                            Text(
                              AppDateFormats.formatDateTimeShort(
                                context,
                                session.date,
                              ),
                              style: textStyles.labelSmall?.copyWith(
                                color: colors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasPrecision)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: LightColors.surfaceHighlight,
                          width: 1.35,
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/target.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              colors.onPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            "$accuracy%",
                            style: textStyles.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Gap(AppSpacing.sm),
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outline,
                    width: 1.2,
                  ),
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: colors.onSurface),
                  child: IconTheme.merge(
                    data: IconThemeData(color: colors.primary),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/gun.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      colors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    strings.quickActionLabelWeapon,
                                    style: (textStyles.labelSmall ??
                                            const TextStyle())
                                        .copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                weaponName,
                                style: (textStyles.bodySmall ??
                                        const TextStyle())
                                    .copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        Container(
                          width: 1,
                          height: 32,
                          color: colors.outline,
                        ),
                        const Gap(AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/bullet.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      colors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    strings.quickActionLabelAmmo,
                                    style: (textStyles.labelSmall ??
                                            const TextStyle())
                                        .copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                ammoName,
                                style: (textStyles.bodySmall ??
                                        const TextStyle())
                                    .copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SessionStat(
                    icon: SvgPicture.asset(
                      'assets/images/train.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        colors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: strings.exercisesLabel,
                    value: "${session.exercises.length}",
                    colors: colors,
                    textStyles: textStyles,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: colors.outline,
                  ),
                  _SessionStat(
                    icon: SvgPicture.asset(
                      'assets/images/hit.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        colors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: strings.shotsFiredLabel,
                    value: "${session.totalRounds}",
                    colors: colors,
                    textStyles: textStyles,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: colors.outline,
                  ),
                  _SessionStat(
                    icon: Icon(
                      Icons.place_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                    label: strings.locationLabel,
                    value: session.location.split(' ').take(2).join(' '),
                    colors: colors,
                    textStyles: textStyles,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final ColorScheme colors;
  final TextTheme textStyles;

  const _SessionStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(color: colors.onSurface),
      child: IconTheme.merge(
        data: IconThemeData(color: colors.primary),
        child: Column(
          children: [
            icon,
            const Gap(4),
            Text(
              value,
              style: (textStyles.labelLarge ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            Text(
              label,
              style: (textStyles.labelSmall ?? const TextStyle()).copyWith(
                color: colors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _globalAveragePrecision(ThotProvider provider) {
  final sessions =
      provider.sessions.where((s) => s.hasCountedPrecision).toList();
  if (sessions.isEmpty) return '—';
  final total = sessions.fold<double>(0, (sum, s) => sum + s.averagePrecision);
  final avg = total / sessions.length;
  return "${avg.toStringAsFixed(0)}%";
}

String _bestSessionPrecision(ThotProvider provider) {
  final sessions =
      provider.sessions.where((s) => s.hasCountedPrecision).toList();
  if (sessions.isEmpty) return '—';
  final best =
      sessions.map((s) => s.averagePrecision).reduce((a, b) => a > b ? a : b);
  return "${best.toStringAsFixed(0)}%";
}

class _ProCornerButton extends StatelessWidget {
  final bool isPremium;
  final bool isOnline;
  final int unreadCount;
  final VoidCallback onTap;
  final VoidCallback onBellTap;

  const _ProCornerButton({
    super.key,
    required this.isPremium,
    required this.isOnline,
    required this.unreadCount,
    required this.onTap,
    required this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final bell = GestureDetector(
      onTap: onBellTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, size: 26, color: colors.onSurface),
          if (unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFD64545),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isOnline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.outline.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.wifi_off_rounded, size: 13, color: colors.outline),
              const Gap(5),
              Text(
                strings.offlineBadgeLabel,
                style: textStyles.labelSmall?.copyWith(
                  color: colors.outline,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ]),
          ),
        if (!isOnline) const Gap(10),
        bell,
      ],
    );
  }
}

// ─── Notification panel overlay ───────────────────────────────────────────────
class _NotificationPanel extends StatefulWidget {
  final double topOffset;
  final double leftOffset;
  final double width;
  final List<_MaintenanceAlert> alerts;
  final void Function(String id) onMarkRead;
  final VoidCallback onMarkAllRead;
  final void Function(String id) onDelete;
  final VoidCallback onDeleteAllRead;
  final void Function(String itemId) onNavigate;
  final VoidCallback onDismiss;

  const _NotificationPanel({
    required this.topOffset,
    required this.leftOffset,
    required this.width,
    required this.alerts,
    required this.onMarkRead,
    required this.onMarkAllRead,
    required this.onDelete,
    required this.onDeleteAllRead,
    required this.onNavigate,
    required this.onDismiss,
  });

  @override
  State<_NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<_NotificationPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allRead = widget.alerts.every((a) => a.isRead);
    final hasRead = widget.alerts.any((a) => a.isRead);
    // Kaki clair pour le divider — même teinte que les séparateurs de la dernière séance
    final dividerColor = const Color(0xFFC2A14A).withValues(alpha: 0.25);

    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: widget.onDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
      ),
      Positioned(
        top: widget.topOffset,
        left: widget.leftOffset,
        width: widget.width,
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark
                      ? null
                      : Border.all(
                          color: LightColors.surfaceHighlight, width: 1.35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                          alpha: isDark ? 0.45 : 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                    child: Row(children: [
                      Icon(Icons.notifications_outlined,
                          size: 18, color: colors.primary),
                      const Gap(8),
                      Expanded(
                        child: Text(strings.notifPanelTitle,
                            style: textStyles.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      if (!allRead)
                        TextButton(
                          onPressed: widget.onMarkAllRead,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(strings.notifMarkAllRead,
                              style: textStyles.labelSmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      if (allRead && hasRead)
                        TextButton(
                          onPressed: widget.onDeleteAllRead,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(strings.notifDeleteAll,
                              style: textStyles.labelSmall?.copyWith(
                                  color: colors.error,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ]),
                  ),
                  Divider(height: 1, color: dividerColor),

                  // List
                  if (widget.alerts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        Icon(Icons.check_circle_outline_rounded,
                            color: colors.primary, size: 40),
                        const Gap(8),
                        Text(strings.notifPanelEmpty,
                            style: textStyles.bodyMedium
                                ?.copyWith(color: colors.secondary),
                            textAlign: TextAlign.center),
                      ]),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.alerts.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: dividerColor),
                        itemBuilder: (context, index) {
                          final alert = widget.alerts[index];
                          return _AlertTile(
                            alert: alert,
                            onMarkRead: () => widget.onMarkRead(alert.id),
                            onDelete: () => widget.onDelete(alert.id),
                            onNavigate: () => widget.onNavigate(alert.itemId),
                          );
                        },
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ── Alert tile ────────────────────────────────────────────────────────────────

class _AlertTile extends StatelessWidget {
  final _MaintenanceAlert alert;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;
  final VoidCallback onNavigate;

  const _AlertTile({
    required this.alert,
    required this.onMarkRead,
    required this.onDelete,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    // Determine icon, label, subtitle, color
    IconData icon;
    String typeLabel;
    String subtitle;
    Color barColor;

    switch (alert.type) {
      case _AlertType.wear:
        icon = Icons.handyman_rounded;
        typeLabel = strings.notifAlertWear;
        subtitle = '${(alert.progress * 100).toInt()}%';
        barColor = alert.progress >= 1.0
            ? const Color(0xFFD64545)
            : const Color(0xFFC2A14A);
        break;
      case _AlertType.fouling:
        icon = Icons.cleaning_services_rounded;
        typeLabel = strings.notifAlertFouling;
        subtitle = '${(alert.progress * 100).toInt()}%';
        barColor = alert.progress >= 1.0
            ? const Color(0xFFD64545)
            : const Color(0xFFC2A14A);
        break;
      case _AlertType.stock:
        icon = Icons.inventory_2_rounded;
        typeLabel = strings.notifAlertStock;
        subtitle = '${(alert.progress * 100).toInt()}%';
        barColor = alert.progress >= 1.0
            ? const Color(0xFFD64545)
            : const Color(0xFFC2A14A);
        break;
      case _AlertType.document:
        icon = Icons.picture_as_pdf_rounded;
        typeLabel = strings.notifAlertDocument;
        final docName = alert.documentName ?? typeLabel;
        final days = alert.daysRemaining ?? 0;
        if (days < 0) {
          subtitle = 'Votre garantie "$docName" est expirée.';
          barColor = const Color(0xFFD64545);
        } else if (days == 0) {
          subtitle = 'Votre garantie "$docName" a expiré aujourd\'hui.';
          barColor = const Color(0xFFD64545);
        } else {
          subtitle =
              'Votre garantie "$docName" arrive à expiration dans $days jour${days > 1 ? 's' : ''}.';
          barColor = days <= 7
              ? const Color(0xFFD64545)
              : const Color(0xFFC2A14A);
        }
        break;
    }

    return GestureDetector(
      onTap: () {
        if (!alert.isRead) onMarkRead();
        if (alert.type != _AlertType.document) {
          onNavigate();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: alert.isRead ? 0.55 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 15, color: barColor),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.type == _AlertType.document
                            ? '${alert.itemName} — ${alert.documentName ?? ''}'
                            : alert.itemName,
                        style: textStyles.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$typeLabel — $subtitle',
                        style: textStyles.labelSmall?.copyWith(
                            color: barColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (!alert.isRead)
                  GestureDetector(
                    onTap: onMarkRead,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.check_rounded,
                          size: 18, color: colors.primary),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: colors.secondary),
                    ),
                  ),
              ]),
              if (alert.type != _AlertType.document) ...[
                const Gap(6),
                LinearProgressIndicator(
                  value: alert.progress.clamp(0.0, 1.0),
                  backgroundColor: colors.outline.withValues(alpha: 0.15),
                  color: barColor,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
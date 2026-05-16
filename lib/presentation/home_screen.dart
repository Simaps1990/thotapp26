import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:thot/data/thot_provider.dart';
import 'package:thot/presentation/diagnostic_screen.dart';
import 'package:thot/presentation/ballistic_calc_screen.dart';
import 'package:thot/presentation/shooting_timer_screen.dart';
import 'package:thot/presentation/color_pod_screen.dart';
import 'package:thot/presentation/shooting_tables_screen.dart';
import 'package:thot/presentation/achievements_screen.dart';
import 'package:thot/presentation/statistics_screen.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/exercise_display.dart';
import 'package:thot/utils/thresholds.dart';
import 'package:thot/l10n/app_strings.dart';
import '../utils/achievement_definitions.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/training_history.dart';
import 'package:thot/widgets/tutorial_overlay.dart';

// ── Modèle d'alerte ──────────────────────────────────────────────────────────

enum _AlertType { wear, fouling, stock, document }

class _MaintenanceAlert {
  final String id;

  /// platformId, ammoId, or itemId depending on type
  final String itemId;
  final String itemName;
  final _AlertType type;

  /// progress 0.0–1.0 for wear/fouling/stock, daysRemaining for document
  final double progress;

  /// Only for document alerts
  final String? documentName;
  final int? daysRemaining;
  bool isRead;
  bool isDeleted;

  _MaintenanceAlert({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.progress,
    this.documentName,
    this.daysRemaining,
    this.isRead = false,
    this.isDeleted = false,
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
    'isDeleted': isDeleted,
  };

  factory _MaintenanceAlert.fromJson(Map<String, dynamic> j) =>
      _MaintenanceAlert(
        id: j['id'] as String,
        itemId: j['itemId'] as String? ?? j['platformId'] as String? ?? '',
        itemName:
            j['itemName'] as String? ?? j['platformName'] as String? ?? '',
        type: _AlertType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => _AlertType.wear,
        ),
        progress: (j['progress'] as num).toDouble(),
        documentName: j['documentName'] as String?,
        daysRemaining: j['daysRemaining'] as int?,
        isRead: j['isRead'] as bool? ?? false,
        isDeleted: j['isDeleted'] as bool? ?? false,
      );
}

void _openQuickToolSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.96,
      minChildSize: 0.70,
      maxChildSize: 0.98,
      expand: false,
      builder: (_, scrollController) => child,
    ),
  );
}

void _showCalculationToolsModal(BuildContext context) {
  _openQuickToolSheet(context, const BallisticCalcScreen());
}

// ── Écran d'accueil ──────────────────────────────────────────────────────────
void _showDiagnosticModal(BuildContext context) {
  final provider = Provider.of<ThotProvider>(context, listen: false);
  if (provider.isToolLockedForFree('diagnostics')) {
    showProModal(context);
    return;
  }
  _openQuickToolSheet(context, const DiagnosticScreen());
}

void _showMilliemeModal(BuildContext context) {
  _openQuickToolSheet(context, const BallisticCalcScreen());
}

void _showTimerModal(BuildContext context) {
  _openQuickToolSheet(context, const ShootingTimerScreen());
}

void _showAchievementsModal(BuildContext context) {
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
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LightColors.iconInactive.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(AppSpacing.md),
            const Expanded(child: AchievementsScreen(useSafeArea: false)),
          ],
        ),
      );
    },
  );
}

void _showStatisticsModal(BuildContext context) {
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
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LightColors.iconInactive.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(AppSpacing.md),
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

void _showColorPodModal(BuildContext context) {
  _openQuickToolSheet(context, const ColorPodScreen());
}

void _showShootingTablesModal(BuildContext context) {
  _openQuickToolSheet(context, const ShootingTablesScreen());
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

  final ScrollController _homeScrollController = ScrollController();
  final GlobalKey _bellKey = GlobalKey();
  final GlobalKey _quickAccessKey = GlobalKey();
  final GlobalKey _trainingKey = GlobalKey();
  final GlobalKey _trainingHighlightKey = GlobalKey();
  final GlobalKey _indicatorsPlaceholderKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _rewardsKey = GlobalKey();
  final GlobalKey _newSessionKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  OverlayEntry? _tutorialOverlayEntry;
  List<_MaintenanceAlert> _alerts = [];
  static const _prefKey = 'maintenance_alerts_v1';
  static const _deletedPrefKey = 'maintenance_alerts_deleted_v1';
  static const _tutorialNeverShowAgainKey = 'home_tutorial_never_show_again_v1';
  static bool _hasShownDevSnackbar = false;

  bool _isOnline = true;
  // ignore: cancel_subscriptions
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _tutorialCheckScheduled = false;
  bool _tutorialDismissedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAlerts();
      _initConnectivity();
      _loadTrainingHistory();
      _checkAndShowTutorial();
      _checkDevLimitsFlag();
    });
    TrainingHistory.updates.addListener(_onTrainingHistoryUpdate);
  }

  void _checkDevLimitsFlag() {
    if (!mounted || _hasShownDevSnackbar) return;
    final provider = context.read<ThotProvider>();
    if (provider.isFreeLimitsDisabled) {
      _hasShownDevSnackbar = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'TEST: Mode Payant désactivé',
            style: TextStyle(fontSize: 12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }
  }

  Future<void> _checkAndShowTutorial() async {
    if (_tutorialDismissedThisSession) return;
    final prefs = await SharedPreferences.getInstance();
    final neverShowAgain = prefs.getBool(_tutorialNeverShowAgainKey) ?? false;
    if (!neverShowAgain && mounted && _tutorialOverlayEntry == null) {
      _showTutorial();
    }
  }

  void _scheduleTutorialCheck() {
    if (_tutorialCheckScheduled || !mounted) return;
    _tutorialCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _tutorialCheckScheduled = false;
      if (!mounted) return;
      await _checkAndShowTutorial();
    });
  }

  void _showTutorial() {
    final strings = AppStrings.of(context);
    final steps = [
      TutorialStep(
        targetKey: _bellKey,
        title: strings.tutorialHomeBellTitle,
        description: strings.tutorialHomeBellDescription,
      ),
      TutorialStep(
        targetKey: _quickAccessKey,
        title: strings.tutorialHomeQuickAccessTitle,
        description: strings.tutorialHomeQuickAccessDescription,
      ),
      TutorialStep(
        targetKey: _trainingHighlightKey,
        title: strings.tutorialHomeTrackingTitle,
        description: strings.tutorialHomeTrackingDescription,
      ),
      TutorialStep(
        targetKey: _indicatorsPlaceholderKey,
        title: strings.tutorialHomeIndicatorsTitle,
        description: strings.tutorialHomeIndicatorsDescription,
      ),
      TutorialStep(
        targetKey: _statsKey,
        title: strings.tutorialHomeStatsTitle,
        description: strings.tutorialHomeStatsDescription,
      ),
      TutorialStep(
        targetKey: _rewardsKey,
        title: strings.tutorialHomeRewardsTitle,
        description: strings.tutorialHomeRewardsDescription,
      ),
    ];

    _tutorialOverlayEntry = OverlayEntry(
      builder: (_) => TutorialOverlay(
        steps: steps,
        onStepChanged: _onTutorialStepChanged,
        onComplete: () {
          _hideTutorial();
        },
        onSkip: () {
          _hideTutorial();
        },
        onNeverShowAgain: () async {
          _hideTutorial();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_tutorialNeverShowAgainKey, true);
        },
      ),
    );

    final rootOverlay = Overlay.of(context, rootOverlay: true);
    rootOverlay.insert(_tutorialOverlayEntry!);
  }

  void _onTutorialStepChanged(int stepIndex) {
    final stepKeys = <GlobalKey>[
      _bellKey,
      _quickAccessKey,
      _trainingHighlightKey,
      _indicatorsPlaceholderKey,
      _statsKey,
      _rewardsKey,
    ];
    final stepAlignments = <double>[0.12, 0.12, 0.12, 0.05, 0.12, 0.12];
    if (stepIndex < 0 || stepIndex >= stepKeys.length) return;

    final contextForStep = stepKeys[stepIndex].currentContext;
    if (contextForStep == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || stepKeys[stepIndex].currentContext == null) return;
      Scrollable.ensureVisible(
        stepKeys[stepIndex].currentContext!,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        alignment: stepAlignments[stepIndex],
      );
    });
  }

  void _hideTutorial() {
    _tutorialOverlayEntry?.remove();
    _tutorialOverlayEntry = null;
    _tutorialDismissedThisSession = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _onTrainingHistoryUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _loadTrainingHistory() async {
    await TrainingHistory.load();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-sync alerts whenever provider data changes (new session, stock update, etc.)
    _syncAlerts();
    _scheduleTutorialCheck();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _homeScrollController.dispose();
    TrainingHistory.updates.removeListener(_onTrainingHistoryUpdate);
    _tutorialOverlayEntry?.remove();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    // Initial check
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() => _isOnline = !result.contains(ConnectivityResult.none));
    }
    // Stream for subsequent changes — uses OS APIs, no network request
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (mounted) {
        setState(() => _isOnline = !results.contains(ConnectivityResult.none));
      }
    });
  }

  Future<void> _syncAlerts() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    final saved = <String, bool>{};
    final deleted = <String>{};
    if (raw != null) {
      try {
        final List decoded = jsonDecode(raw) as List;
        for (final item in decoded) {
          final m = _MaintenanceAlert.fromJson(item as Map<String, dynamic>);
          saved[m.id] = m.isRead;
          if (m.isDeleted) deleted.add(m.id);
        }
      } catch (_) {}
    }
    // Charger les IDs supprimés persistés (survivent aux syncs)
    final deletedList = prefs.getStringList(_deletedPrefKey) ?? const [];
    deleted.addAll(deletedList);

    // Migration des anciens IDs de documents (name.hashCode -> path.hashCode)
    final migratedDeleted = <String>{};
    final providerItems = [
      ...provider.platforms.map((p) => (p.id, p.documents)),
      ...provider.ammos.map((a) => (a.id, a.documents)),
      ...provider.accessories.map((a) => (a.id, a.documents)),
    ];
    for (final deletedId in deleted) {
      // Vérifier si c'est un ancien ID de document (contient "_doc_")
      if (deletedId.contains('_doc_')) {
        // Essayer de trouver le document correspondant et migrer l'ID
        for (final (itemId, docs) in providerItems) {
          for (final doc in docs) {
            final oldId = '${itemId}_doc_${doc.name.hashCode}';
            final newId = '${itemId}_doc_${doc.path.hashCode}';
            if (deletedId == oldId) {
              migratedDeleted.add(newId);
            }
          }
        }
      } else {
        migratedDeleted.add(deletedId);
      }
    }
    deleted.addAll(migratedDeleted);

    final fresh = <_MaintenanceAlert>[];
    final now = DateTime.now();

    // Wear & fouling alerts (platforms)
    for (final w in provider.platforms.where((p) => !p.isHidden)) {
      if (w.trackCleanliness && w.cleaningProgress >= Thresholds.maintenanceWarningRatio) {
        final id = '${w.id}_fouling';
        if (!deleted.contains(id)) {
          fresh.add(
            _MaintenanceAlert(
              id: id,
              itemId: w.id,
              itemName: w.name,
              type: _AlertType.fouling,
              progress: w.cleaningProgress,
              isRead: saved[id] ?? false,
            ),
          );
        }
      }
      if (w.trackWear && w.revisionProgress >= Thresholds.maintenanceWarningRatio) {
        final id = '${w.id}_wear';
        if (!deleted.contains(id)) {
          fresh.add(
            _MaintenanceAlert(
              id: id,
              itemId: w.id,
              itemName: w.name,
              type: _AlertType.wear,
              progress: w.revisionProgress,
              isRead: saved[id] ?? false,
            ),
          );
        }
      }
      // Document expiry alerts for platforms
      for (final doc in w.documents) {
        if (doc.expiryDate != null && doc.notifyBeforeDays > 0) {
          final days = doc.expiryDate!.difference(now).inDays;
          if (days <= doc.notifyBeforeDays) {
            final id = '${w.id}_doc_${doc.path.hashCode}';
            if (!deleted.contains(id)) {
              fresh.add(
                _MaintenanceAlert(
                  id: id,
                  itemId: w.id,
                  itemName: w.name,
                  type: _AlertType.document,
                  progress: 0,
                  documentName: doc.name,
                  daysRemaining: days,
                  isRead: saved[id] ?? false,
                ),
              );
            }
          }
        }
      }
    }

    // Stock alerts (ammo)
    for (final a in provider.ammos.where((a) => !a.isHidden)) {
      if (a.trackStock) {
        final threshold = a.lowStockThreshold.toDouble();
        final rawInitial = a.initialQuantity.toDouble();
        final current = a.quantity.toDouble();
        final double criticality;
        if (rawInitial <= threshold) {
          criticality = current <= threshold ? 1.0 : 0.0;
        } else {
          criticality =
              (1.0 - ((current - threshold) / (rawInitial - threshold)))
                  .clamp(0.0, 1.0)
                  .clamp(0.0, 1.0);
        }
        if (criticality >= 0.8) {
          final id = '${a.id}_stock';
          if (!deleted.contains(id)) {
            fresh.add(
              _MaintenanceAlert(
                id: id,
                itemId: a.id,
                itemName: a.name,
                type: _AlertType.stock,
                progress: criticality,
                isRead: saved[id] ?? false,
              ),
            );
          }
        }
      }
      // Document expiry alerts for ammo
      for (final doc in a.documents) {
        if (doc.expiryDate != null && doc.notifyBeforeDays > 0) {
          final days = doc.expiryDate!.difference(now).inDays;
          if (days <= doc.notifyBeforeDays) {
            final id = '${a.id}_doc_${doc.path.hashCode}';
            if (!deleted.contains(id)) {
              fresh.add(
                _MaintenanceAlert(
                  id: id,
                  itemId: a.id,
                  itemName: a.name,
                  type: _AlertType.document,
                  progress: 0,
                  documentName: doc.name,
                  daysRemaining: days,
                  isRead: saved[id] ?? false,
                ),
              );
            }
          }
        }
      }
    }

    // Wear, fouling & document expiry alerts for accessories
    for (final acc in provider.accessories.where((a) => !a.isHidden)) {
      if (acc.trackCleanliness && acc.cleaningProgress >= Thresholds.maintenanceWarningRatio) {
        final id = '${acc.id}_fouling';
        if (!deleted.contains(id)) {
          fresh.add(
            _MaintenanceAlert(
              id: id,
              itemId: acc.id,
              itemName: acc.name,
              type: _AlertType.fouling,
              progress: acc.cleaningProgress,
              isRead: saved[id] ?? false,
            ),
          );
        }
      }
      if (acc.trackWear && acc.revisionProgress >= Thresholds.maintenanceWarningRatio) {
        final id = '${acc.id}_wear';
        if (!deleted.contains(id)) {
          fresh.add(
            _MaintenanceAlert(
              id: id,
              itemId: acc.id,
              itemName: acc.name,
              type: _AlertType.wear,
              progress: acc.revisionProgress,
              isRead: saved[id] ?? false,
            ),
          );
        }
      }
      for (final doc in acc.documents) {
        if (doc.expiryDate != null && doc.notifyBeforeDays > 0) {
          final days = doc.expiryDate!.difference(now).inDays;
          if (days <= doc.notifyBeforeDays) {
            final id = '${acc.id}_doc_${doc.path.hashCode}';
            if (!deleted.contains(id)) {
              fresh.add(
                _MaintenanceAlert(
                  id: id,
                  itemId: acc.id,
                  itemName: acc.name,
                  type: _AlertType.document,
                  progress: 0,
                  documentName: doc.name,
                  daysRemaining: days,
                  isRead: saved[id] ?? false,
                ),
              );
            }
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
          if (!deleted.contains(id)) {
            fresh.add(
              _MaintenanceAlert(
                id: id,
                itemId: 'global',
                itemName: doc.name,
                type: _AlertType.document,
                progress: 0,
                documentName: doc.name,
                daysRemaining: days,
                isRead: saved[id] ?? false,
              ),
            );
          }
        }
      }
    }

    if (mounted) setState(() => _alerts = fresh);
    await _saveAlerts();
  }

  Future<void> _saveAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey,
      jsonEncode(_alerts.map((a) => a.toJson()).toList()),
    );
  }

  int get _unreadCount =>
      _alerts.where((a) => !a.isRead && !a.isDeleted).length;

  void _markRead(String id) {
    setState(() {
      for (final a in _alerts) {
        if (a.id == id) a.isRead = true;
      }
    });
    _saveAlerts();
    _overlayEntry?.markNeedsBuild();
  }

  void _markAllRead() {
    setState(() {
      for (final a in _alerts) {
        a.isRead = true;
      }
    });
    _saveAlerts();
    _overlayEntry?.markNeedsBuild();
  }

  void _deleteAlert(String id) {
    setState(() {
      for (final a in _alerts) {
        if (a.id == id) a.isDeleted = true;
      }
    });
    _saveAlerts();
    _persistDeletedIds();
    _overlayEntry?.markNeedsBuild();
  }

  void _deleteAllRead() {
    setState(() {
      for (final a in _alerts) {
        if (a.isRead) a.isDeleted = true;
      }
    });
    _saveAlerts();
    _persistDeletedIds();
    _overlayEntry?.markNeedsBuild();
  }

  Future<void> _persistDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = (prefs.getStringList(_deletedPrefKey) ?? const []).toSet();
    for (final a in _alerts) {
      if (a.isDeleted) existing.add(a.id);
    }
    await prefs.setStringList(_deletedPrefKey, existing.toList());
  }

  void _togglePanel() {
    if (_overlayEntry != null) {
      _closePanel();
    } else {
      _openPanel();
    }
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
        alerts: _alerts.where((a) => !a.isDeleted).toList(),
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
      border: isDark
          ? null
          : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
      boxShadow: AppShadows.cardPremium,
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required TextTheme textStyles,
    required ColorScheme colors,
  }) {
    return Text(
      title,
      style: textStyles.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colors.secondary,
      ),
    );
  }

  List<Widget> _buildHeaderSection({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final brightness = Theme.of(context).brightness;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/images/LOGO.svg',
            height: 34,
            colorFilter: ColorFilter.mode(
              brightness == Brightness.dark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
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

  List<Widget> _buildIndicatorsSection({
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    final hasTrackedPlatform = provider.platforms.any(
      (w) => w.trackWear || w.trackCleanliness,
    );
    final hasTrackedAmmo = provider.ammos.any((a) => a.trackStock);
    final hasTrackedAccessory = provider.accessories.any(
      (a) => a.trackWear || a.trackCleanliness,
    );
    final shouldShowMaintenanceInvite =
        !(hasTrackedPlatform || hasTrackedAmmo || hasTrackedAccessory);
    return [
      Container(
        key: _indicatorsPlaceholderKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.homeIndicatorsTitle,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(9),
            shouldShowMaintenanceInvite
                ? _buildIndicatorsPlaceholderCard(
                    colors: colors,
                    textStyles: textStyles,
                  )
                : _buildMaintenanceIndicatorsCard(
                    provider: provider,
                    colors: colors,
                    textStyles: textStyles,
                  ),
          ],
        ),
      ),
    ];
  }

  Widget _buildIndicatorsPlaceholderCard({
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: _hardCardDecoration(colors),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 42,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/material.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.homeIndicatorsPlaceholderTitle,
                  style: textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const Gap(4),
                Text(
                  strings.homeIndicatorsPlaceholderSubtitle,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPlaceholderCard({
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: _hardCardDecoration(colors),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Center(
              child: Icon(
                Icons.insert_chart_rounded,
                size: 24,
                color: colors.primary,
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.homeStatsPlaceholderTitle,
                  style: textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const Gap(4),
                Text(
                  strings.homeStatsPlaceholderSubtitle,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatsInviteSection({
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    return [
      Container(
        key: _statsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.homeStatsTitle,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(9),
            _buildStatsPlaceholderCard(colors: colors, textStyles: textStyles),
          ],
        ),
      ),
    ];
  }

  Widget _buildAchievementsButton({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    return _HomeStandardActionCard(
      leading: ShaderMask(
        shaderCallback: (bounds) {
          const base = Color(0xFFC2A14A);
          final light = Color.lerp(base, Colors.white, 0.35) ?? base;
          final dark = Color.lerp(base, Colors.black, 0.15) ?? base;
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [light, base, dark],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: const Icon(
          Icons.emoji_events_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: strings.homeTrophiesTitle,
      subtitle: strings.homeTrophiesUnlocked(
        unlockedAchievementsCount(provider),
      ),
      onTap: () => _showAchievementsModal(context),
      colors: colors,
      textStyles: textStyles,
    );
  }

  List<Widget> _buildPrecisionChartSection({
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    if (provider.sessions.isEmpty) return const [];
    return [
      SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.homePrecisionTitle,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.secondary,
              ),
            ),
            PopupMenuButton<_PrecisionRange>(
              initialValue: _precisionRange,
              tooltip: strings.homePrecisionFilterTooltip,
              onSelected: (v) => setState(() => _precisionRange = v),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _PrecisionRange.day,
                  child: Text(strings.precisionFilterDayLong),
                ),
                PopupMenuItem(
                  value: _PrecisionRange.week,
                  child: Text(strings.precisionFilterWeekLong),
                ),
                PopupMenuItem(
                  value: _PrecisionRange.month,
                  child: Text(strings.precisionFilterMonthLong),
                ),
                PopupMenuItem(
                  value: _PrecisionRange.year,
                  child: Text(strings.precisionFilterYearLong),
                ),
                PopupMenuItem(
                  value: _PrecisionRange.total,
                  child: Text(strings.precisionFilterTotalLong),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _precisionRange.labelForLocale(strings),
                    style: textStyles.labelLarge?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.secondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const Gap(9),
      Builder(
        builder: (context) {
          final now = DateTime.now();
          final sessionsWithPrecision =
              provider.sessions
                  .where((s) => s.exercises.any((e) => e.isPrecisionCounted))
                  .toList()
                ..sort((a, b) => a.date.compareTo(b.date));
          final duration = _precisionRange.duration;
          final filteredSessions = duration == null
              ? sessionsWithPrecision
              : sessionsWithPrecision
                    .where((s) => s.date.isAfter(now.subtract(duration)))
                    .toList();
          final spots = <FlSpot>[];
          for (int i = 0; i < filteredSessions.length; i++) {
            spots.add(
              FlSpot(i.toDouble(), filteredSessions[i].averagePrecision),
            );
          }
          final allPrecisions = filteredSessions
              .map((s) => s.averagePrecision)
              .toList();
          final avgPrecision = allPrecisions.isEmpty
              ? 0
              : allPrecisions.reduce((a, b) => a + b) / allPrecisions.length;
          final maxPrecision = allPrecisions.isEmpty
              ? 0
              : allPrecisions.reduce((a, b) => a > b ? a : b);

          String labelForIndex(int index) {
            if (index < 0 || index >= filteredSessions.length) return '';
            final d = filteredSessions[index].date;
            if (_precisionRange == _PrecisionRange.day)
              return AppDateFormats.formatTimeShort(context, d);
            if (_precisionRange == _PrecisionRange.total ||
                _precisionRange == _PrecisionRange.year)
              return AppDateFormats.formatMonthYear(context, d);
            return AppDateFormats.formatDayMonth(context, d);
          }

          return Container(
            height: 220,
            padding: AppSpacing.paddingLg,
            decoration: _hardCardDecoration(colors),
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      allPrecisions.isEmpty ? strings.homePrecisionEmpty : '',
                      style: textStyles.bodyMedium?.copyWith(
                        color: colors.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (s) => Colors.grey.shade700,
                                getTooltipItems: (spots) => spots
                                    .map(
                                      (spot) => LineTooltipItem(
                                        '${spot.y.toStringAsFixed(1)}%\n${labelForIndex(spot.x.toInt())}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final i = value.toInt();
                                    if (i < 0 || i >= filteredSessions.length)
                                      return const SizedBox.shrink();
                                    final count = filteredSessions.length;
                                    final step = count <= 6
                                        ? 1
                                        : (count / 5).ceil();
                                    if (i % step != 0 && i != count - 1)
                                      return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        labelForIndex(i),
                                        style: textStyles.labelSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: colors.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: colors.primary.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                            minY: 0,
                            maxY: 100,
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '${strings.homePrecisionAvgLabel} ${avgPrecision.toStringAsFixed(0)}%',
                            style: textStyles.labelSmall?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                          Text(
                            '${strings.homePrecisionMaxLabel} ${maxPrecision.toStringAsFixed(0)}%',
                            style: textStyles.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildQuickAccessSection({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    return [
      Container(
        key: _quickAccessKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.homeQuickAccessTitle,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.secondary,
              ),
            ),
            const Gap(9),
            Row(
              children: [
                for (int i = 0; i < provider.quickActions.length; i++) ...[
                  if (i > 0) const Gap(AppSpacing.sm),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final action = _getQuickAction(
                          context,
                          provider.quickActions[i],
                          provider,
                        );
                        final actionId = provider.quickActions[i];
                        final key = actionId == 'new_session'
                            ? _newSessionKey
                            : null;
                        return _QuickActionButton(
                          key: key,
                          icon: action['icon'] as Widget,
                          label: action['label'] as String,
                          onTap: action['onTap'] as VoidCallback,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildTrainingProgramSection({
    required BuildContext context,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTraining = TrainingHistory.hasAnyTraining();

    return [
      Container(
        key: _trainingKey,
        child: Container(
          key: _trainingHighlightKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.homeProgramTitle,
                      style: textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(9),
              GestureDetector(
                onTap: () {
                  // Switch to the Tools branch and ask ToolsScreen to open the
                  // "Reflexes" panel automatically. The token forces a re-trigger if
                  // the user taps the card again while already on /tools.
                  context.go(
                    '/tools?open=reflexes&t=${DateTime.now().millisecondsSinceEpoch}',
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? colors.outline.withValues(alpha: 0.3)
                          : LightColors.surfaceHighlight,
                    ),
                    boxShadow: AppShadows.cardPremium,
                    image: DecorationImage(
                      image: AssetImage(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/trainn.webp'
                            : 'assets/images/train.webp',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        Color.fromRGBO(0, 0, 0, 0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.homeProgramCardTitle,
                                    style: textStyles.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!hasTraining || true) ...[
                                    const Gap(4),
                                    Text(
                                      strings.homeProgramStartMessage,
                                      style: textStyles.bodySmall?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Row(
                          children: List.generate(7, (index) {
                            final weeklyTraining =
                                TrainingHistory.getWeeklyTraining();
                            final localeTag = Localizations.localeOf(
                              context,
                            ).toLanguageTag();
                            final dayName = DateFormat.E(localeTag).format(
                              DateTime.now().subtract(
                                Duration(days: 6 - index),
                              ),
                            );
                            final isTrained = index < weeklyTraining.length
                                ? weeklyTraining[index]
                                : false;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index < 6 ? AppSpacing.xs : 0,
                                ),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOut,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: isTrained
                                            ? const Color(0xFF5CB85C)
                                            : Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isTrained
                                              ? Colors.white.withValues(
                                                  alpha: 0.75,
                                                )
                                              : Colors.white.withValues(
                                                  alpha: 0.25,
                                                ),
                                        ),
                                        boxShadow: isTrained
                                            ? [
                                                BoxShadow(
                                                  color: LightColors.primary
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isTrained
                                              ? Icons.check_rounded
                                              : Icons.remove_rounded,
                                          size: 16,
                                          color: Colors.white.withValues(
                                            alpha: isTrained ? 1 : 0.65,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      dayName.substring(0, 2).toUpperCase(),
                                      style: textStyles.labelSmall?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildMaintenanceIndicatorsCard({
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    final hasWear =
        provider.platforms.isNotEmpty &&
        provider.platforms.any((w) => w.trackWear);
    final hasClean =
        provider.platforms.isNotEmpty &&
        provider.platforms.any((w) => w.trackCleanliness);
    final hasAmmo =
        provider.ammos.isNotEmpty && provider.ammos.any((a) => a.trackStock);
    final hasAccessoryWear =
        provider.accessories.isNotEmpty &&
        provider.accessories.any((a) => a.trackWear);
    final hasAccessoryClean =
        provider.accessories.isNotEmpty &&
        provider.accessories.any((a) => a.trackCleanliness);
    final hasMaintainedData =
        hasWear || hasClean || hasAmmo || hasAccessoryWear || hasAccessoryClean;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: _hardCardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasMaintainedData)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  strings.homeMaintenanceEmpty,
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ),
            )
          else ...[
            if (hasWear) ...[
              Builder(
                builder: (context) {
                  final mostWorn = provider.platforms
                      .where((w) => w.trackWear)
                      .reduce(
                        (a, b) =>
                            a.revisionProgress > b.revisionProgress ? a : b,
                      );
                  return _MaintenanceBar(
                    label:
                        '${strings.homeMaintenanceRevisionLabel}${mostWorn.name}',
                    value: (mostWorn.revisionProgress * 100).round(),
                    valueUnit: '%',
                    progress: mostWorn.revisionProgress.clamp(0.0, 1.0),
                    colors: colors,
                  );
                },
              ),
              if (hasClean || hasAmmo || hasAccessoryWear || hasAccessoryClean)
                const Gap(AppSpacing.md),
            ],
            if (hasClean) ...[
              Builder(
                builder: (context) {
                  final dirtiest = provider.platforms
                      .where((w) => w.trackCleanliness)
                      .reduce(
                        (a, b) =>
                            a.cleaningProgress > b.cleaningProgress ? a : b,
                      );
                  return _MaintenanceBar(
                    label:
                        '${strings.homeMaintenanceCleaningLabel}${dirtiest.name}',
                    value: (dirtiest.cleaningProgress * 100).round(),
                    valueUnit: '%',
                    progress: dirtiest.cleaningProgress.clamp(0.0, 1.0),
                    colors: colors,
                  );
                },
              ),
              if (hasAmmo || hasAccessoryWear || hasAccessoryClean)
                const Gap(AppSpacing.md),
            ],
            if (hasAmmo) ...[
              Builder(
                builder: (context) {
                  final lowestStock = provider.ammos
                      .where((a) => a.trackStock)
                      .reduce((a, b) => a.quantity < b.quantity ? a : b);
                  final threshold = lowestStock.lowStockThreshold.toDouble();
                  final rawInitial = lowestStock.initialQuantity.toDouble();
                  final current = lowestStock.quantity.toDouble();
                  final double criticality;
                  if (rawInitial <= threshold) {
                    criticality = current <= threshold ? 1.0 : 0.0;
                  } else {
                    criticality =
                        (1.0 -
                                ((current - threshold) /
                                        (rawInitial - threshold))
                                    .clamp(0.0, 1.0))
                            .clamp(0.0, 1.0);
                  }
                  return _MaintenanceBar(
                    label:
                        '${strings.homeMaintenanceStockLabel}${lowestStock.name}',
                    value: lowestStock.quantity,
                    valueUnit: strings.homeRemainingSuffix,
                    progress: criticality,
                    colors: colors,
                  );
                },
              ),
              if (hasAccessoryWear || hasAccessoryClean)
                const Gap(AppSpacing.md),
            ],
            if (hasAccessoryWear) ...[
              Builder(
                builder: (context) {
                  final mostWornAccessory = provider.accessories
                      .where((a) => a.trackWear)
                      .reduce(
                        (a, b) =>
                            a.revisionProgress > b.revisionProgress ? a : b,
                      );
                  return _MaintenanceBar(
                    label:
                        '${strings.homeMaintenanceRevisionLabel}${mostWornAccessory.name}',
                    value: (mostWornAccessory.revisionProgress * 100).round(),
                    valueUnit: '%',
                    progress: mostWornAccessory.revisionProgress.clamp(
                      0.0,
                      1.0,
                    ),
                    colors: colors,
                  );
                },
              ),
              if (hasAccessoryClean) const Gap(AppSpacing.md),
            ],
            if (hasAccessoryClean) ...[
              Builder(
                builder: (context) {
                  final dirtiestAccessory = provider.accessories
                      .where((a) => a.trackCleanliness)
                      .reduce(
                        (a, b) =>
                            a.cleaningProgress > b.cleaningProgress ? a : b,
                      );
                  return _MaintenanceBar(
                    label:
                        '${strings.homeMaintenanceCleaningLabel}${dirtiestAccessory.name}',
                    value: (dirtiestAccessory.cleaningProgress * 100).round(),
                    valueUnit: '%',
                    progress: dirtiestAccessory.cleaningProgress.clamp(
                      0.0,
                      1.0,
                    ),
                    colors: colors,
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  List<Widget> _buildLastSessionSection({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    if (provider.sessions.isEmpty) return const [];
    final strings = AppStrings.of(context);
    return [
      SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.homeLastSessionTitle,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.secondary,
              ),
            ),
            TextButton(
              onPressed: () => StatefulNavigationShell.of(context).goBranch(1),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                strings.homeSeeAll,
                style: textStyles.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      const Gap(9),
      _LastSessionCard(
        session: provider.sessions.first,
        provider: provider,
        colors: colors,
        textStyles: textStyles,
      ),
    ];
  }

  List<Widget> _buildStatsOverviewSection({
    required BuildContext context,
    required ThotProvider provider,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final strings = AppStrings.of(context);
    final avgShotsPerSession = provider.totalSessions == 0
        ? '0'
        : (provider.totalRoundsFired / provider.totalSessions).toStringAsFixed(
            0,
          );
    return [
      Container(
        key: _statsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.homeStatsTitle,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.secondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showStatisticsModal(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      strings.homeSeeAll,
                      style: textStyles.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(9),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: strings.homeStatSessions,
                    value: '${provider.totalSessions}',
                    colors: colors,
                    textStyles: textStyles,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    title: strings.homeStatShotsFired,
                    value: '${provider.totalRoundsFired}',
                    colors: colors,
                    textStyles: textStyles,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    title: strings.homeStatPlatforms,
                    value: '${provider.platforms.length}',
                    colors: colors,
                    textStyles: textStyles,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: strings.statisticsAmmosLabel,
                    value: '${provider.ammos.length}',
                    colors: colors,
                    textStyles: textStyles,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    title: strings.statisticsAccessoriesLabel,
                    value: '${provider.accessories.length}',
                    colors: colors,
                    textStyles: textStyles,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    title: strings.statisticsShotsPerSessionLabel,
                    value: avgShotsPerSession,
                    colors: colors,
                    textStyles: textStyles,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    _scheduleTutorialCheck();
    final lastSessionSection = _buildLastSessionSection(
      context: context,
      provider: provider,
      colors: colors,
      textStyles: textStyles,
    );
    final precisionSection = _buildPrecisionChartSection(
      provider: provider,
      colors: colors,
      textStyles: textStyles,
    );
    final hasStatsData =
        provider.totalSessions > 0 ||
        provider.totalRoundsFired > 0 ||
        provider.platforms.isNotEmpty ||
        provider.ammos.isNotEmpty ||
        provider.accessories.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _homeScrollController,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            defaultTargetPlatform == TargetPlatform.iOS
                ? (MediaQuery.paddingOf(context).top / 6)
                : (MediaQuery.paddingOf(context).top - 10),
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buildHeaderSection(
                context: context,
                provider: provider,
                colors: colors,
                textStyles: textStyles,
              ),
              ..._buildQuickAccessSection(
                context: context,
                provider: provider,
                colors: colors,
                textStyles: textStyles,
              ),
              const Gap(26),
              ..._buildTrainingProgramSection(
                context: context,
                colors: colors,
                textStyles: textStyles,
              ),
              const Gap(26),
              ..._buildIndicatorsSection(
                provider: provider,
                colors: colors,
                textStyles: textStyles,
              ),
              if (lastSessionSection.isNotEmpty) ...[
                const Gap(26),
                ...lastSessionSection,
              ],
              const Gap(26),
              ...(hasStatsData
                  ? _buildStatsOverviewSection(
                      context: context,
                      provider: provider,
                      colors: colors,
                      textStyles: textStyles,
                    )
                  : _buildStatsInviteSection(
                      provider: provider,
                      colors: colors,
                      textStyles: textStyles,
                    )),
              if (precisionSection.isNotEmpty) ...[
                const Gap(26),
                ...precisionSection,
              ],
              const Gap(26),
              Container(
                key: _rewardsKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(
                      title: strings.homeRewardsSectionTitle,
                      textStyles: textStyles,
                      colors: colors,
                    ),
                    const Gap(9),
                    _buildAchievementsButton(
                      context: context,
                      provider: provider,
                      colors: colors,
                      textStyles: textStyles,
                    ),
                  ],
                ),
              ),
              if (_tutorialOverlayEntry != null) const SizedBox(height: 160),
              const Gap(AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeStandardActionCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ColorScheme colors;
  final TextTheme textStyles;

  const _HomeStandardActionCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.colors,
    required this.textStyles,
  });

  BoxDecoration _hardCardDecoration(ColorScheme colors, {double radius = 16}) {
    final isDark = colors.brightness == Brightness.dark;
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: isDark
          ? null
          : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
      boxShadow: AppShadows.cardPremium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _hardCardDecoration(colors),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                SizedBox(width: 28, child: Center(child: leading)),
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
              SnackBar(
                content: Text(provider.getLimitMessage('session')),
                duration: const Duration(seconds: 3),
              ),
            );
            context.push('/pro');
            return;
          }
          context.push('/sessions/new');
        },
      };

    case 'new_platform':
      return {
        'icon': SvgPicture.asset(
          'assets/images/tube.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        'label': strings.quickActionLabelPlatform,
        'onTap': () {
          if (!provider.canAddPlatform()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.getLimitMessage('platform')),
                duration: const Duration(seconds: 3),
              ),
            );
            context.push('/pro');
            return;
          }
          context.push('/inventory/add?itemType=PLATEFORME');
        },
      };

    case 'new_ammo':
      return {
        'icon': SvgPicture.asset(
          'assets/images/pointe.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        'label': strings.quickActionLabelAmmo,
        'onTap': () {
          if (!provider.canAddAmmo()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.getLimitMessage('ammo')),
                duration: const Duration(seconds: 3),
              ),
            );
            context.push('/pro');
            return;
          }
          context.push('/inventory/add?itemType=CONSOMMABLE');
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
              SnackBar(
                content: Text(provider.getLimitMessage('accessory')),
                duration: const Duration(seconds: 3),
              ),
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

    case 'view_platforms':
      return {
        'icon': Icon(
          Icons.inventory_2_rounded,
          color: colors.primary,
          size: 24,
        ),
        'label': strings.quickActionLabelPlatform,
        'onTap': () => StatefulNavigationShell.of(context).goBranch(2),
      };

    case 'view_ammo':
      return {
        'icon': SvgPicture.asset(
          'assets/images/pointe.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        'label': strings.quickActionLabelAmmo,
        'onTap': () => StatefulNavigationShell.of(context).goBranch(2),
      };

    case 'view_accessories':
      return {
        'icon': Icon(
          Icons.inventory_2_rounded,
          color: colors.primary,
          size: 24,
        ),
        'label': strings.quickActionLabelAccessory,
        'onTap': () => StatefulNavigationShell.of(context).goBranch(2),
      };

    case 'view_sessions':
      return {
        'icon': Icon(Icons.history_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelSession,
        'onTap': () => StatefulNavigationShell.of(context).goBranch(1),
      };

    case 'settings':
      return {
        'icon': Icon(Icons.settings_rounded, color: colors.primary, size: 24),
        'label': strings.navSettingsLabel,
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
        'onTap': () => context.go(
          '/tools?open=diagnostic&t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      };

    case 'millieme':
      return {
        'icon': Icon(Icons.straighten_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelMillieme,
        'onTap': () => context.go(
          '/tools?open=millieme&t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      };

    case 'timer':
      return {
        'icon': Icon(Icons.timer_rounded, color: colors.primary, size: 24),
        'label': strings.shortcutTimer,
        'onTap': () => context.go(
          '/tools?open=timer&t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      };

    case 'shooting_tables':
      return {
        'icon': Icon(
          Icons.table_chart_outlined,
          color: colors.primary,
          size: 24,
        ),
        'label': strings.quickActionLabelShootingTables,
        'onTap': () => context.go(
          '/tools?open=shooting_tables&t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      };

    case 'visual_stimuli':
      return {
        'icon': Icon(Icons.palette_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelVisualStimuli,
        'onTap': () => context.go(
          '/tools?open=visual_stimuli&t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      };

    case 'reaction_exercises':
      return {
        'icon': Icon(Icons.bolt_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelReactionExercises,
        'onTap': () => context.go(
          '/tools?open=reflexes&t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      };

    case 'calculation_tools':
      return {
        'icon': Icon(Icons.calculate_rounded, color: colors.primary, size: 24),
        'label': strings.quickActionLabelCalculationTools,
        'onTap': () => context.go(
          '/tools?open=calculations&t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      };

    default:
      return {
        'icon': Icon(
          Icons.help_outline_rounded,
          color: colors.primary,
          size: 24,
        ),
        'label': 'Action',
        'onTap': () {},
      };
  }
}

class _QuickActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    super.key,
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
                : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
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
      return const Color(0xFF2F6F3A);
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
                '$value$valueUnit',
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
            : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
  final Session session;
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

    String platformName = '—';
    String ammoName = '—';
    if (session.exercises.isNotEmpty) {
      final firstEx = session.exercises.first;
      platformName = platformDisplayName(context, provider, firstEx);
      ammoName = ammoDisplayName(context, provider, firstEx);
    }

    final borderColor = colors.primary.withValues(alpha: 0.4);

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
                : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
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
                            '$accuracy%',
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
                  border: Border.all(color: borderColor, width: 1.2),
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
                                    'assets/images/tube.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      colors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    strings.quickActionLabelPlatform,
                                    style:
                                        (textStyles.labelSmall ??
                                                const TextStyle())
                                            .copyWith(color: colors.secondary),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                platformName,
                                style:
                                    (textStyles.bodySmall ?? const TextStyle())
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
                        Container(width: 1, height: 32, color: borderColor),
                        const Gap(AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/pointe.svg',
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
                                    style:
                                        (textStyles.labelSmall ??
                                                const TextStyle())
                                            .copyWith(color: colors.secondary),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                ammoName,
                                style:
                                    (textStyles.bodySmall ?? const TextStyle())
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
                    value: '${session.exercises.length}',
                    colors: colors,
                    textStyles: textStyles,
                  ),
                  Container(width: 1, height: 32, color: borderColor),
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
                    value: '${session.totalRounds}',
                    colors: colors,
                    textStyles: textStyles,
                  ),
                  Container(width: 1, height: 32, color: borderColor),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const Gap(4),
        Text(
          label,
          style: (textStyles.labelSmall ?? const TextStyle()).copyWith(
            color: colors.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: (textStyles.bodySmall ?? const TextStyle()).copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProCornerButton extends StatelessWidget {
  // ignore: unused_field — reserved for future freemium badge toggle
  final bool isPremium;
  final bool isOnline;
  final int unreadCount;
  // ignore: unused_field — reserved for future Pro badge tap handler
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
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
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: colors.onSurface, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 13,
                  color: isDark ? Colors.white : colors.onSurface,
                ),
                const Gap(5),
                Text(
                  strings.offlineBadgeLabel,
                  style: textStyles.labelSmall?.copyWith(
                    color: isDark ? Colors.white : colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
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
    // Kaki clair pour le divider — même teinte que les séparateurs de la dernière session
    final dividerColor = const Color(0xFFC2A14A).withValues(alpha: 0.25);

    return Stack(
      children: [
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
                            color: LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.45 : 0.14,
                        ),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                strings.notifPanelTitle,
                                style: textStyles.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (!allRead)
                              TextButton(
                                onPressed: widget.onMarkAllRead,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  strings.notifMarkAllRead,
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (allRead && hasRead)
                              TextButton(
                                onPressed: widget.onDeleteAllRead,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  strings.notifDeleteAll,
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: dividerColor),

                      // List
                      if (widget.alerts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: colors.primary,
                                size: 40,
                              ),
                              const Gap(8),
                              Text(
                                strings.notifPanelEmpty,
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
                                onNavigate: () =>
                                    widget.onNavigate(alert.itemId),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
        final days = alert.daysRemaining ?? 0;
        if (days < 0) {
          subtitle = strings.notifDocumentExpired;
          barColor = const Color(0xFFD64545);
        } else if (days == 0) {
          subtitle = strings.notifDocumentExpiredToday;
          barColor = const Color(0xFFD64545);
        } else {
          subtitle = strings.notifDocumentExpiresDays(days);
          barColor = days <= 7
              ? const Color(0xFFD64545)
              : const Color(0xFFC2A14A);
        }
        break;
    }

    return Opacity(
      opacity: alert.isRead ? 0.55 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                  child: GestureDetector(
                    onTap: () {
                      if (!alert.isRead) onMarkRead();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.type == _AlertType.document
                              ? alert.documentName ?? alert.itemName
                              : alert.itemName,
                          style: textStyles.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          alert.type == _AlertType.document
                              ? subtitle
                              : '$typeLabel — $subtitle',
                          style: textStyles.labelSmall?.copyWith(
                            color: barColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
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
    );
  }
}

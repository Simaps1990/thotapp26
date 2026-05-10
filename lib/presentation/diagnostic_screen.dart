import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:go_router/go_router.dart';
import '../data/thot_provider.dart';
import '../data/models.dart';
import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/l10n/app_strings_diagnostic.dart';

const String kYes = 'yes';
const String kNo = 'no';
const String kUnknown = 'unknown';

const String kIncidentNoFire = 'incident_no_fire';
const String kIncidentDelayedFire = 'incident_delayed_fire';
const String kIncidentCycle = 'incident_cycle';
const String kIncidentAccuracy = 'incident_accuracy';
const String kIncidentAbnormalDeparture = 'incident_abnormal_departure';

class _DiagnosticResult {
  final String incidentKey;
  final String suspectedIssueKey;
  final String riskLevelKey;
  final Map<String, int> probabilities;
  final String finalDecision;
  final String summary;

  const _DiagnosticResult({
    required this.incidentKey,
    required this.suspectedIssueKey,
    required this.riskLevelKey,
    required this.probabilities,
    required this.finalDecision,
    required this.summary,
  });
}

class DiagnosticScreen extends StatefulWidget {
  final bool embedded;

  const DiagnosticScreen({Key? key, this.embedded = false}) : super(key: key);

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  bool _showNewDiagnostic = false;

  void _startNewDiagnostic() {
    setState(() {
      _showNewDiagnostic = true;
    });
  }

  void _closeDiagnostic() {
    setState(() {
      _showNewDiagnostic = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    final content = Column(
      children: [
        if (!widget.embedded) ...[
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
        ],

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        AppStringsDiagnostic.diagnosticToolTitle,
                        style: textStyles.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const Gap(6),
                    Tooltip(
                      message: AppStringsDiagnostic.diagnosticToolSubtitle,
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 4),
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: textStyles.bodySmall?.copyWith(color: colors.surface),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: colors.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.xs),
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 28,
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Divider(color: colors.outline),
        ),

        // Content
        Expanded(
          child: _showNewDiagnostic
              ? DiagnosticTreeView(onComplete: _closeDiagnostic)
              : DiagnosticHistoryView(onStartNew: _startNewDiagnostic),
        ),
      ],
    );

    if (widget.embedded) {
      return Container(
        color: baseBackground,
        child: content,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }
}

class DiagnosticHistoryView extends StatelessWidget {
  final VoidCallback onStartNew;

  const DiagnosticHistoryView({Key? key, required this.onStartNew})
      : super(key: key);

  void _showDiagnosticDetails(BuildContext context, Diagnostic diagnostic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            top: 12,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.95,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
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
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: DiagnosticResultSheet(diagnostic: diagnostic),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // New diagnostic button
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppStringsDiagnostic.diagnosticDisclaimerTitle),
                    content:
                        Text(AppStringsDiagnostic.diagnosticDisclaimerBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(strings.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(
                            AppStringsDiagnostic.diagnosticDisclaimerConfirm),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  onStartNew();
                }
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text(AppStringsDiagnostic.diagnosticNew),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),

        // History list
        Expanded(
          child: provider.diagnostics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services_outlined,
                          size: 64, color: colors.secondary),
                      const Gap(AppSpacing.md),
                      Text(
                        AppStringsDiagnostic.diagnosticEmptyTitle,
                        style: textStyles.bodyLarge
                            ?.copyWith(color: colors.secondary),
                      ),
                      const Gap(AppSpacing.xs),
                      Text(
                        AppStringsDiagnostic.diagnosticEmptySubtitle,
                        style: textStyles.bodySmall
                            ?.copyWith(color: colors.secondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
                  itemCount: provider.diagnostics.length,
                  separatorBuilder: (_, __) => const Gap(AppSpacing.md),
                  itemBuilder: (context, index) {
                    final diagnostic = provider.diagnostics[index];
                    final platform =
                        provider.getPlatformById(diagnostic.platformId);
                    final platformName = diagnostic
                            .platformNameSnapshot.isNotEmpty
                        ? diagnostic.platformNameSnapshot
                        : (diagnostic.platformId == 'none'
                            ? AppStringsDiagnostic.diagnosticOfUnknownPlatform
                            : (platform?.name ??
                                AppStringsDiagnostic
                                    .diagnosticOfUnknownPlatform));
                    final platformType =
                        diagnostic.platformTypeSnapshot.isNotEmpty
                            ? diagnostic.platformTypeSnapshot
                            : (platform?.type ?? '-');
                    return Dismissible(
                      key: Key(diagnostic.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                                AppStringsDiagnostic.diagnosticDeleteTitle),
                            content: Text(
                                AppStringsDiagnostic.diagnosticDeleteMessage),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(strings.actionCancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                    foregroundColor: colors.error),
                                child: Text(strings.delete),
                              ),
                            ],
                          ),
                        );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.delete_rounded),
                      ),
                      onDismissed: (_) =>
                          provider.deleteDiagnostic(diagnostic.id),
                      child: GestureDetector(
                        onTap: () => _showDiagnosticDetails(context, diagnostic),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? colors.outline : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                            boxShadow: AppShadows.cardPremium,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppStringsDiagnostic.diagnosticOfPlatform(
                                          platformName),
                                      style: textStyles.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(8, 0),
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(AppStringsDiagnostic
                                                .diagnosticDeleteTitle),
                                            content: Text(AppStringsDiagnostic
                                                .diagnosticDeleteMessage),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text(strings.actionCancel),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  provider.deleteDiagnostic(
                                                      diagnostic.id);
                                                  Navigator.of(context).pop();
                                                },
                                                style: TextButton.styleFrom(
                                                    foregroundColor: colors.error),
                                                child: Text(strings.delete),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.delete_rounded),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(2),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: colors.secondary),
                                  const Gap(AppSpacing.xs),
                                  Text(
                                    '$platformType • ${AppDateFormats.formatDateTimeShort(context, diagnostic.date)}',
                                    style: textStyles.labelSmall
                                        ?.copyWith(color: colors.secondary),
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.sm),
                              SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    const Gap(AppSpacing.xs),
                                    Divider(height: 1, color: const Color(0xFFC2A14A).withValues(alpha: 0.25)),
                                    const Gap(AppSpacing.md),
                                    Text(
                                      AppStringsDiagnostic.diagnosticSuspectedIssueTitle,
                                      style: textStyles.labelSmall?.copyWith(
                                        color: colors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Gap(AppSpacing.xs),
                                    Text(
                                      diagnostic.finalDecision,
                                      style: textStyles.bodyMedium?.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Gap(AppSpacing.md),
                                    Divider(height: 1, color: const Color(0xFFC2A14A).withValues(alpha: 0.25)),
                                    const Gap(AppSpacing.md),
                                    Text(
                                      strings.summaryLabel,
                                      style: textStyles.labelSmall?.copyWith(
                                        color: colors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Gap(AppSpacing.xs),
                                    Text(
                                      diagnostic.summary,
                                      style: textStyles.bodySmall
                                          ?.copyWith(color: colors.onSurface),
                                    ),
                                  ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class DiagnosticTreeView extends StatefulWidget {
  final VoidCallback onComplete;

  const DiagnosticTreeView({Key? key, required this.onComplete})
      : super(key: key);

  @override
  State<DiagnosticTreeView> createState() => _DiagnosticTreeViewState();
}

class _DiagnosticTreeViewState extends State<DiagnosticTreeView> {
  final Map<String, dynamic> _responses = {};
  int _currentStep = 0;
  final List<int> _history = [];

  String? _selectedPlatformId;

  void _answer(String questionKey, dynamic answer) {
    setState(() {
      _responses[questionKey] = answer;
      _history.add(_currentStep);
      _currentStep = _getNextStep();
    });
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _currentStep = _history.removeLast();
        // Remove the last response
        final lastKey = _getQuestionKey(_currentStep);
        _responses.remove(lastKey);
      });
    }
  }

  int _getNextStep() {
    if (_currentStep == 0) return 1; // platform selection -> safety
    if (_currentStep == 1) {
      if (_responses['q1'] == kNo) return 99;
      return 2;
    }
    if (_currentStep == 2) {
      if (_responses['q2'] == kNo) return 99;
      return 3;
    }
    if (_currentStep == 3) {
      if (_responses['q3'] == kUnknown) return 99;
      return 4; // choose incident
    }

    // Incident selection
    if (_currentStep == 4) {
      final incident = _responses['q4'];
      if (incident == kIncidentNoFire) return 5;
      if (incident == kIncidentDelayedFire) return 9;
      if (incident == kIncidentCycle) return 12;
      if (incident == kIncidentAccuracy) return 16;
      if (incident == kIncidentAbnormalDeparture) return 21;
      return 100;
    }

    // incident_no_fire
    if (_currentStep == 5) return 6;
    if (_currentStep == 6) return 7;
    if (_currentStep == 7) return 8;
    if (_currentStep == 8) return 100;

    // incident_delayed_fire
    if (_currentStep == 9) return 10;
    if (_currentStep == 10) return 11;
    if (_currentStep == 11) return 100;

    // incident_cycle
    if (_currentStep == 12) return 13;
    if (_currentStep == 13) return 14;
    if (_currentStep == 14) return 15;
    if (_currentStep == 15) return 100;

    // incident_accuracy
    if (_currentStep == 16) return 17;
    if (_currentStep == 17) return 18;
    if (_currentStep == 18) return 19;
    if (_currentStep == 19) return 20;
    if (_currentStep == 20) return 100;

    // incident_abnormal_departure
    if (_currentStep == 21) return 100;

    return 100;
  }

  String _getQuestionKey(int step) {
    if (step == 0) return 'platform_id';
    return 'q$step';
  }

  void _completeDiagnostic() {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final platform =
        (_selectedPlatformId != null && _selectedPlatformId != 'none')
            ? provider.getPlatformById(_selectedPlatformId!)
            : null;
    final result = _evaluateResult(platform);

    final diagnostic = Diagnostic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      platformId: _selectedPlatformId ?? 'none',
      platformNameSnapshot: platform?.name ?? '',
      platformTypeSnapshot: platform?.type ?? '',
      responses: Map.from(_responses),
      incidentKey: result.incidentKey,
      suspectedIssueKey: result.suspectedIssueKey,
      riskLevelKey: result.riskLevelKey,
      probabilities: result.probabilities,
      finalDecision: result.finalDecision,
      summary: result.summary,
    );

    provider.addDiagnostic(diagnostic);
    widget.onComplete();
  }

  String _generateSummary({
    required String platformName,
    required String platformType,
    required String platformCaliber,
    required String incidentLabel,
    required String finalDecision,
    required String riskLabel,
  }) {
    final strings = AppStrings.of(context);
    final parts = <String>[];
    parts.add(strings.diagnosticOf(platformName));
    if (platformType.isNotEmpty) parts.add(platformType);
    if (platformCaliber.isNotEmpty) parts.add(platformCaliber);
    parts.add('${strings.incidentLabel} $incidentLabel');
    parts.add('${strings.presumedProblemLabel} $finalDecision');
    parts.add('${strings.riskLabel} $riskLabel');

    return parts.join(' • ');
  }

  Map<String, int> _normalizeProbabilities(Map<String, int> probabilities) {
    if (probabilities.isEmpty) return probabilities;
    final total = probabilities.values.reduce((a, b) => a + b);
    if (total == 0) return probabilities;
    return probabilities.map((key, value) => MapEntry(key, ((value / total) * 100).round()));
  }

  _DiagnosticResult _evaluateResult(Platform? platform) {
    final strings = AppStrings.of(context);
    final incidentKey = (_responses['q4'] as String?) ?? 'incident_unknown';
    String suspectedIssueKey = 'multiple_possible';
    String riskLevelKey = 'medium';
    Map<String, int> probabilities = const {};

    if (incidentKey == kIncidentNoFire) {
      if (_responses['q5'] == kNo && _responses['q7'] == kYes) {
        suspectedIssueKey = 'component_damage';
        riskLevelKey = 'high';
        probabilities = {
          'component_damage': 80,
          'configuration_issue': 55,
          'fouling_dirty': 35,
          'ammo_defective': 15,
        };
      } else if (_responses['q5'] == kYes && _responses['q6'] == kNo) {
        suspectedIssueKey = 'ammo_defective';
        riskLevelKey = 'medium';
        probabilities = {
          'ammo_defective': 80,
          'fouling_dirty': 25,
          'configuration_issue': 20,
          'component_damage': 15,
        };
      } else if (_responses['q5'] == kYes &&
          _responses['q6'] == kYes &&
          _responses['q8'] == kNo) {
        suspectedIssueKey = 'fouling_dirty';
        riskLevelKey = 'medium';
        probabilities = {
          'fouling_dirty': 75,
          'configuration_issue': 45,
          'component_damage': 30,
          'ammo_defective': 20,
        };
      } else {
        suspectedIssueKey = 'multiple_possible';
        riskLevelKey = 'medium';
        probabilities = {
          'ammo_defective': 40,
          'fouling_dirty': 40,
          'configuration_issue': 35,
          'component_damage': 35,
        };
      }
    } else if (incidentKey == kIncidentDelayedFire) {
      if (_responses['q9'] == kYes &&
          _responses['q10'] == kYes &&
          _responses['q11'] == kNo) {
        suspectedIssueKey = 'ammo_defective';
        riskLevelKey = 'high';
        probabilities = {
          'ammo_defective': 85,
          'component_damage': 20,
          'fouling_dirty': 15,
          'configuration_issue': 10,
        };
      } else if (_responses['q9'] == kYes && _responses['q11'] == kYes) {
        suspectedIssueKey = 'component_damage';
        riskLevelKey = 'high';
        probabilities = {
          'component_damage': 65,
          'ammo_defective': 55,
          'fouling_dirty': 25,
          'configuration_issue': 20,
        };
      } else {
        suspectedIssueKey = 'multiple_possible';
        riskLevelKey = 'high';
        probabilities = {
          'ammo_defective': 50,
          'component_damage': 50,
          'fouling_dirty': 20,
          'configuration_issue': 20,
        };
      }
    } else if (incidentKey == kIncidentCycle) {
      if (_responses['q13'] == kYes && _responses['q14'] == kNo) {
        suspectedIssueKey = 'ammo_defective';
        riskLevelKey = 'medium';
        probabilities = {
          'ammo_defective': 75,
          'configuration_issue': 35,
          'fouling_dirty': 30,
          'component_damage': 20,
        };
      } else if (_responses['q14'] == kYes) {
        suspectedIssueKey = 'configuration_issue';
        riskLevelKey = 'medium';
        probabilities = {
          'configuration_issue': 80,
          'ammo_defective': 35,
          'fouling_dirty': 25,
          'component_damage': 20,
        };
      } else if (_responses['q15'] == kYes) {
        suspectedIssueKey = 'fouling_dirty';
        riskLevelKey = 'medium';
        probabilities = {
          'fouling_dirty': 80,
          'configuration_issue': 35,
          'component_damage': 30,
          'ammo_defective': 20,
        };
      } else if (_responses['q12'] == kYes &&
          _responses['q13'] == kNo &&
          _responses['q14'] == kNo &&
          _responses['q15'] == kNo) {
        suspectedIssueKey = 'component_damage';
        riskLevelKey = 'high';
        probabilities = {
          'component_damage': 70,
          'configuration_issue': 35,
          'fouling_dirty': 20,
          'ammo_defective': 20,
        };
      } else {
        suspectedIssueKey = 'multiple_possible';
        riskLevelKey = 'medium';
        probabilities = {
          'configuration_issue': 45,
          'fouling_dirty': 45,
          'ammo_defective': 35,
          'component_damage': 30,
        };
      }
    } else if (incidentKey == kIncidentAccuracy) {
      if (_responses['q18'] == kYes) {
        suspectedIssueKey = 'optic_or_mount';
        riskLevelKey = 'medium';
        probabilities = {
          'optic_or_mount': 85,
          'configuration_issue': 30,
          'fouling_dirty': 15,
          'ammo_defective': 10,
        };
      } else if (_responses['q17'] == kYes && _responses['q18'] == kNo) {
        suspectedIssueKey = 'configuration_issue';
        riskLevelKey = 'medium';
        probabilities = {
          'configuration_issue': 75,
          'ammo_defective': 55,
          'optic_or_mount': 35,
          'fouling_dirty': 20,
        };
      } else if (_responses['q19'] == kYes) {
        suspectedIssueKey = 'fouling_dirty';
        riskLevelKey = 'medium';
        probabilities = {
          'fouling_dirty': 75,
          'ammo_defective': 30,
          'configuration_issue': 25,
          'optic_or_mount': 20,
        };
      } else if (_responses['q20'] == kYes) {
        suspectedIssueKey = 'human_factor';
        riskLevelKey = 'low';
        probabilities = {
          'human_factor': 80,
          'ammo_defective': 20,
          'optic_or_mount': 15,
          'fouling_dirty': 15,
        };
      } else {
        suspectedIssueKey = 'multiple_possible';
        riskLevelKey = 'medium';
        probabilities = {
          'ammo_defective': 35,
          'fouling_dirty': 35,
          'optic_or_mount': 35,
          'configuration_issue': 35,
          'human_factor': 30,
        };
      }
    } else if (incidentKey == kIncidentAbnormalDeparture) {
      suspectedIssueKey = 'component_damage';
      riskLevelKey = 'high';
      probabilities = (_responses['q21'] == 'confirmed')
          ? {
              'component_damage': 70,
              'configuration_issue': 20,
              'human_factor': 10,
            }
          : {
              'component_damage': 50,
              'human_factor': 30,
              'configuration_issue': 20,
            };
    }

    probabilities = _normalizeProbabilities(probabilities);

    final finalDecision = AppStringsDiagnostic.issueLabel(suspectedIssueKey);
    final riskLabel = DiagnosticResultUIHelper.riskLabel(riskLevelKey);
    final incidentLabel = DiagnosticResultUIHelper.incidentLabel(incidentKey);
    final summary = _generateSummary(
      platformName: platform?.name ?? strings.platformNotSpecified,
      platformType: platform?.type ?? '',
      platformCaliber: platform?.caliber ?? '',
      incidentLabel: incidentLabel,
      finalDecision: finalDecision,
      riskLabel: riskLabel,
    );

    return _DiagnosticResult(
      incidentKey: incidentKey,
      suspectedIssueKey: suspectedIssueKey,
      riskLevelKey: riskLevelKey,
      probabilities: probabilities,
      finalDecision: finalDecision,
      summary: summary,
    );
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    if (_currentStep == 99) {
      // STOP screens
      return _buildStopScreen();
    }

    if (_currentStep == 100) {
      // Final decision
      return _buildFinalScreen();
    }

    return Column(
      children: [
        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _buildQuestion(),
          ),
        ),

        // Navigation buttons
        if (_history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextButton.icon(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back),
              label: Text(strings.previous),
              style: TextButton.styleFrom(foregroundColor: colors.secondary),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestion() {
    switch (_currentStep) {
      case 0:
        return _buildPlatformSelection();
      case 1:
        return _buildQ1();
      case 2:
        return _buildQ2();
      case 3:
        return _buildQ3();
      case 4:
        return _buildQ4();
      case 5:
        return _buildQ5();
      case 6:
        return _buildQ6();
      case 7:
        return _buildQ7();
      case 8:
        return _buildQ8();
      case 9:
        return _buildQ9();
      case 10:
        return _buildQ10();
      case 11:
        return _buildQ11();
      case 12:
        return _buildQ12();
      case 13:
        return _buildQ13();
      case 14:
        return _buildQ14();
      case 15:
        return _buildQ15();
      case 16:
        return _buildQ16();
      case 17:
        return _buildQ17();
      case 18:
        return _buildQ18();
      case 19:
        return _buildQ19();
      case 20:
        return _buildQ20();
      case 21:
        return _buildQ21();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPlatformSelection() {
    final provider = Provider.of<ThotProvider>(context);

    return _QuestionCard(
      title: AppStringsDiagnostic.diagnosticPlatformSelectionTitle,
      child: Column(
        children: [
          _OptionButton(
            text: AppStringsDiagnostic.diagnosticNoSpecificPlatform,
            subtitle: AppStringsDiagnostic.diagnosticNoSpecificPlatformSubtitle,
            onTap: () {
              _selectedPlatformId = null;
              _answer('platform_id', 'none');
            },
          ),
          if (provider.platforms.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Text(
              AppStringsDiagnostic.diagnosticOrSelectPlatform,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(AppSpacing.md),
            ...provider.platforms.map((platform) {
              return _OptionButton(
                text: platform.name,
                subtitle:
                    '${platform.type} • ${platform.caliber} • ${platform.model}',
                onTap: () {
                  _selectedPlatformId = platform.id;
                  _answer('platform_id', platform.id);
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildQ1() => _QuestionCard(
        title: AppStrings.of(context).diagnosticQuestion1,
        subtitle: AppStrings.of(context).diagnosticSafetyPhase,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q1', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                isWarning: true,
                onTap: () => _answer('q1', kNo)),
          ],
        ),
      );

  Widget _buildQ2() => _QuestionCard(
        title: AppStrings.of(context).diagnosticQuestion2,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q2', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                isWarning: true,
                onTap: () => _answer('q2', kNo)),
          ],
        ),
      );

  Widget _buildQ3() => _QuestionCard(
        title: AppStrings.of(context).diagnosticQuestion3,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).diagnosticPlatformPossiblyLoaded,
                onTap: () => _answer('q3', 'loaded')),
            _OptionButton(
                text: AppStrings.of(context).diagnosticPlatformOpenedSafe,
                onTap: () => _answer('q3', 'safe_open')),
            _OptionButton(
                text: AppStrings.of(context).diagnosticUnknownState,
                isWarning: true,
                onTap: () => _answer('q3', kUnknown)),
          ],
        ),
      );

  Widget _buildQ4() => _QuestionCard(
        title: AppStringsDiagnostic.questionIncidentTitle,
        subtitle: AppStrings.of(context).diagnosticClassification,
        child: Column(
          children: [
            _OptionButton(
                text: AppStringsDiagnostic.incidentNoFireLabel,
                onTap: () => _answer('q4', kIncidentNoFire)),
            _OptionButton(
                text: AppStringsDiagnostic.incidentDelayedFireLabel,
                onTap: () => _answer('q4', kIncidentDelayedFire)),
            _OptionButton(
                text: AppStringsDiagnostic.incidentCycleLabel,
                onTap: () => _answer('q4', kIncidentCycle)),
            _OptionButton(
                text: AppStringsDiagnostic.incidentAccuracyLabel,
                onTap: () => _answer('q4', kIncidentAccuracy)),
            _OptionButton(
                text: AppStringsDiagnostic.incidentAbnormalDepartureLabel,
                isWarning: true,
                onTap: () => _answer('q4', kIncidentAbnormalDeparture)),
          ],
        ),
      );

  Widget _buildQ5() => _QuestionCard(
        title: AppStringsDiagnostic.q5MarkOnPrimer,
        subtitle: AppStringsDiagnostic.incidentNoFireLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q5', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q5', kNo)),
          ],
        ),
      );

  Widget _buildQ6() => _QuestionCard(
        title: AppStringsDiagnostic.q6RepeatsOtherAmmo,
        subtitle: AppStringsDiagnostic.incidentNoFireLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q6', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q6', kNo)),
          ],
        ),
      );

  Widget _buildQ7() => _QuestionCard(
        title: AppStringsDiagnostic.q7CycleAbnormal,
        subtitle: AppStringsDiagnostic.incidentNoFireLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q7', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q7', kNo)),
          ],
        ),
      );

  Widget _buildQ8() => _QuestionCard(
        title: AppStringsDiagnostic.q8RecentCleaning,
        subtitle: AppStringsDiagnostic.incidentNoFireLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q8', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q8', kNo)),
          ],
        ),
      );

  Widget _buildQ9() => _QuestionCard(
        title: AppStringsDiagnostic.q9RealDelay,
        subtitle: AppStringsDiagnostic.incidentDelayedFireLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q9', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q9', kNo)),
          ],
        ),
      );

  Widget _buildQ10() => _QuestionCard(
        title: AppStringsDiagnostic.q10SingleRound,
        subtitle: AppStringsDiagnostic.incidentDelayedFireLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q10', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q10', kNo)),
          ],
        ),
      );

  Widget _buildQ11() => _QuestionCard(
        title: AppStringsDiagnostic.q11AlreadySeen,
        subtitle: AppStringsDiagnostic.incidentDelayedFireLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q11', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q11', kNo)),
          ],
        ),
      );

  Widget _buildQ12() => _QuestionCard(
        title: AppStringsDiagnostic.q12RepeatedCycleIssue,
        subtitle: AppStringsDiagnostic.incidentCycleLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q12', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q12', kNo)),
          ],
        ),
      );

  Widget _buildQ13() => _QuestionCard(
        title: AppStringsDiagnostic.q13ChangesWithOtherAmmo,
        subtitle: AppStringsDiagnostic.incidentCycleLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q13', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q13', kNo)),
          ],
        ),
      );

  Widget _buildQ14() => _QuestionCard(
        title: AppStringsDiagnostic.q14ChangesWithOtherMag,
        subtitle: AppStringsDiagnostic.incidentCycleLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q14', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q14', kNo)),
          ],
        ),
      );

  Widget _buildQ15() => _QuestionCard(
        title: AppStringsDiagnostic.q15DirtyOrDry,
        subtitle: AppStringsDiagnostic.incidentCycleLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q15', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q15', kNo)),
          ],
        ),
      );

  Widget _buildQ16() => _QuestionCard(
        title: AppStringsDiagnostic.q16SuddenAccuracyDrop,
        subtitle: AppStringsDiagnostic.incidentAccuracyLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q16', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q16', kNo)),
          ],
        ),
      );

  Widget _buildQ17() => _QuestionCard(
        title: AppStringsDiagnostic.q17RecentChange,
        subtitle: AppStringsDiagnostic.incidentAccuracyLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q17', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q17', kNo)),
          ],
        ),
      );

  Widget _buildQ18() => _QuestionCard(
        title: AppStringsDiagnostic.q18VisibleMovement,
        subtitle: AppStringsDiagnostic.incidentAccuracyLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q18', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q18', kNo)),
          ],
        ),
      );

  Widget _buildQ19() => _QuestionCard(
        title: AppStringsDiagnostic.q19HighRoundsSinceCleaning,
        subtitle: AppStringsDiagnostic.incidentAccuracyLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q19', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q19', kNo)),
          ],
        ),
      );

  Widget _buildQ20() => _QuestionCard(
        title: AppStringsDiagnostic.q20DependsOnSupport,
        subtitle: AppStringsDiagnostic.incidentAccuracyLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStrings.of(context).yesUpper,
                onTap: () => _answer('q20', kYes)),
            _OptionButton(
                text: AppStrings.of(context).noUpper,
                onTap: () => _answer('q20', kNo)),
          ],
        ),
      );

  Widget _buildQ21() => _QuestionCard(
        title: AppStringsDiagnostic.q21ConfirmedOrSuspected,
        subtitle: AppStringsDiagnostic.incidentAbnormalDepartureLabel,
        child: Column(
          children: [
            _OptionButton(
                text: AppStringsDiagnostic.answerConfirmed,
                isWarning: true,
                onTap: () => _answer('q21', 'confirmed')),
            _OptionButton(
                text: AppStringsDiagnostic.answerSuspected,
                onTap: () => _answer('q21', 'suspected')),
          ],
        ),
      );

  Widget _buildStopScreen() {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    String message = '';
    if (_responses['q1'] == kNo || _responses['q2'] == kNo) {
      message = AppStringsDiagnostic.diagnosticImmediateStopMessage;
    } else if (_responses['q3'] == kUnknown) {
      message = AppStringsDiagnostic.diagnosticUnknownStateMessage;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: colors.error),
            const Gap(AppSpacing.lg),
            Text(
              message,
              style: textStyles.titleMedium?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                child: Text(strings.closeUpper),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _buildDiagnosticResultContent(null),
      ),
    );
  }

  Widget _buildDiagnosticResultContent(Diagnostic? savedDiag) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);

    final String platformName;
    final String platformType;
    final DateTime date;
    
    final Map<String, int> probabilities;
    final String suspectedIssueKey;
    final String riskLevelKey;
    final String incidentKey;
    final String finalDecision;
    final String summaryText;

    if (savedDiag != null) {
      final platform = provider.getPlatformById(savedDiag.platformId);
      platformName = platform?.name ?? (savedDiag.platformNameSnapshot.isNotEmpty 
          ? savedDiag.platformNameSnapshot 
          : strings.platformNotSpecified);
      platformType = platform?.type ?? savedDiag.platformTypeSnapshot;
      date = savedDiag.date;
      
      probabilities = savedDiag.probabilities;
      suspectedIssueKey = savedDiag.suspectedIssueKey;
      riskLevelKey = savedDiag.riskLevelKey;
      incidentKey = savedDiag.incidentKey;
      finalDecision = savedDiag.finalDecision;
      summaryText = savedDiag.summary;
    } else {
      final platform = (_selectedPlatformId != null && _selectedPlatformId != 'none')
          ? provider.getPlatformById(_selectedPlatformId!)
          : null;
      platformName = platform?.name ?? 'plateforme non spécifiée';
      platformType = platform?.type ?? '-';
      date = DateTime.now();
      
      final result = _evaluateResult(platform);
      probabilities = result.probabilities;
      suspectedIssueKey = result.suspectedIssueKey;
      riskLevelKey = result.riskLevelKey;
      incidentKey = result.incidentKey;
      finalDecision = result.finalDecision;
      summaryText = _generateSummary(
        platformName: platformName,
        platformType: platformType,
        platformCaliber: platform?.caliber ?? '',
        incidentLabel: DiagnosticResultUIHelper.incidentLabel(incidentKey),
        finalDecision: finalDecision,
        riskLabel: DiagnosticResultUIHelper.riskLabel(riskLevelKey),
      );
    }

    final sortedProbabilities = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final iconColor = DiagnosticResultUIHelper.issueColor(suspectedIssueKey, colors);
    final riskLabel = DiagnosticResultUIHelper.riskLabel(riskLevelKey);
    final incidentLabel = DiagnosticResultUIHelper.incidentLabel(incidentKey);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.checklist_rounded, size: 80, color: iconColor),
        const Gap(AppSpacing.lg),
        Text(
          AppStringsDiagnostic.diagnosticOfPlatform(platformName),
          style: textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(AppSpacing.xs),
        Text(
          '$platformType • ${AppDateFormats.formatDateTimeShort(context, date)}',
          style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          textAlign: TextAlign.center,
        ),
        const Gap(AppSpacing.md),
        
        // 1. CARTE PRINCIPALE : Incident et Cause
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStringsDiagnostic.diagnosticIdentifiedIncidentTitle.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.xs),
              Text(
                incidentLabel,
                style: textStyles.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
              Text(
                AppStringsDiagnostic.diagnosticSuspectedIssueTitle.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.build_circle_rounded, color: iconColor, size: 24),
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      finalDecision,
                      style: textStyles.titleLarge?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              if (suspectedIssueKey == 'component_damage') ...[
                const Gap(AppSpacing.sm),
                Text(
                  AppStringsDiagnostic.issueComponentDamageHint,
                  style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
                ),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 2. NIVEAU DE RISQUE ET PROBABILITÉS
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStringsDiagnostic.diagnosticRiskLevelTitle.toUpperCase(),
                    style: textStyles.labelSmall?.copyWith(
                      color: colors.secondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskLevelKey == 'high' 
                          ? colors.error.withValues(alpha: 0.1) 
                          : riskLevelKey == 'medium'
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: riskLevelKey == 'high' 
                            ? colors.error 
                            : riskLevelKey == 'medium'
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    child: Text(
                      riskLabel,
                      style: textStyles.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: riskLevelKey == 'high' 
                            ? colors.error 
                            : riskLevelKey == 'medium'
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
              Text(
                AppStringsDiagnostic.diagnosticProbabilitiesTitle.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.sm),
              ...sortedProbabilities.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DiagnosticResultUIHelper.buildProbabilityRow(
                      issueKey: entry.key,
                      value: entry.value,
                      colors: colors,
                      textStyles: textStyles,
                    ),
                  )),
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 3. RECOMMANDATIONS
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: colors.primary, size: 24),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStringsDiagnostic.diagnosticImmediateActionsTitle.toUpperCase(),
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      AppStringsDiagnostic.diagnosticRecommendedActions(riskLevelKey),
                      style: textStyles.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 4. À ÉVITER
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.do_not_disturb_alt_rounded, color: colors.error, size: 24),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStringsDiagnostic.diagnosticAvoidTitle.toUpperCase(),
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.error,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      AppStringsDiagnostic.diagnosticAvoidActions(),
                      style: textStyles.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 5. RÉSUMÉ
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.summaryLabel.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.sm),
              Text(
                summaryText,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.xl),
        
        if (savedDiag == null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeDiagnostic,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 2,
              ),
              child: Text(
                strings.saveDiagnosticUpper,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                foregroundColor: colors.secondary,
              ),
              child: Text(
                strings.closeUpper,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _QuestionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: textStyles.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(AppSpacing.sm),
        ],
        Text(
          title,
          style: textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const Gap(AppSpacing.lg),
        child,
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final String? subtitle;
  final bool isWarning;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    this.subtitle,
    this.isWarning = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: isWarning
                ? colors.error.withValues(alpha: 0.1)
                : colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isWarning ? colors.error : colors.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: textStyles.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isWarning ? colors.error : colors.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const Gap(AppSpacing.xs),
                Text(
                  subtitle!,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DiagnosticResultUIHelper {
  static String incidentLabel(String key) => AppStringsDiagnostic.incidentLabel(key);

  static String riskLabel(String key) => AppStringsDiagnostic.riskLabel(key);

  static Color issueColor(String key, ColorScheme colors) {
    switch (key) {
      case 'component_damage': return colors.error;
      case 'ammo_defective': return const Color(0xFFC27A1A);
      case 'fouling_dirty': return const Color(0xFF8A6A3B);
      case 'configuration_issue': return const Color(0xFF356AE6);
      case 'optic_or_mount': return const Color(0xFF7B4CE0);
      case 'human_factor': return const Color(0xFF2F8F83);
      default: return colors.secondary;
    }
  }

  static Widget issueDot(Color color) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  static Widget buildProbabilityRow({
    required String issueKey,
    required int value,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    return Row(
      children: [
        issueDot(issueColor(issueKey, colors)),
        const Gap(AppSpacing.xs),
        Expanded(
          child: Text(
            '${AppStringsDiagnostic.issueLabel(issueKey)} — $value%',
            style: textStyles.bodySmall?.copyWith(color: colors.onSurface),
          ),
        ),
      ],
    );
  }
}

class DiagnosticResultSheet extends StatelessWidget {
  final Diagnostic diagnostic;

  const DiagnosticResultSheet({super.key, required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final platformName = diagnostic.platformNameSnapshot.isNotEmpty 
        ? diagnostic.platformNameSnapshot 
        : 'plateforme non spécifiée';
    final platformType = diagnostic.platformTypeSnapshot;
    final date = diagnostic.date;
    
    final sortedProbabilities = diagnostic.probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final iconColor = DiagnosticResultUIHelper.issueColor(diagnostic.suspectedIssueKey, colors);
    final riskLabel = DiagnosticResultUIHelper.riskLabel(diagnostic.riskLevelKey);
    final incidentLabel = DiagnosticResultUIHelper.incidentLabel(diagnostic.incidentKey);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.checklist_rounded, size: 80, color: iconColor),
        const Gap(AppSpacing.lg),
        Text(
          AppStringsDiagnostic.diagnosticOfPlatform(platformName),
          style: textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(AppSpacing.xs),
        Text(
          '$platformType • ${AppDateFormats.formatDateTimeShort(context, date)}',
          style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          textAlign: TextAlign.center,
        ),
        const Gap(AppSpacing.md),
        
        // 1. CARTE PRINCIPALE : Incident et Cause
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStringsDiagnostic.diagnosticIdentifiedIncidentTitle.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.xs),
              Text(
                incidentLabel,
                style: textStyles.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
              Text(
                AppStringsDiagnostic.diagnosticSuspectedIssueTitle.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.build_circle_rounded, color: iconColor, size: 24),
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      diagnostic.finalDecision,
                      style: textStyles.titleLarge?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              if (diagnostic.suspectedIssueKey == 'component_damage') ...[
                const Gap(AppSpacing.sm),
                Text(
                  AppStringsDiagnostic.issueComponentDamageHint,
                  style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
                ),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 2. NIVEAU DE RISQUE ET PROBABILITÉS
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStringsDiagnostic.diagnosticRiskLevelTitle.toUpperCase(),
                    style: textStyles.labelSmall?.copyWith(
                      color: colors.secondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: diagnostic.riskLevelKey == 'high' 
                          ? colors.error.withValues(alpha: 0.1) 
                          : diagnostic.riskLevelKey == 'medium'
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: diagnostic.riskLevelKey == 'high' 
                            ? colors.error 
                            : diagnostic.riskLevelKey == 'medium'
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    child: Text(
                      riskLabel,
                      style: textStyles.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: diagnostic.riskLevelKey == 'high' 
                            ? colors.error 
                            : diagnostic.riskLevelKey == 'medium'
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
              Text(
                AppStringsDiagnostic.diagnosticProbabilitiesTitle.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.sm),
              ...sortedProbabilities.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DiagnosticResultUIHelper.buildProbabilityRow(
                      issueKey: entry.key,
                      value: entry.value,
                      colors: colors,
                      textStyles: textStyles,
                    ),
                  )),
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 3. RECOMMANDATIONS
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: colors.primary, size: 24),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStringsDiagnostic.diagnosticImmediateActionsTitle.toUpperCase(),
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      AppStringsDiagnostic.diagnosticRecommendedActions(diagnostic.riskLevelKey),
                      style: textStyles.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 4. À ÉVITER
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.do_not_disturb_alt_rounded, color: colors.error, size: 24),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStringsDiagnostic.diagnosticAvoidTitle.toUpperCase(),
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.error,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      AppStringsDiagnostic.diagnosticAvoidActions(),
                      style: textStyles.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.md),

        // 5. RÉSUMÉ
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.summaryLabel.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.sm),
              Text(
                diagnostic.summary,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.xl),
        
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              foregroundColor: colors.secondary,
            ),
            child: Text(
              strings.closeUpper,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

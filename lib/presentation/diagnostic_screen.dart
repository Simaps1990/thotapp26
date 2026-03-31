import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:go_router/go_router.dart';
import '../data/thot_provider.dart';
import '../data/models.dart';
import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';

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
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    
    final content = Column(
      children: [
        if (!widget.embedded) ...[
          // Handle bar
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
        ],
          
          // Header (sans bouton de fermeture explicite)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.diagnosticToolTitle,
                    style: textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                // Icône en forme de V pour fermer
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.diagnosticToolSubtitle,
                style: textStyles.bodySmall?.copyWith(
                  color: colors.secondary,
                ),
              ),
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
  
  const DiagnosticHistoryView({Key? key, required this.onStartNew}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    
    return Column(
      children: [
        // New diagnostic button
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(strings.diagnosticDisclaimerTitle),
                    content: Text(strings.diagnosticDisclaimerBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(strings.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(strings.diagnosticDisclaimerConfirm),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  onStartNew();
                }
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text(strings.diagnosticNew),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
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
                      Icon(Icons.medical_services_outlined, size: 64, color: colors.secondary),
                      const Gap(AppSpacing.md),
                      Text(
                        strings.diagnosticEmptyTitle,
                        style: textStyles.bodyLarge?.copyWith(color: colors.secondary),
                      ),
                      const Gap(AppSpacing.xs),
                      Text(
                        strings.diagnosticEmptySubtitle,
                        style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: provider.diagnostics.length,
                  separatorBuilder: (_, __) => const Gap(AppSpacing.md),
                  itemBuilder: (context, index) {
                    final diagnostic = provider.diagnostics[index];
                    final weapon = provider.getWeaponById(diagnostic.weaponId);
                    
                    return Dismissible(
                      key: Key(diagnostic.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(strings.diagnosticDeleteTitle),
                            content: Text(strings.diagnosticDeleteMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(strings.actionCancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(foregroundColor: colors.error),
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
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(Icons.delete_outline, color: colors.onError),
                      ),
                      onDismissed: (_) => provider.deleteDiagnostic(diagnostic.id),
                      child: Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: colors.secondary),
                                      const Gap(AppSpacing.xs),
                                      Text(
                                        AppDateFormats.formatDateTimeShort(
                                            context, diagnostic.date),
                                        style: textStyles.labelSmall?.copyWith(color: colors.secondary),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(strings.diagnosticDeleteTitle),
                                        content: Text(strings.diagnosticDeleteMessage),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text(strings.actionCancel),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              provider.deleteDiagnostic(diagnostic.id);
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(foregroundColor: colors.error),
                                            child: Text(strings.delete),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.delete_outline, color: colors.error),
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.sm),
                            Text(
                              diagnostic.weaponId == 'none'
                                  ? strings.diagnosticNoSpecificWeapon
                                  : (weapon?.name ?? strings.unknownWeapon),
                              style: textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                            const Gap(AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.decisionLabel,
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
                                    style: textStyles.bodySmall?.copyWith(color: colors.onSurface),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
  
  const DiagnosticTreeView({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<DiagnosticTreeView> createState() => _DiagnosticTreeViewState();
}

class _DiagnosticTreeViewState extends State<DiagnosticTreeView> {
  final Map<String, dynamic> _responses = {};
  int _currentStep = 0;
  final List<int> _history = [];
  
  String? _selectedWeaponId;

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
    if (_currentStep == 0) return 1; // weapon selection -> safety
    if (_currentStep == 1) {
      if (_responses['q1'] == 'non') return 99;
      return 2;
    }
    if (_currentStep == 2) {
      if (_responses['q2'] == 'non') return 99;
      return 3;
    }
    if (_currentStep == 3) {
      if (_responses['q3'] == 'inconnu') return 99;
      return 4; // choose incident
    }

    // Incident selection
    if (_currentStep == 4) {
      final incident = _responses['q4'];
      if (incident == 'Non-tir') return 5;
      if (incident == 'Long feu') return 10;
      if (incident == 'Départ intempestif') return 13;
      if (incident == 'Enrayage') return 16;
      if (incident == 'Baisse de précision') return 23;
      return 100;
    }

    // Non-tir
    if (_currentStep == 5) {
      if (_responses['q5'] == 'non') return 6;
      return 7;
    }
    if (_currentStep == 6) {
      if (_responses['q6'] == 'non') {
        _responses['final'] = 'PERCUTEUR / DÉVERROUILLAGE';
        return 100;
      }
      return 7;
    }
    if (_currentStep == 7) {
      if (_responses['q7'] == 'non') {
        _responses['final'] = 'PERCUSSION FAIBLE / HORS AXE';
        return 100;
      }
      return 8;
    }
    if (_currentStep == 8) {
      if (_responses['q8'] == 'non') {
        _responses['final'] = 'DÉFAUT DE CHAMBRAGE / ALIMENTATION';
        return 16;
      }
      return 9;
    }
    if (_currentStep == 9) {
      _responses['final'] = _responses['q9'] == 'oui'
          ? 'MUNITION / LOT DÉFECTUEUX'
          : 'CAUSES MULTIFACTORIELLES (MUNITION / MECANIQUE / FACTEUR HUMAIN)';
      return 100;
    }

    // Long feu
    if (_currentStep == 10) {
      if (_responses['q10'] == 'oui') return 11;
      return 12;
    }
    if (_currentStep == 11) {
      _responses['final'] = 'LONG FEU (DANGER) — MUNITION DÉFECTUEUSE';
      return 100;
    }
    if (_currentStep == 12) {
      _responses['final'] = 'INCIDENT MUNITION — PROCÉDURE LONG FEU';
      return 100;
    }

    // Départ intempestif
    if (_currentStep == 13) {
      if (_responses['q13'] == 'non') {
        _responses['final'] = 'FACTEUR HUMAIN (DOIGT / SÛRETÉ / MANIPULATION)';
        return 100;
      }
      return 14;
    }
    if (_currentStep == 14) {
      if (_responses['q14'] == 'oui') return 98;
      return 15;
    }
    if (_currentStep == 15) {
      _responses['final'] = 'DÉFAUT MÉCANIQUE GRAVE (DÉTENTE / ACCROCHAGE)';
      return 98;
    }

    // Enrayage
    if (_currentStep == 16) return 17;
    if (_currentStep == 17) {
      if (_responses['q17'] == 'oui') return 18;
      return 19;
    }
    if (_currentStep == 18) {
      _responses['final'] = 'ALIMENTATION / CHARGEUR';
      return 100;
    }
    if (_currentStep == 19) {
      if (_responses['q16'] == 'Extraction/éjection') {
        _responses['final'] = 'EXTRACTION / ÉJECTION';
        return 100;
      }
      _responses['final'] = 'CHAMBRAGE / RETOUR EN BATTERIE';
      return 100;
    }

    // Baisse de précision
    if (_currentStep == 23) {
      if (_responses['q23'] == 'non') {
        _responses['final'] = 'FACTEUR HUMAIN / APPUI';
        return 100;
      }
      return 24;
    }
    if (_currentStep == 24) {
      if (_responses['q24'] == 'oui') {
        _responses['final'] = 'MUNITION (LOT / TYPE)';
        return 100;
      }
      return 25;
    }
    if (_currentStep == 25) {
      if (_responses['q25'] == 'oui') {
        _responses['final'] = 'OPTique / MONTAGE DESSERRÉ';
        return 100;
      }
      return 26;
    }
    if (_currentStep == 26) {
      _responses['final'] = _responses['q26'] == 'oui'
          ? 'ENCRASSEMENT / ENTRETIEN'
          : 'CAUSES MULTIFACTORIELLES (ARME / OPTIQUE / MUNITION)';
      return 100;
    }

    return 100;
  }
  
  String _getQuestionKey(int step) {
    if (step == 0) return 'weapon_id';
    return 'q$step';
  }
  
  void _completeDiagnostic() {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    
    // Generate summary
    final summary = _generateSummary();
    final decision = _getFinalDecision();
    
    final diagnostic = Diagnostic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weaponId: _selectedWeaponId ?? 'none',
      responses: Map.from(_responses),
      finalDecision: decision,
      summary: summary,
    );
    
    provider.addDiagnostic(diagnostic);
    widget.onComplete();
  }
  
  String _generateSummary() {
    final strings = AppStrings.of(context);
    final parts = <String>[];
    
    // If weapon selected, use weapon info
    if (_selectedWeaponId != null && _selectedWeaponId != 'none') {
      final provider = Provider.of<ThotProvider>(context, listen: false);
      final weapon = provider.getWeaponById(_selectedWeaponId!);
      if (weapon != null) {
        parts.add('${strings.weaponLabel}: ${weapon.name}');
        parts.add('${strings.caliberLabel}: ${weapon.caliber}');
      }
    }
    
    if (_responses['q4'] != null) {
      parts.add('${strings.incidentLabel}: ${_responses['q4']}');
    }
    if (_responses['final'] != null) {
      parts.add('${strings.hypothesisLabel}: ${_responses['final']}');
    }
    
    return parts.join(' • ');
  }
  
  String _getFinalDecision() {
    if (_responses['final'] != null) {
      return _responses['final'];
    }
    return AppStrings.of(context).diagnosticDefaultFinal;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    
    if (_currentStep == 99) {
      // STOP screens
      return _buildStopScreen();
    }
    
    if (_currentStep == 98) {
      // IMMOBILISATION
      return _buildImmobilisationScreen();
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
        return _buildWeaponSelection();
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
      case 22:
        return _buildQ22();
      case 23:
        return _buildQ23();
      case 24:
        return _buildQ24();
      case 25:
        return _buildQ25();
      case 26:
        return _buildQ26();
      case 27:
        return _buildQ27();
      case 28:
        return _buildQ28();
      case 29:
        return _buildQ29();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildWeaponSelection() {
    final provider = Provider.of<ThotProvider>(context);
    final strings = AppStrings.of(context);
    
    return _QuestionCard(
      title: strings.diagnosticWeaponSelectionTitle,
      child: Column(
        children: [
          _OptionButton(
            text: strings.diagnosticNoSpecificWeapon,
            subtitle: strings.diagnosticNoSpecificWeaponSubtitle,
            onTap: () {
              _selectedWeaponId = null;
              _answer('weapon_id', 'none');
            },
          ),
          if (provider.weapons.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Text(
              strings.diagnosticOrSelectWeapon,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(AppSpacing.md),
            ...provider.weapons.map((weapon) {
              return _OptionButton(
                text: weapon.name,
                subtitle: '${weapon.caliber} • ${weapon.model}',
                onTap: () {
                  _selectedWeaponId = weapon.id;
                  _answer('weapon_id', weapon.id);
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
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q1', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, isWarning: true, onTap: () => _answer('q1', 'non')),
      ],
    ),
  );
  
  Widget _buildQ2() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion2,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q2', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, isWarning: true, onTap: () => _answer('q2', 'non')),
      ],
    ),
  );
  
  Widget _buildQ3() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion3,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).diagnosticWeaponPossiblyLoaded, onTap: () => _answer('q3', 'chargée')),
        _OptionButton(text: AppStrings.of(context).diagnosticWeaponOpenedSafe, onTap: () => _answer('q3', 'neutralisée')),
        _OptionButton(text: AppStrings.of(context).diagnosticUnknownState, isWarning: true, onTap: () => _answer('q3', 'inconnu')),
      ],
    ),
  );
  
  Widget _buildQ4() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion4,
    subtitle: AppStrings.of(context).diagnosticClassification,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).diagnosticIncidentNoFire, onTap: () => _answer('q4', 'Non-tir')),
        _OptionButton(text: AppStrings.of(context).diagnosticIncidentHangfire, onTap: () => _answer('q4', 'Long feu')),
        _OptionButton(text: AppStrings.of(context).diagnosticIncidentUnintendedDischarge, isWarning: true, onTap: () => _answer('q4', 'Départ intempestif')),
        _OptionButton(text: AppStrings.of(context).diagnosticIncidentJam, onTap: () => _answer('q4', 'Enrayage')),
        _OptionButton(text: AppStrings.of(context).diagnosticIncidentAccuracyDrop, onTap: () => _answer('q4', 'Baisse de précision')),
      ],
    ),
  );
  
  Widget _buildQ5() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion5,
    subtitle: AppStrings.of(context).diagnosticNoFireLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q5', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q5', 'non')),
      ],
    ),
  );
  
  Widget _buildQ6() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion6,
    subtitle: AppStrings.of(context).diagnosticNoFireLabel,
    description: AppStrings.of(context).diagnosticQuestion6Description,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q6', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q6', 'non')),
      ],
    ),
  );
  
  Widget _buildQ7() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion7,
    subtitle: AppStrings.of(context).diagnosticNoFireLabel,
    description: AppStrings.of(context).diagnosticQuestion7Description,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q7', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q7', 'non')),
      ],
    ),
  );
  
  Widget _buildQ8() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion8,
    subtitle: AppStrings.of(context).diagnosticNoFireLabel,
    description: AppStrings.of(context).diagnosticQuestion8Description,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q8', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q8', 'non')),
      ],
    ),
  );
  
  Widget _buildQ9() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion9,
    subtitle: AppStrings.of(context).diagnosticNoFireLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q9', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q9', 'non')),
      ],
    ),
  );
  
  Widget _buildQ10() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion10,
    subtitle: AppStrings.of(context).diagnosticHangfireLabel,
    description: AppStrings.of(context).diagnosticQuestion10Description,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, isWarning: true, onTap: () => _answer('q10', 'oui')),
        _OptionButton(text: AppStrings.of(context).diagnosticNoOrUnknown, onTap: () => _answer('q10', 'non')),
      ],
    ),
  );
  
  Widget _buildQ11() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion11,
    subtitle: AppStrings.of(context).diagnosticHangfireLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q11', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, isWarning: true, onTap: () => _answer('q11', 'non')),
      ],
    ),
  );
  
  Widget _buildQ12() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion12,
    subtitle: AppStrings.of(context).diagnosticHangfireLabel,
    description: AppStrings.of(context).diagnosticQuestion12Description,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q12', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, isWarning: true, onTap: () => _answer('q12', 'non')),
      ],
    ),
  );
  
  Widget _buildQ13() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion13,
    subtitle: AppStrings.of(context).diagnosticUnintendedDischargeLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q13', 'oui')),
        _OptionButton(text: AppStrings.of(context).diagnosticNoOrDoubt, onTap: () => _answer('q13', 'non')),
      ],
    ),
  );
  
  Widget _buildQ14() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion14,
    subtitle: AppStrings.of(context).diagnosticUnintendedDischargeLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, isWarning: true, onTap: () => _answer('q14', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q14', 'non')),
      ],
    ),
  );
  
  Widget _buildQ15() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion15,
    subtitle: AppStrings.of(context).diagnosticUnintendedDischargeLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, isWarning: true, onTap: () => _answer('q15', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q15', 'non')),
      ],
    ),
  );
  
  Widget _buildQ16() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion16,
    subtitle: AppStrings.of(context).diagnosticJamLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).diagnosticJamFeeding, onTap: () => _answer('q16', 'Alimentation/chambrage')),
        _OptionButton(text: AppStrings.of(context).diagnosticJamReturnToBattery, onTap: () => _answer('q16', 'Retour en batterie')),
        _OptionButton(text: AppStrings.of(context).diagnosticJamExtractionEjection, onTap: () => _answer('q16', 'Extraction/éjection')),
        _OptionButton(text: AppStrings.of(context).iDoNotKnow, onTap: () => _answer('q16', 'Inconnu')),
      ],
    ),
  );
  
  Widget _buildQ17() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion17,
    subtitle: AppStrings.of(context).diagnosticJamLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q17', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q17', 'non')),
      ],
    ),
  );
  
  Widget _buildQ18() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion18,
    subtitle: AppStrings.of(context).diagnosticJamLabel,
    description: AppStrings.of(context).diagnosticQuestion18Description,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q18', 'oui')),
        _OptionButton(text: AppStrings.of(context).diagnosticNoOrSeveral, onTap: () => _answer('q18', 'non')),
      ],
    ),
  );
  
  Widget _buildQ19() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion19,
    subtitle: AppStrings.of(context).diagnosticJamLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q19', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q19', 'non')),
      ],
    ),
  );

  Widget _buildQ20() => const SizedBox();

  Widget _buildQ21() => const SizedBox();

  Widget _buildQ22() => const SizedBox();
  
  Widget _buildQ23() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion23,
    subtitle: AppStrings.of(context).diagnosticAccuracyDropLabel,
    description: AppStrings.of(context).diagnosticQuestion23Description,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q23', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q23', 'non')),
      ],
    ),
  );
  
  Widget _buildQ24() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion24,
    subtitle: AppStrings.of(context).diagnosticAccuracyDropLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q24', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q24', 'non')),
      ],
    ),
  );
  
  Widget _buildQ25() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion25,
    subtitle: AppStrings.of(context).diagnosticAccuracyDropLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q25', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q25', 'non')),
      ],
    ),
  );
  
  Widget _buildQ26() => _QuestionCard(
    title: AppStrings.of(context).diagnosticQuestion26,
    subtitle: AppStrings.of(context).diagnosticAccuracyDropLabel,
    child: Column(
      children: [
        _OptionButton(text: AppStrings.of(context).yesUpper, onTap: () => _answer('q26', 'oui')),
        _OptionButton(text: AppStrings.of(context).noUpper, onTap: () => _answer('q26', 'non')),
      ],
    ),
  );
  
  Widget _buildQ27() => const SizedBox();
  Widget _buildQ28() => const SizedBox();
  Widget _buildQ29() => const SizedBox();
  
  Widget _buildStopScreen() {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    
    String message = '';
    if (_responses['q1'] == 'non' || _responses['q2'] == 'non') {
      message = strings.diagnosticImmediateStopMessage;
    } else if (_responses['q3'] == 'inconnu') {
      message = strings.diagnosticUnknownStateMessage;
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
  
  Widget _buildImmobilisationScreen() {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: colors.error),
            const Gap(AppSpacing.lg),
            Text(
              strings.immobilizeWeaponTitle,
              style: textStyles.titleLarge?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.md),
            Text(
              strings.immobilizeWeaponMessage,
              style: textStyles.bodyLarge?.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeDiagnostic,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                child: Text(strings.saveDiagnosticUpper),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFinalScreen() {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final decision = _getFinalDecision();
    final causes = strings.diagnosticDecisionCauses(decision);
    final actions = strings.diagnosticDecisionActions(decision);
    
    IconData icon;
    Color iconColor;
    
    if (decision.contains('IMMOBILISATION') || decision.contains('EXPERTISE')) {
      icon = Icons.error_outline;
      iconColor = colors.error;
    } else if (decision.contains('CONTRÔLE')) {
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFC2A14A);
    } else {
      icon = Icons.check_circle_outline;
      iconColor = const Color(0xFF3A7D44);
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: iconColor),
            const Gap(AppSpacing.lg),
            Text(
              strings.diagnosticCompletedTitle,
              style: textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.lg),
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.finalDecisionLabel,
                    style: textStyles.labelSmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    decision,
                    style: textStyles.titleMedium?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  Text(
                    strings.probableCausesLabel,
                    style: textStyles.labelSmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    causes,
                    style: textStyles.bodyMedium?.copyWith(color: colors.onSurface),
                  ),
                  const Gap(AppSpacing.lg),
                  Text(
                    strings.recommendedActionLabel,
                    style: textStyles.labelSmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    actions,
                    style: textStyles.bodyMedium?.copyWith(color: colors.onSurface),
                  ),
                  const Gap(AppSpacing.lg),
                  Text(
                    strings.summaryLabel,
                    style: textStyles.labelSmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    _generateSummary(),
                    style: textStyles.bodyMedium?.copyWith(color: colors.onSurface),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeDiagnostic,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
                child: Text(strings.saveDiagnosticUpper),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final Widget child;
  
  const _QuestionCard({
    required this.title,
    this.subtitle,
    this.description,
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
        if (description != null) ...[
          const Gap(AppSpacing.sm),
          Text(
            description!,
            style: textStyles.bodySmall?.copyWith(
              color: colors.secondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: isWarning ? colors.error.withValues(alpha: 0.1) : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
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

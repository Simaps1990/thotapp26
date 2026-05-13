import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/standard_drills.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/utils/unit_converter.dart';
import 'package:thot/widgets/cross_platform_image.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/utils/native_picker.dart';

class _CitySuggestion {
  final String name;
  final String countryCode;
  final double latitude;
  final double longitude;

  const _CitySuggestion({
    required this.name,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  String get label => '$name, $countryCode';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _CitySuggestion &&
            other.name == name &&
            other.countryCode == countryCode &&
            other.latitude == latitude &&
            other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(name, countryCode, latitude, longitude);
}

class NewSessionScreen extends StatefulWidget {
  final String? sessionId;

  const NewSessionScreen({super.key, this.sessionId});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationFocusNode = FocusNode();
  final _shootingDistanceController = TextEditingController();

  final _sessionScrollController = ScrollController();
  final _nameFieldKey = GlobalKey();
  final _locationFieldKey = GlobalKey();
  final _exercisesFieldKey = GlobalKey();

  // Convenience accessor for localized strings.
  AppStrings get strings => AppStrings.of(context);

  bool _nameError = false;
  bool _locationError = false;
  bool _exercisesError = false;

  DateTime _selectedDate = DateTime.now();
  String _sessionType =
      'Personnel'; // Stored as internal key, displayed via AppStrings

  // Weather
  bool _weatherEnabled = false;
  bool _isWeatherLoading = false;
  final _tempController = TextEditingController();
  final _windController = TextEditingController();
  final _humidityController = TextEditingController();
  final _pressureController = TextEditingController();

  bool _tempEnabled = true;
  bool _windEnabled = true;
  bool _humidityEnabled = true;
  bool _pressureEnabled = true;

  // Exercises
  List<Exercise> _exercises = [];

  double? _selectedCityLatitude;
  double? _selectedCityLongitude;

  bool _isApplyingCitySelection = false;
  bool _citySearchError = false;
  Timer? _cityDebounce;
  int _cityRequestId = 0;

  @override
  void initState() {
    super.initState();

    if (widget.sessionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSession();
      });
    }
  }

  void _loadSession() {
    final provider = Provider.of<ThotProvider>(context, listen: false);

    try {
      final session = provider.sessions.firstWhere(
        (s) => s.id == widget.sessionId,
      );

      setState(() {
        _nameController.text = session.name;
        _locationController.text = session.location;
        _shootingDistanceController.text = session.shootingDistance ?? '';
        _selectedDate = session.date;
        _sessionType = session.sessionType;
        _weatherEnabled = session.weatherEnabled;
        _tempController.text = session.temperature;
        _windController.text = session.wind;
        _humidityController.text = session.humidity;
        _pressureController.text = session.pressure;
        _tempEnabled = session.temperatureEnabled;
        _windEnabled = session.windEnabled;
        _humidityEnabled = session.humidityEnabled;
        _pressureEnabled = session.pressureEnabled;
        _exercises = List.from(session.exercises);

        _selectedCityLatitude = session.locationLatitude;
        _selectedCityLongitude = session.locationLongitude;

        final rawLocation = session.location.trim();
        if (rawLocation.contains(',')) {
          final parts = rawLocation.split(',');
          if (parts.isEmpty) {
            // keep location as typed; no additional metadata to store here
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Widget _buildHeader({
    required ColorScheme colors,
    required TextTheme textStyles,
    required double topInset,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        defaultTargetPlatform == TargetPlatform.iOS
            ? (topInset / 2 + 20)
            : (topInset + 20),
        20,
        8,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Text(
              strings.newSessionTitle,
              textAlign: TextAlign.center,
              style: textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: colors.onSurface,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGeneralInfoSection({
    required BuildContext context,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    return [
      // Session Type
      Row(
        children: [
          Icon(Icons.tune_rounded, size: 18, color: colors.primary),
          const Gap(8),
          Text(
            strings.sessionTypeLabel.toUpperCase(),
            style: textStyles.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
      const Gap(AppSpacing.sm),
      _SlidingSegmentedSelector(
        selectedIndex: switch (_sessionType) {
          'Professionnel' => 1,
          'Compétition' => 2,
          _ => 0,
        },
        labels: [
          strings.sessionTypePersonal,
          strings.sessionTypeProfessional,
          strings.sessionTypeCompetition,
        ],
        onSelected: (index) {
          setState(() {
            _sessionType = switch (index) {
              1 => 'Professionnel',
              2 => 'Compétition',
              _ => 'Personnel',
            };
          });
        },
      ),
      const Gap(AppSpacing.md),

      Container(
        key: _nameFieldKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              onChanged: (_) {
                if (_nameError && _nameController.text.trim().isNotEmpty) {
                  setState(() => _nameError = false);
                }
              },
              decoration: InputDecoration(
                labelText: strings.sessionNameLabel,
                hintText: strings.sessionNameHint,
                hintStyle: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface.withAlpha(100),
                ),
                errorText: null,
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
                  borderSide: BorderSide(color: colors.outline),
                ),
              ),
            ),
            if (_nameError)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Text(
                  strings.requiredFieldError,
                  style: textStyles.bodySmall?.copyWith(color: colors.error),
                ),
              ),
          ],
        ),
      ),
      const Gap(AppSpacing.md),

      // Date and Time
      InkWell(
        onTap: _selectDateTime,
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today_rounded),
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
              borderSide: BorderSide(color: colors.outline),
            ),
          ),
          child: Text(
            AppDateFormats.formatDateTimeShort(context, _selectedDate),
            style: textStyles.bodyLarge,
          ),
        ),
      ),

      const Gap(AppSpacing.md),

      Container(
        key: _locationFieldKey,
        child: Autocomplete<_CitySuggestion>(
          textEditingController: _locationController,
          focusNode: _locationFocusNode,
          displayStringForOption: (_CitySuggestion option) => option.label,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            final query = textEditingValue.text.trim();

            if (_isApplyingCitySelection || query.length < 2) {
              return const <_CitySuggestion>[];
            }

            return await _searchCitiesDebounced(query);
          },
          onSelected: (city) async {
            await _onCitySelected(city);
          },
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onFieldSubmitted(),
                  onChanged: (value) {
                    if (_isApplyingCitySelection) return;

                    setState(() {
                      if (_locationError && value.trim().isNotEmpty) {
                        _locationError = false;
                      }

                      _citySearchError = false;
                      _selectedCityLatitude = null;
                      _selectedCityLongitude = null;
                      _weatherEnabled = false;
                      _tempController.clear();
                      _windController.clear();
                      _humidityController.clear();
                      _pressureController.clear();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: strings.locationLabel,
                    hintText: strings.locationHint,
                    hintStyle: textStyles.bodyMedium?.copyWith(
                      color: colors.onSurface.withAlpha(100),
                    ),
                    errorText: _locationError
                        ? strings.locationRequiredForWeather
                        : (_citySearchError
                              ? strings.citySearchUnavailable
                              : null),
                    prefixIcon: const Icon(Icons.place_rounded),
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
                      borderSide: BorderSide(color: colors.outline),
                    ),
                  ),
                );
              },
        ),
      ),

      const Gap(AppSpacing.md),

      TextField(
        controller: _shootingDistanceController,
        decoration: InputDecoration(
          labelText: strings.shootingDistanceLabel,
          hintText: strings.shootingDistanceHint,
          hintStyle: textStyles.bodyMedium?.copyWith(
            color: colors.onSurface.withAlpha(100),
          ),
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
            borderSide: BorderSide(color: colors.outline),
          ),
        ),
      ),

      const Gap(AppSpacing.md),
    ];
  }

  List<Widget> _buildSummarySection({
    required ColorScheme colors,
    required ThotProvider provider,
  }) {
    if (_exercises.isEmpty) return const [];

    return [
      // Session Summary
      _SectionHeader(
        leading: SvgPicture.asset(
          'assets/images/seance.svg',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        title: strings.sessionSummaryTitle,
      ),
      const Gap(AppSpacing.md),
      _SessionSummary(exercises: _exercises, provider: provider),
      const Gap(AppSpacing.xl),
    ];
  }

  List<Widget> _buildSaveSection({required ColorScheme colors}) {
    return [
      // Save Button
      SizedBox(
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.cardPremium,
          ),
          child: FilledButton(
            onPressed: _saveSession,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Text(strings.saveSessionButton),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildExercisesSection({
    required ColorScheme colors,
    required TextTheme textStyles,
    required ThotProvider provider,
  }) {
    return [
      // Exercises Section
      _SectionHeader(
        leading: SvgPicture.asset(
          'assets/images/train.svg',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        title: strings.exercisesSectionTitle,
      ),
      const Gap(AppSpacing.sm),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                strings.createExerciseButton.toUpperCase(),
                style: textStyles.labelLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _importExerciseFromTemplate,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                strings.importExerciseButton.toUpperCase(),
                style: textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
      const Gap(AppSpacing.md),
      Container(
        key: _exercisesFieldKey,
        child: _exercises.isEmpty
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addExercise,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/images/train.svg',
                          width: 40,
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).brightness == Brightness.dark
                                ? colors.onSurface
                                : colors.outline,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          strings.noExerciseAdded,
                          style: textStyles.bodyMedium?.copyWith(
                            color: _exercisesError
                                ? colors.error
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? colors.onSurface
                                      : colors.outline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: _exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return _ExerciseCard(
                    exercise: exercise,
                    index: index,
                    provider: provider,
                    onEdit: () => _editExercise(index),
                    onDelete: () => setState(() {
                      _exercises.removeAt(index);
                      _exercisesError = _exercises.isEmpty;
                    }),
                    onMoveUp: index > 0
                        ? () => setState(() {
                            final e = _exercises.removeAt(index);
                            _exercises.insert(index - 1, e);
                          })
                        : null,
                    onMoveDown: index < _exercises.length - 1
                        ? () => setState(() {
                            final e = _exercises.removeAt(index);
                            _exercises.insert(index + 1, e);
                          })
                        : null,
                  );
                }).toList(),
              ),
      ),
      const Gap(AppSpacing.lg),
    ];
  }

  List<Widget> _buildWeatherSection({
    required ColorScheme colors,
    required TextTheme textStyles,
    required UnitConverter converter,
  }) {
    return [
      // Weather Section
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SectionHeader(
            leading: Icon(
              Icons.wb_sunny_rounded,
              size: 18,
              color: colors.primary,
            ),
            title: strings.weatherConditionsTitle,
          ),
          Switch(value: _weatherEnabled, onChanged: _onWeatherToggled),
        ],
      ),
      if (_weatherEnabled) ...[
        const Gap(AppSpacing.md),

        if (_isWeatherLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colors.primary,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    strings.weatherLoadingText,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: WeatherEditableField(
                controller: _tempController,
                labelText: strings.temperatureLabel,
                hintText: converter.useMetric ? '22°C' : '72°F',
                prefixIcon: Icons.thermostat_rounded,
                enabled: _tempEnabled,
                onToggleEnabled: () =>
                    setState(() => _tempEnabled = !_tempEnabled),
              ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: WeatherEditableField(
                controller: _pressureController,
                labelText: strings.pressureLabel,
                hintText: '1013 hPa',
                prefixIcon: Icons.compress_rounded,
                enabled: _pressureEnabled,
                onToggleEnabled: () =>
                    setState(() => _pressureEnabled = !_pressureEnabled),
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: WeatherEditableField(
                controller: _windController,
                labelText: strings.windLabel,
                hintText: converter.useMetric ? '12 km/h' : '7 mph',
                prefixIcon: Icons.air_rounded,
                enabled: _windEnabled,
                onToggleEnabled: () =>
                    setState(() => _windEnabled = !_windEnabled),
              ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: WeatherEditableField(
                controller: _humidityController,
                labelText: strings.humidityLabel,
                hintText: '45%',
                prefixIcon: Icons.water_drop_rounded,
                enabled: _humidityEnabled,
                onToggleEnabled: () =>
                    setState(() => _humidityEnabled = !_humidityEnabled),
              ),
            ),
          ],
        ),
      ],
      const Gap(AppSpacing.md),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final converter = UnitConverter(provider.useMetric);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors.surface, // Couleur du fond du header
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                _buildHeader(
                  colors: colors,
                  textStyles: textStyles,
                  topInset: MediaQuery.paddingOf(context).top,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    controller: _sessionScrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._buildGeneralInfoSection(
                          context: context,
                          colors: colors,
                          textStyles: textStyles,
                        ),

                        ..._buildWeatherSection(
                          colors: colors,
                          textStyles: textStyles,
                          converter: converter,
                        ),

                        ..._buildExercisesSection(
                          colors: colors,
                          textStyles: textStyles,
                          provider: provider,
                        ),

                        ..._buildSummarySection(
                          colors: colors,
                          provider: provider,
                        ),

                        ..._buildSaveSection(colors: colors),
                        SizedBox(height: MediaQuery.paddingOf(context).bottom),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted) return;

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addTemplateAsExercise(ExerciseTemplate t) {
    final exercise = Exercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: t.name,
      platformId: _exercises.isNotEmpty ? _exercises.last.platformId : '',
      ammoId: _exercises.isNotEmpty ? _exercises.last.ammoId : '',
      shotsFired: t.shotsFired,
      distance: t.distance,
      observations: t.observations,
      steps: t.steps != null ? List<ExerciseStep>.from(t.steps!) : null,
      platformLabel: null,
      ammoLabel: null,
      equipmentIds: const [],
      targetName: null,
      targetPhotos: const [],
      precision: null,
      precisionEnabled: true,
    );
    setState(() {
      _exercises.add(exercise);
      _exercisesError = false;
    });
  }

  void _importExerciseFromTemplate() {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ImportExerciseTemplateSheet(
        provider: provider,
        onSelected: (template) {
          _addTemplateAsExercise(template);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _addExercise() {
    Exercise? template;
    if (_exercises.isNotEmpty) {
      final lastExercise = _exercises.last;
      template = Exercise(
        id: '',
        name: '',
        platformId: lastExercise.platformId,
        platformLabel: lastExercise.platformLabel,
        ammoId: lastExercise.ammoId,
        ammoLabel: lastExercise.ammoLabel,
        equipmentIds: List<String>.from(lastExercise.equipmentIds),
        platformAssignments: List<ExercisePlatformAssignment>.from(
          lastExercise.platformAssignments,
        ),
        shotAllocations: List<ExerciseShotAllocation>.from(
          lastExercise.shotAllocations,
        ),
        targetName: null,
        targetPhotos: const [],
        shotsFired: 0,
        distance: 0,
        precision: null,
        precisionEnabled: true,
        observations: '',
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final baseBackground = Theme.of(ctx).scaffoldBackgroundColor;
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.92;
        return SizedBox(
          height: sheetHeight,
          child: Container(
            decoration: BoxDecoration(
              color: baseBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: _ExerciseForm(
              exercise: template,
              scrollController: null,
              onSave: (exercise) {
                setState(() {
                  _exercises.add(exercise);
                  _exercisesError = false;
                });
                Navigator.of(ctx).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _editExercise(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final baseBackground = Theme.of(ctx).scaffoldBackgroundColor;
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.92;
        return SizedBox(
          height: sheetHeight,
          child: Container(
            decoration: BoxDecoration(
              color: baseBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: _ExerciseForm(
              exercise: _exercises[index],
              scrollController: null,
              onSave: (exercise) {
                setState(() {
                  _exercises[index] = exercise;
                  _exercisesError = false;
                });
                Navigator.of(ctx).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _saveSession() async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _locationError = false;
      _exercisesError = _exercises.isEmpty;
    });

    if (_nameError) {
      await Scrollable.ensureVisible(
        _nameFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_exercisesError) {
      await Scrollable.ensureVisible(
        _exercisesFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    final session = Session(
      id: widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      date: _selectedDate,
      location: _locationController.text.trim(),
      shootingDistance: _shootingDistanceController.text.isEmpty
          ? null
          : _shootingDistanceController.text,
      locationLatitude: _selectedCityLatitude,
      locationLongitude: _selectedCityLongitude,
      sessionType: _sessionType,
      exercises: _exercises,
      weatherEnabled: _weatherEnabled,
      temperature: _tempController.text,
      wind: _windController.text,
      humidity: _humidityController.text,
      pressure: _pressureController.text,
      temperatureEnabled: _tempEnabled,
      windEnabled: _windEnabled,
      humidityEnabled: _humidityEnabled,
      pressureEnabled: _pressureEnabled,
      platformIds: {
        for (final ex in _exercises)
          ...ex.platformShotImpact.keys.where(
            (wid) =>
                wid.trim().isNotEmpty && wid != 'none' && wid != 'borrowed',
          ),
      }.toList(growable: false),
    );

    assert(
      widget.sessionId == null || session.id == widget.sessionId,
      'Session id mismatch during update',
    );

    final provider = Provider.of<ThotProvider>(context, listen: false);

    if (!provider.isPremium) {
      for (final ex in _exercises) {
        for (final platformId in ex.platformShotImpact.keys) {
          if (platformId.trim().isEmpty ||
              platformId == 'none' ||
              platformId == 'borrowed') {
            continue;
          }
          if (!provider.canUsePlatformId(platformId)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.freeVersionPlatformLimit),
                duration: const Duration(seconds: 3),
              ),
            );
            showProModal(context);
            return;
          }
        }

        for (final ammoId in ex.ammoShotImpact.keys) {
          if (ammoId.trim().isEmpty ||
              ammoId == 'none' ||
              ammoId == 'borrowed') {
            continue;
          }
          if (!provider.canUseAmmoId(ammoId)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.freeVersionAmmoLimit),
                duration: const Duration(seconds: 3),
              ),
            );
            showProModal(context);
            return;
          }
        }

        for (final accId in ex.equipmentShotImpact.keys) {
          if (accId.trim().isEmpty || accId == 'none' || accId == 'borrowed') {
            continue;
          }
          if (!provider.canUseAccessoryId(accId)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.freeVersionAccessoryLimit),
                duration: const Duration(seconds: 3),
              ),
            );
            showProModal(context);
            return;
          }
        }
      }
    }

    if (widget.sessionId != null) {
      provider.updateSession(session);
    } else {
      if (!provider.canAddSession()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.getLimitMessage('session')),
            duration: const Duration(seconds: 3),
          ),
        );
        showProModal(context);
        return;
      }
      provider.addSession(session);
    }

    context.pop();
  }

  @override
  void dispose() {
    _cityDebounce?.cancel();
    _nameController.dispose();
    _locationController.dispose();
    _locationFocusNode.dispose();
    _shootingDistanceController.dispose();
    _sessionScrollController.dispose();
    _tempController.dispose();
    _windController.dispose();
    _humidityController.dispose();
    _pressureController.dispose();
    super.dispose();
  }

  Future<List<_CitySuggestion>> _searchCitiesDebounced(String query) {
    _cityDebounce?.cancel();
    final completer = Completer<List<_CitySuggestion>>();
    final myId = ++_cityRequestId;
    _cityDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final result = await _searchCities(query);
        if (myId != _cityRequestId) {
          if (!completer.isCompleted) completer.complete(const []);
        } else {
          if (!completer.isCompleted) completer.complete(result);
        }
      } catch (e) {
        if (!completer.isCompleted) completer.complete(const []);
      }
    });
    return completer.future;
  }

  Future<List<_CitySuggestion>> _searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    try {
      final uri = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        <String, String>{'name': trimmed, 'count': '8', 'format': 'json'},
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final results = decoded is Map<String, dynamic>
          ? decoded['results'] as List?
          : null;

      if (results == null) {
        if (mounted) {
          setState(() => _citySearchError = false);
        }
        return const [];
      }

      final suggestions = <_CitySuggestion>[];

      for (final item in results) {
        if (item is! Map<String, dynamic>) continue;

        final name = (item['name'] as String?)?.trim();
        final country =
            (item['country'] as String?)?.trim() ??
            (item['country_code'] as String?)?.trim().toUpperCase() ??
            '';
        final lat = (item['latitude'] as num?)?.toDouble();
        final lon = (item['longitude'] as num?)?.toDouble();

        if (name == null || name.isEmpty) continue;
        if (country.isEmpty) continue;
        if (lat == null || lon == null) continue;

        suggestions.add(
          _CitySuggestion(
            name: name,
            countryCode: country,
            latitude: lat,
            longitude: lon,
          ),
        );
      }

      if (mounted && _citySearchError) {
        setState(() => _citySearchError = false);
      }

      debugPrint('City query "$trimmed" -> ${suggestions.length} result(s)');
      return suggestions;
    } catch (e) {
      debugPrint('City search failed for "$trimmed": $e');

      if (mounted) {
        setState(() => _citySearchError = true);
      }

      return const [];
    }
  }

  Future<void> _onCitySelected(_CitySuggestion city) async {
    _isApplyingCitySelection = true;

    _locationController.text = city.label;
    _locationController.selection = TextSelection.collapsed(
      offset: _locationController.text.length,
    );

    setState(() {
      _selectedCityLatitude = city.latitude;
      _selectedCityLongitude = city.longitude;
      _locationError = false;
      _citySearchError = false;
    });

    try {
      await _autofillWeatherForCoordinates(
        lat: city.latitude,
        lon: city.longitude,
      );
    } finally {
      _isApplyingCitySelection = false;
    }
  }

  Future<void> _onWeatherToggled(bool enabled) async {
    if (!enabled) {
      setState(() {
        _weatherEnabled = false;
      });
      return;
    }

    final hasValidatedCity =
        _selectedCityLatitude != null &&
        _selectedCityLongitude != null &&
        _locationController.text.trim().isNotEmpty;

    if (!hasValidatedCity) {
      setState(() {
        _locationError = true;
        _weatherEnabled = false;
      });

      if (_locationFieldKey.currentContext != null) {
        await Scrollable.ensureVisible(
          _locationFieldKey.currentContext!,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.locationRequiredForWeather),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _weatherEnabled = true;
    });
  }

  Future<void> _autofillWeatherForCoordinates({
    required double lat,
    required double lon,
  }) async {
    if (_isWeatherLoading) return;

    setState(() => _isWeatherLoading = true);

    try {
      final provider = Provider.of<ThotProvider>(context, listen: false);
      final converter = UnitConverter(provider.useMetric);

      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat'
        '&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,pressure_msl,wind_speed_10m'
        '&timezone=auto',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('Weather autofill: HTTP ${res.statusCode}: ${res.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.weatherNetworkError),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final json = jsonDecode(utf8.decode(res.bodyBytes));
      final current = json is Map<String, dynamic> ? json['current'] : null;
      if (current is! Map<String, dynamic>) {
        debugPrint('Weather autofill: invalid response shape: $json');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.weatherInvalidResponse),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final tempC = (current['temperature_2m'] as num?)?.toDouble();
      final windKmh = (current['wind_speed_10m'] as num?)?.toDouble();
      final humidity = (current['relative_humidity_2m'] as num?)?.toDouble();
      final pressureHpa = (current['pressure_msl'] as num?)?.toDouble();

      if (tempC == null &&
          windKmh == null &&
          humidity == null &&
          pressureHpa == null) {
        debugPrint('Weather autofill: missing values: $current');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.weatherUnavailable),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      setState(() {
        if (tempC != null) {
          _tempController.text = converter.formatTemperature(tempC);
        }
        if (windKmh != null) {
          _windController.text = converter.formatWindSpeed(windKmh);
        }
        if (humidity != null) {
          _humidityController.text = '${humidity.round()}%';
        }
        if (pressureHpa != null) {
          _pressureController.text = converter.formatPressure(pressureHpa);
        }
      });
    } catch (e) {
      debugPrint('Weather autofill failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.weatherRetrievalError),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isWeatherLoading = false);
    }
  }
}

class WeatherEditableField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final VoidCallback onToggleEnabled;

  const WeatherEditableField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.enabled,
    required this.onToggleEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final radius = BorderRadius.circular(AppRadius.lg);

    final field = TextField(
      controller: controller,
      enabled: enabled,
      style: textStyles.bodyLarge?.copyWith(
        decoration: enabled ? TextDecoration.none : TextDecoration.lineThrough,
        color: enabled
            ? colors.onSurface
            : colors.onSurface.withValues(alpha: 0.55),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: textStyles.bodyMedium?.copyWith(
          color: colors.onSurface.withAlpha(100),
        ),
        prefixIcon: Icon(prefixIcon, size: 20),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.outline),
        ),
        suffixIcon: IconButton(
          tooltip: enabled ? strings.disableTooltip : strings.enableTooltip,
          onPressed: onToggleEnabled,
          icon: Icon(
            enabled ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 18,
            color: enabled
                ? colors.secondary
                : colors.secondary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );

    if (enabled) return field;

    // Disabled fields still need to be tappable to re-enable.
    return InkWell(
      onTap: onToggleEnabled,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      splashFactory: NoSplash.splashFactory,
      highlightColor: colors.primary.withValues(alpha: 0.08),
      child: AbsorbPointer(child: field),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final Widget leading;
  final String title;

  const _SectionHeader({required this.leading, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconTheme(
          data: IconThemeData(color: colors.primary, size: 18),
          child: leading,
        ),
        const Gap(8),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _SlidingSegmentedSelector extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  const _SlidingSegmentedSelector({
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / labels.length;

        final chipGray = Color.alphaBlend(
          colors.outline.withValues(alpha: 0.8),
          baseBackground,
        );

        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: chipGray,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: subtleBorderColor),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < labels.length; i++)
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onSelected(i),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                labels[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: i == selectedIndex
                                      ? colors.onPrimary
                                      : colors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final ThotProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final exerciseTitle = exercise.name.trim().isEmpty
        ? strings.exerciseCardTitle(index)
        : exercise.name.trim();
    final exerciseSubtitle = exercise.name.trim().isEmpty
        ? null
        : strings.exerciseCardTitle(index);

    void openTargetPhoto(ExercisePhoto photo) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          final dialogColors = Theme.of(ctx).colorScheme;
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    color: dialogColors.surface,
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CrossPlatformImage(
                          filePath: photo.path,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                    color: dialogColors.onSurface,
                    style: IconButton.styleFrom(
                      backgroundColor: dialogColors.surface.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final primaryPhoto = exercise.targetPhotos.isNotEmpty
        ? exercise.targetPhotos.first
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardDecoration = BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: isDark
          ? null
          : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
      boxShadow: AppShadows.cardPremium,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: exercise title + subtitle + edit/delete actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (exerciseSubtitle != null) ...[
                      const Gap(2),
                      Text(
                        exerciseSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (onMoveUp != null)
                    IconButton(
                      onPressed: onMoveUp,
                      icon: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 20,
                      ),
                      color: colors.secondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onMoveDown != null)
                    IconButton(
                      onPressed: onMoveDown,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                      ),
                      color: colors.secondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const Gap(8),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    color: colors.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Gap(8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const Gap(AppSpacing.md),

          // Card 3: shooting results (main target photo + shots & distance)
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.shootingResultsTitle,
                  style: textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: main target photo (if any)
                    if (primaryPhoto != null) ...[
                      GestureDetector(
                        onTap: () => openTargetPhoto(primaryPhoto),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: CrossPlatformImage(
                                  filePath: primaryPhoto.path,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Gap(4),
                            SizedBox(
                              width: 120,
                              child: Text(
                                primaryPhoto.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.labelSmall?.copyWith(
                                  color: colors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(AppSpacing.md),
                    ],

                    // Divider between photo and stats
                    if (primaryPhoto != null)
                      Container(width: 1, height: 120, color: colors.outline),
                    if (primaryPhoto != null) const Gap(AppSpacing.md),

                    // Right: shots & distance (and precision if counted)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: strings.shotsFiredLabel,
                            value: "${exercise.shotsFired}",
                          ),
                          _InfoRow(
                            label: strings.shootingDistanceDetailLabel,
                            value: provider.useMetric
                                ? '${exercise.distance} m'
                                : '${(exercise.distance * 1.09361).round()} yd',
                          ),
                          if (exercise.targetName != null &&
                              exercise.targetName!.isNotEmpty)
                            _InfoRow(
                              label: strings.usedTargetLabel,
                              value: exercise.targetName!,
                            ),
                          if (exercise.isPrecisionCounted)
                            _InfoRow(
                              label: strings.statisticsPrecisionTitle,
                              value:
                                  "${exercise.precision!.toStringAsFixed(0)}%",
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (exercise.observations.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            Text(
              strings.observationsTitle,
              style: textStyles.labelSmall?.copyWith(color: colors.secondary),
            ),
            Text(
              exercise.observations,
              style: textStyles.bodySmall?.copyWith(color: colors.secondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textStyles.labelSmall?.copyWith(color: colors.secondary),
          ),
          const Gap(2),
          Text(
            value,
            style: textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ImportExerciseTemplateSheet extends StatefulWidget {
  final ThotProvider provider;
  final ValueChanged<ExerciseTemplate> onSelected;

  const _ImportExerciseTemplateSheet({
    required this.provider,
    required this.onSelected,
  });

  @override
  State<_ImportExerciseTemplateSheet> createState() =>
      _ImportExerciseTemplateSheetState();
}

class _ImportExerciseTemplateSheetState
    extends State<_ImportExerciseTemplateSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedSourceIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseTemplate> _filteredTemplates(List<ExerciseTemplate> templates) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return templates;
    return templates
        .where(
          (template) =>
              template.name.toLowerCase().contains(query) ||
              template.observations.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );
    final standardDrills = _filteredTemplates(StandardDrills.all(strings));
    final userTemplates = _filteredTemplates(widget.provider.exerciseTemplates);
    final visibleTemplates = _selectedSourceIndex == 0
        ? standardDrills
        : userTemplates;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: baseBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(10),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: LightColors.iconInactive.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                strings.importTemplateTitle.toUpperCase(),
                                style: textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            const Gap(6),
                            Tooltip(
                              message: strings.createTemplateTooltip,
                              triggerMode: TooltipTriggerMode.tap,
                              showDuration: const Duration(seconds: 5),
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.onSurface.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: textStyles.bodySmall?.copyWith(
                                color: colors.surface,
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: colors.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Padding(
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
                const Gap(AppSpacing.xs),
                Divider(
                  color: colors.outline,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                ),
                const Gap(AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    10,
                  ),
                  child: SizedBox(
                    height: 44,
                    child: _SlidingSegmentedSelector(
                      selectedIndex: _selectedSourceIndex,
                      labels: [
                        strings.exerciseTemplatesStandardSection,
                        strings.exerciseTemplatesMyTemplatesSection,
                      ],
                      onSelected: (index) {
                        setState(() => _selectedSourceIndex = index);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: textStyles.bodyMedium?.copyWith(fontSize: 14),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: strings.searchEllipsis,
                      hintStyle: textStyles.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: colors.secondary,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              splashRadius: 18,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      filled: true,
                      fillColor: searchFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: visibleTemplates.isEmpty
                      ? Center(
                          child: Padding(
                            padding: AppSpacing.paddingLg,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 64,
                                  color: colors.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const Gap(AppSpacing.md),
                                Text(
                                  strings.noTemplatesAvailable,
                                  style: textStyles.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: visibleTemplates.length,
                          itemBuilder: (context, index) {
                            final template = visibleTemplates[index];
                            final subtitle = template.detailedMode
                                ? '${strings.stepsCount(template.steps?.length ?? 0)} · ${template.distance} m'
                                : '${template.shotsFired} coups · ${template.distance} m';
                            final isStandard = _selectedSourceIndex == 0;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.md,
                              ),
                              child: Material(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => widget.onSelected(template),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          template.name,
                                                          style: textStyles
                                                              .titleSmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: colors
                                                                    .onSurface,
                                                              ),
                                                        ),
                                                      ),
                                                      if (isStandard) ...[
                                                        const Gap(6),
                                                        Icon(
                                                          Icons
                                                              .verified_rounded,
                                                          size: 16,
                                                          color: colors.primary,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const Gap(2),
                                                  Text(
                                                    subtitle,
                                                    style: textStyles.bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              colors.secondary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Gap(AppSpacing.sm),
                                            FilledButton.icon(
                                              onPressed: () =>
                                                  widget.onSelected(template),
                                              icon: const Icon(
                                                Icons.add,
                                                size: 16,
                                              ),
                                              label: Text(
                                                strings.templateImportButton,
                                              ),
                                              style: FilledButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (template.observations
                                            .trim()
                                            .isNotEmpty) ...[
                                          const Gap(4),
                                          Text(
                                            '${strings.observationsTitle} : ${template.observations.trim()}',
                                            style: textStyles.bodySmall
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SessionSummary extends StatelessWidget {
  final List<Exercise> exercises;
  final ThotProvider provider;

  const _SessionSummary({required this.exercises, required this.provider});

  String _getCurrencySymbol(String? currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'CAD':
        return 'CA\$';
      case 'GBP':
        return '£';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'EUR':
      default:
        return '€';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final totalShots = exercises.fold(0, (sum, ex) => sum + ex.shotsFired);

    // Impact on ammo (inventory only)
    final Map<String, int> ammoImpact = {};
    for (final ex in exercises) {
      ex.ammoShotImpact.forEach((ammoId, shots) {
        final ammo = provider.getAmmoById(ammoId);
        if (ammo == null) return;
        ammoImpact[ammo.id] = (ammoImpact[ammo.id] ?? 0) + shots;
      });
    }

    // Impact on platforms (inventory only)
    final Map<String, int> platformImpact = {};
    for (final ex in exercises) {
      ex.platformShotImpact.forEach((platformId, shots) {
        final platform = provider.getPlatformById(platformId);
        if (platform == null) return;
        platformImpact[platform.id] =
            (platformImpact[platform.id] ?? 0) + shots;
      });
    }

    // Impact on equipment
    final Map<String, int> equipmentImpact = {};
    for (final ex in exercises) {
      ex.equipmentShotImpact.forEach((equipmentId, shots) {
        equipmentImpact[equipmentId] =
            (equipmentImpact[equipmentId] ?? 0) + shots;
      });
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.sessionSummaryTotalShots(totalShots),
            style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(AppSpacing.md),

          // Platforms impact
          if (platformImpact.isNotEmpty) ...[
            Text(
              strings.platformsUsedLabel,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            ...platformImpact.entries.map((e) {
              final platform = provider.getPlatformById(e.key);
              if (platform == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${platform.name}: ${e.value} coups',
                  style: textStyles.bodySmall,
                ),
              );
            }),
            const Gap(AppSpacing.md),
          ],

          // Ammo impact
          if (ammoImpact.isNotEmpty) ...[
            Text(
              strings.consumablesUsedLabel,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            ...ammoImpact.entries.map((e) {
              final ammo = provider.getAmmoById(e.key);
              if (ammo == null) return const SizedBox.shrink();
              final remaining = (ammo.quantity - e.value)
                  .clamp(0, 1 << 30)
                  .toInt();
              final lineCost = ammo.unitPrice != null
                  ? (e.value * ammo.unitPrice!).toStringAsFixed(2)
                  : null;
              final currencySymbol = _getCurrencySymbol(ammo.currency);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  lineCost == null
                      ? strings.sessionSummaryAmmoImpactLine(
                          ammo.name,
                          e.value,
                          remaining,
                        )
                      : strings.sessionSummaryAmmoImpactLineWithCost(
                          ammo.name,
                          e.value,
                          remaining,
                          lineCost,
                          currencySymbol,
                        ),
                  style: textStyles.bodySmall,
                ),
              );
            }),
            const Gap(AppSpacing.md),
          ],

          // Equipment impact
          if (equipmentImpact.isNotEmpty) ...[
            Text(
              strings.sessionSummaryAccessoriesImpactTitle,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            ...equipmentImpact.entries.map((e) {
              final accessory = provider.accessories
                  .where((a) => a.id == e.key)
                  .firstOrNull;
              if (accessory == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  strings.sessionSummaryAccessoryImpactLine(
                    accessory.name,
                    e.value,
                  ),
                  style: textStyles.bodySmall,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ExerciseForm extends StatefulWidget {
  final Exercise? exercise;
  final Function(Exercise) onSave;
  final ScrollController? scrollController;

  const _ExerciseForm({
    this.exercise,
    required this.onSave,
    this.scrollController,
  });

  @override
  State<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<_ExerciseForm> {
  final _exerciseNameController = TextEditingController();
  final _exerciseScrollController = ScrollController();
  final _platformFieldKey = GlobalKey();
  final _ammoFieldKey = GlobalKey();
  final _shotsFieldKey = GlobalKey();
  final _distanceFieldKey = GlobalKey();

  bool _detailedMode = false;
  final List<ExerciseStep> _steps = [];

  bool _platformError = false;
  bool _ammoError = false;
  bool _shotsError = false;
  bool _distanceError = false;

  String _platformSource = 'inventory'; // inventory | borrowed
  String _ammoSource = 'inventory'; // inventory | borrowed
  String? _selectedPlatformId;
  String? _selectedAmmoId;
  final _borrowedPlatformController = TextEditingController();
  final _borrowedAmmoController = TextEditingController();
  final Set<String> _selectedEquipmentIds = {};
  final Set<String> _removedLinkedAccessoryIds = {};
  final _targetNameController = TextEditingController();
  final List<ExercisePhoto> _targetPhotos = [];
  final _shotsFiredController = TextEditingController();
  final _distanceController = TextEditingController();
  final _observationsController = TextEditingController();
  bool _measurePrecision = false;
  double _precision = 0;
  bool _precisionEnabled = true;
  bool _defaultsInitialized = false;
  final Map<String, TextEditingController> _photoControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _exerciseNameController.text = widget.exercise!.name;

      final platformId = widget.exercise!.platformId;
      if (platformId == 'borrowed' || platformId == 'none') {
        _platformSource = 'borrowed';
        _selectedPlatformId = null;
        _borrowedPlatformController.text = widget.exercise!.platformLabel ?? '';
      } else {
        _platformSource = 'inventory';
        _selectedPlatformId = platformId;
      }

      final ammoId = widget.exercise!.ammoId;
      if (ammoId == 'borrowed' || ammoId == 'none') {
        _ammoSource = 'borrowed';
        _selectedAmmoId = null;
        _borrowedAmmoController.text = widget.exercise!.ammoLabel ?? '';
      } else {
        _ammoSource = 'inventory';
        _selectedAmmoId = ammoId;
      }

      _selectedEquipmentIds
        ..clear()
        ..addAll(widget.exercise!.equipmentIds);

      // Si on est en mode édition avec une plateforme sélectionnée et aucun équipement personnalisé,
      // ajouter automatiquement les accessoires liés
      if (_platformSource == 'inventory' &&
          _selectedPlatformId != null &&
          widget.exercise!.equipmentIds.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final provider = Provider.of<ThotProvider>(context, listen: false);
            _updateEquipmentForPlatform(provider);
          }
        });
      }
      _targetNameController.text = widget.exercise!.targetName ?? '';
      _targetPhotos
        ..clear()
        ..addAll(widget.exercise!.targetPhotos);
      for (var photo in _targetPhotos) {
        _photoControllers[photo.id] = TextEditingController(text: photo.name);
      }
      _shotsFiredController.text = widget.exercise!.shotsFired.toString();
      _distanceController.text = widget.exercise!.distance.toString();
      _observationsController.text = widget.exercise!.observations;
      _measurePrecision = widget.exercise!.precision != null;
      _precision = widget.exercise!.precision ?? 0;
      _precisionEnabled = widget.exercise!.precisionEnabled;

      _detailedMode = widget.exercise!.steps != null;
      _steps
        ..clear()
        ..addAll(widget.exercise!.steps ?? const []);
    } else {
      // Les deux champs démarrent vides
    }
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

  Set<String> _getLinkedAccessoryIds(ThotProvider provider) {
    if (_platformSource != 'inventory' || _selectedPlatformId == null) {
      return const {};
    }
    final platform = provider.getPlatformById(_selectedPlatformId!);
    if (platform == null) return const {};
    return provider
        .linkedAccessoriesForPlatform(platform.id)
        .map((a) => a.id)
        .toSet();
  }

  void _updateEquipmentForPlatform(ThotProvider provider) {
    if (_platformSource != 'inventory' || _selectedPlatformId == null) {
      return;
    }

    final platform = provider.getPlatformById(_selectedPlatformId!);
    if (platform == null) return;

    // Récupérer les accessoires liés à cette plateforme
    final linkedAccessories = provider.linkedAccessoriesForPlatform(
      platform.id,
    );

    // Réinitialiser les suppressions de liaison quand on change de plateforme
    _removedLinkedAccessoryIds.clear();

    // Ajouter les accessoires liés à la sélection existante
    setState(() {
      _selectedEquipmentIds.clear();
      _selectedEquipmentIds.addAll(linkedAccessories.map((a) => a.id));
    });
  }

  List<Platform> _availablePlatformsForStep(ThotProvider provider) {
    if (_platformSource != 'inventory' || _selectedPlatformId == null) {
      return const [];
    }
    final selected = provider.getPlatformById(_selectedPlatformId!);
    if (selected == null) return const [];
    return [selected];
  }

  List<Ammo> _availableAmmosForStep(ThotProvider provider) {
    if (_ammoSource != 'inventory' || _selectedAmmoId == null) {
      return const [];
    }
    final selected = provider.getAmmoById(_selectedAmmoId!);
    if (selected == null) return const [];
    return [selected];
  }

  String _stepTitle(StepType type) {
    return AppStrings.of(context).exerciseStepTypeLabel(type);
  }

  String _positionShort(ShootingPosition? pos) {
    if (pos == null) return '';
    final strings = AppStrings.of(context);
    return strings.exercisePositionLabel(pos);
  }

  String _stepSummary(ExerciseStep s, AppStrings strings, bool useMetric) {
    final parts = <String>[];
    final provider = Provider.of<ThotProvider>(context, listen: false);
    if (s.type == StepType.tir && s.shots != null) {
      parts.add('${s.shots} ${strings.exerciseNarrativeShotsWord}');
      final usedPlatformId = (s.usedPlatformId ?? '').trim();
      if (usedPlatformId.isNotEmpty) {
        final platformName = usedPlatformId.startsWith('custom:')
            ? usedPlatformId.substring('custom:'.length).trim()
            : provider.getPlatformById(usedPlatformId)?.name;
        if (platformName != null && platformName.trim().isNotEmpty) {
          parts.add(platformName);
        }
      }
      final usedAmmoId = (s.usedAmmoId ?? '').trim();
      if (usedAmmoId.isNotEmpty) {
        final ammoName = usedAmmoId.startsWith('custom:')
            ? usedAmmoId.substring('custom:'.length).trim()
            : provider.getAmmoById(usedAmmoId)?.name;
        if (ammoName != null && ammoName.trim().isNotEmpty) {
          parts.add(ammoName);
        }
      }
    }
    if (s.distanceM != null) {
      final dist = useMetric
          ? '${s.distanceM} m'
          : '${(s.distanceM! * 1.09361).round()} yd';
      parts.add(dist);
    }
    if ((s.target ?? '').trim().isNotEmpty) parts.add(s.target!.trim());
    if (s.type == StepType.transition) {
      if ((s.platformFrom ?? '').trim().isNotEmpty) {
        parts.add(
          '${strings.exerciseNarrativeFrom.trim()} ${s.platformFrom!.trim()}',
        );
      }
      if ((s.platformTo ?? '').trim().isNotEmpty) {
        parts.add(
          '${strings.exerciseNarrativeTo.trim()} ${s.platformTo!.trim()}',
        );
      }
    }
    if (s.type == StepType.rechargement && s.reloadType != null) {
      parts.add(strings.exerciseReloadTypeNarrative(s.reloadType!));
    }
    if (s.type == StepType.attente && s.durationSeconds != null) {
      parts.add('${s.durationSeconds}s');
    }
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_defaultsInitialized) return;
    _defaultsInitialized = true;

    // Ensure we always land in a valid state (no more "none").
    final provider = Provider.of<ThotProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (_platformSource == 'inventory') {
          final exists =
              _selectedPlatformId != null &&
              provider.platforms.any((w) => w.id == _selectedPlatformId);
          final allowed = _selectedPlatformId != null
              ? provider.canUsePlatformId(_selectedPlatformId!)
              : true;
          if (!exists || !allowed) {
            _selectedPlatformId = provider.platforms.isNotEmpty
                ? provider.platforms.first.id
                : null;
            if (provider.platforms.isEmpty) _platformSource = 'borrowed';
          }
        }

        if (_ammoSource == 'inventory') {
          final exists =
              _selectedAmmoId != null &&
              provider.ammos.any((a) => a.id == _selectedAmmoId);
          final allowed = _selectedAmmoId != null
              ? provider.canUseAmmoId(_selectedAmmoId!)
              : true;
          if (!exists || !allowed) {
            _selectedAmmoId = provider.ammos.isNotEmpty
                ? provider.ammos.first.id
                : null;
            if (provider.ammos.isEmpty) _ammoSource = 'borrowed';
          }
        }
      });

      // Auto-ajouter les accessoires liés quand la plateforme est pré-sélectionnée
      if (_platformSource == 'inventory' &&
          _selectedPlatformId != null &&
          _selectedEquipmentIds.isEmpty) {
        _updateEquipmentForPlatform(provider);
      }
    });
  }

  Future<void> _editEquipments(ThotProvider provider) async {
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EquipmentMultiSelectSheet(
        accessories: provider.accessories,
        initialSelection: _selectedEquipmentIds,
      ),
    );

    if (!mounted || updated == null) return;
    setState(() {
      _selectedEquipmentIds
        ..clear()
        ..addAll(updated);
    });
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _borrowedPlatformController.dispose();
    _borrowedAmmoController.dispose();
    _targetNameController.dispose();
    _shotsFiredController.dispose();
    _distanceController.dispose();
    _observationsController.dispose();
    for (var c in _photoControllers.values) {
      c.dispose();
    }
    _exerciseScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetPhoto() async {
    final picked = await NativePicker.pick(context, mode: PickerMode.photoOnly);
    if (!mounted || picked.isCancelled) return;

    String? path;
    if (kIsWeb) {
      if (picked.bytes == null) return;
      final ext = (picked.name ?? 'jpg').split('.').last;
      path = 'data:image/$ext;base64,${base64Encode(picked.bytes!)}';
    } else {
      path = picked.path;
    }
    if (path == null || path.isEmpty) return;

    final id =
        DateTime.now().microsecondsSinceEpoch.toString() +
        (picked.name ?? 'img');
    final photo = ExercisePhoto(
      id: id,
      name: picked.name ?? 'photo',
      path: path,
    );

    _photoControllers[photo.id] = TextEditingController(text: photo.name);

    setState(() {
      _targetPhotos.add(photo);
    });
  }

  void _renameTargetPhoto(String id, String newName) {
    final index = _targetPhotos.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _targetPhotos[index] = _targetPhotos[index].copyWith(name: newName);
  }

  void _removeTargetPhoto(String id) {
    setState(() {
      _targetPhotos.removeWhere((p) => p.id == id);
      _photoControllers[id]?.dispose();
      _photoControllers.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final converter = UnitConverter(provider.useMetric);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      strings.addExerciseTitle.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  // Icône en forme de V pour fermer
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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

            Expanded(
              child: SingleChildScrollView(
                controller:
                    widget.scrollController ?? _exerciseScrollController,
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(AppSpacing.lg),

                    Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.exerciseNameLabel.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),

                    TextField(
                      controller: _exerciseNameController,
                      textInputAction: TextInputAction.next,
                      onTap: () =>
                          _exerciseNameController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _exerciseNameController.text.length,
                          ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'.*')),
                      ],
                      decoration: InputDecoration(
                        hintText: strings.exerciseNameHint,
                        hintStyle: textStyles.bodyMedium?.copyWith(
                          color: colors.onSurface.withAlpha(100),
                        ),
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
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.lg),

                    // Platform Section
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/tube.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            colors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          strings.platformTitle.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SourceToggleRow(
                            leftLabel: strings.myInventory,
                            rightLabel: strings.borrowed,
                            value: _platformSource,
                            onChanged: (v) => setState(() {
                              _platformSource = v;
                              if (_platformSource == 'borrowed') {
                                _selectedPlatformId = null;
                                // Vider les équipements quand on passe en mode emprunté
                                _selectedEquipmentIds.clear();
                              }
                              if (_platformSource != 'borrowed') {
                                _borrowedPlatformController.text = '';
                              }
                            }),
                          ),
                          const Gap(10),
                          Container(
                            key: _platformFieldKey,
                            child: _platformSource == 'inventory'
                                ? (provider.platforms.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 18,
                                                color: colors.secondary,
                                              ),
                                              const Gap(8),
                                              Expanded(
                                                child: Text(
                                                  strings.noPlatformInStock,
                                                  style: textStyles.bodySmall
                                                      ?.copyWith(
                                                        color: colors.secondary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _SelectedSingleItemField(
                                          leading: _selectedPlatformId == null
                                              ? SvgPicture.asset(
                                                  'assets/images/tube.svg',
                                                  width: 18,
                                                  height: 18,
                                                  colorFilter: ColorFilter.mode(
                                                    colors.primary,
                                                    BlendMode.srcIn,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons
                                                      .radio_button_checked_rounded,
                                                  size: 18,
                                                  color: colors.primary,
                                                ),
                                          titleWhenEmpty: strings
                                              .choosePlatformFromInventory,
                                          titleWhenSet:
                                              (_selectedPlatformId == null
                                                      ? null
                                                      : provider.getPlatformById(
                                                          _selectedPlatformId!,
                                                        ))
                                                  ?.name ??
                                              strings
                                                  .choosePlatformFromInventory,
                                          subtitle:
                                              (_selectedPlatformId == null
                                                      ? null
                                                      : provider.getPlatformById(
                                                          _selectedPlatformId!,
                                                        )) ==
                                                  null
                                              ? null
                                              : strings.tapToChange,
                                          onTap: () async {
                                            if (provider.platforms.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    strings
                                                        .noPlatformInStockSwitchBorrowed,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final selected = await showModalBottomSheet<String>(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  _SingleSelectSheet<Platform>(
                                                    title: strings.platformsTab,
                                                    items: provider.platforms,
                                                    initialId:
                                                        _selectedPlatformId,
                                                    isLockedItem: (w) {
                                                      final idx = provider
                                                          .platforms
                                                          .indexOf(w);
                                                      return idx >= 0
                                                          ? provider
                                                                .isPlatformLockedForFree(
                                                                  w,
                                                                  idx,
                                                                )
                                                          : false;
                                                    },
                                                    iconBuilder:
                                                        (
                                                          selected,
                                                          colors,
                                                        ) => SvgPicture.asset(
                                                          'assets/images/tube.svg',
                                                          width: 20,
                                                          height: 20,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                selected
                                                                    ? colors
                                                                          .primary
                                                                    : colors
                                                                          .outline,
                                                                BlendMode.srcIn,
                                                              ),
                                                        ),
                                                    primaryText: (w) => w.name,
                                                    secondaryText: (w) => [
                                                      strings
                                                          .itemPlatformTypeLabel(
                                                            w.type,
                                                          ),
                                                      if (w.model
                                                          .trim()
                                                          .isNotEmpty)
                                                        w.model,
                                                      if (w.caliber
                                                          .trim()
                                                          .isNotEmpty)
                                                        w.caliber,
                                                    ].join(' • '),
                                                    matchesQuery: (w, q) {
                                                      final qq = q
                                                          .toLowerCase();
                                                      return w.name
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.type
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.model
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.caliber
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.serialNumber
                                                              .toLowerCase()
                                                              .contains(qq);
                                                    },
                                                    getId: (w) => w.id,
                                                  ),
                                            );
                                            if (!mounted || selected == null)
                                              return;
                                            setState(() {
                                              _selectedPlatformId = selected;
                                              _platformError = false;
                                            });
                                            // Auto-ajouter les accessoires liés à la plateforme
                                            _updateEquipmentForPlatform(
                                              provider,
                                            );
                                          },
                                        ))
                                : TextField(
                                    controller: _borrowedPlatformController,
                                    textInputAction: TextInputAction.next,
                                    onTap: () =>
                                        _borrowedPlatformController.selection =
                                            TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  _borrowedPlatformController
                                                      .text
                                                      .length,
                                            ),
                                    decoration: InputDecoration(
                                      labelText:
                                          strings.borrowedPlatformOptional,
                                      hintText: strings.borrowedPlatformHint,
                                      hintStyle: textStyles.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurface.withAlpha(
                                              100,
                                            ),
                                          ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.radio_button_checked_rounded,
                                          size: 18,
                                        ),
                                      ),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                            minWidth: 44,
                                            minHeight: 44,
                                          ),
                                      filled: true,
                                      fillColor: colors.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.lg,
                                        ),
                                        borderSide: BorderSide(
                                          color: colors.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.lg,
                                        ),
                                        borderSide: BorderSide(
                                          color: colors.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.lg,
                                        ),
                                        borderSide: BorderSide(
                                          color: colors.primary,
                                          width: 1.6,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.lg),

                    // Équipement utilisé
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.usedEquipmentLabel.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SelectedEquipmentField(
                            accessories: provider.accessories,
                            selectedIds: _selectedEquipmentIds,
                            linkedIds: _getLinkedAccessoryIds(
                              provider,
                            ).difference(_removedLinkedAccessoryIds),
                            onTap: () => _editEquipments(provider),
                            onRemove: (id) => setState(
                              () => _selectedEquipmentIds.remove(id),
                            ),
                            onUnlinkForSession: (id) async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(strings.confirmDeleteTitle),
                                  content: Text(
                                    strings.unlinkAccessoryForSessionMessage,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text(strings.actionCancel),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colors.error,
                                      ),
                                      child: Text(strings.actionDelete),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true || !mounted) return;
                              setState(() {
                                _removedLinkedAccessoryIds.add(id);
                                _selectedEquipmentIds.remove(id);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.lg),

                    // Consommable Section
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/pointe.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            colors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          strings.ammoTitle.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SourceToggleRow(
                            leftLabel: strings.myInventory,
                            rightLabel: strings.borrowed,
                            value: _ammoSource,
                            onChanged: (v) => setState(() {
                              _ammoSource = v;
                              if (_ammoSource == 'borrowed')
                                _selectedAmmoId = null;
                              if (_ammoSource != 'borrowed')
                                _borrowedAmmoController.text = '';
                            }),
                          ),
                          const Gap(10),
                          Container(
                            key: _ammoFieldKey,
                            child: _ammoSource == 'inventory'
                                ? (provider.ammos.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 18,
                                                color: colors.secondary,
                                              ),
                                              const Gap(8),
                                              Expanded(
                                                child: Text(
                                                  strings.noAmmoInStock,
                                                  style: textStyles.bodySmall
                                                      ?.copyWith(
                                                        color: colors.secondary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _SelectedSingleItemField(
                                          leading: Icon(
                                            Icons.radio_button_checked_rounded,
                                            size: 18,
                                            color: colors.primary,
                                          ),
                                          titleWhenEmpty:
                                              strings.chooseAmmoFromInventory,
                                          titleWhenSet:
                                              (_selectedAmmoId == null
                                                      ? null
                                                      : provider.getAmmoById(
                                                          _selectedAmmoId!,
                                                        ))
                                                  ?.name ??
                                              strings.chooseAmmoFromInventory,
                                          subtitle:
                                              (_selectedAmmoId == null
                                                      ? null
                                                      : provider.getAmmoById(
                                                          _selectedAmmoId!,
                                                        )) ==
                                                  null
                                              ? null
                                              : strings.tapToChange,
                                          onTap: () async {
                                            if (provider.ammos.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    strings
                                                        .noAmmoInStockSwitchBorrowed,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final selected =
                                                await showModalBottomSheet<
                                                  String
                                                >(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      _SingleSelectSheet<Ammo>(
                                                        title: strings.ammosTab,
                                                        items: provider.ammos,
                                                        initialId:
                                                            _selectedAmmoId,
                                                        isLockedItem: (a) {
                                                          final idx = provider
                                                              .ammos
                                                              .indexOf(a);
                                                          return idx >= 0
                                                              ? provider
                                                                    .isAmmoLockedForFree(
                                                                      a,
                                                                      idx,
                                                                    )
                                                              : false;
                                                        },
                                                        icon: Icons
                                                            .trip_origin_rounded,
                                                        primaryText: (a) =>
                                                            a.name,
                                                        secondaryText: (a) => [
                                                          a.caliber,
                                                          if (a.brand
                                                              .trim()
                                                              .isNotEmpty)
                                                            a.brand,
                                                          if (a.projectileType
                                                              .trim()
                                                              .isNotEmpty)
                                                            strings.itemProjectileTypeLabel(
                                                              a.projectileType,
                                                            ),
                                                        ].join(' • '),
                                                        matchesQuery: (a, q) {
                                                          final qq = q
                                                              .toLowerCase();
                                                          return a.name
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    qq,
                                                                  ) ||
                                                              a.caliber
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    qq,
                                                                  ) ||
                                                              a.brand
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    qq,
                                                                  ) ||
                                                              a.projectileType
                                                                  .toLowerCase()
                                                                  .contains(qq);
                                                        },
                                                        getId: (a) => a.id,
                                                      ),
                                                );

                                            if (!mounted || selected == null)
                                              return;
                                            setState(() {
                                              _selectedAmmoId = selected;
                                              _ammoError = false;
                                            });
                                          },
                                        ))
                                : TextField(
                                    controller: _borrowedAmmoController,
                                    textInputAction: TextInputAction.next,
                                    onTap: () =>
                                        _borrowedAmmoController
                                            .selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: _borrowedAmmoController
                                              .text
                                              .length,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: strings.borrowedAmmoOptional,
                                      hintText: strings.borrowedAmmoHint,
                                      hintStyle: textStyles.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurface.withAlpha(
                                              100,
                                            ),
                                          ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.radio_button_checked_rounded,
                                          size: 18,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: colors.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.lg,
                                        ),
                                        borderSide: BorderSide(
                                          color: colors.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.lg,
                                        ),
                                        borderSide: BorderSide(
                                          color: colors.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.lg,
                                        ),
                                        borderSide: BorderSide(
                                          color: colors.primary,
                                          width: 1.6,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.lg),

                    // DÉROULÉ Section
                    Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.exerciseModeLabel.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        children: [
                          _SlidingSegmentedSelector(
                            selectedIndex: _detailedMode ? 1 : 0,
                            labels: [
                              strings.exerciseModeSimple,
                              strings.exerciseModeDetailed,
                            ],
                            onSelected: (index) {
                              setState(() {
                                _detailedMode = index == 1;
                              });
                            },
                          ),
                          if (!_detailedMode) ...[
                            const Gap(AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/hit.svg',
                                            width: 14,
                                            height: 14,
                                            colorFilter: ColorFilter.mode(
                                              colors.primary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const Gap(6),
                                          Text(
                                            strings.shotsCountLabel
                                                .toUpperCase(),
                                            style: textStyles.labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: colors.onSurface,
                                                  letterSpacing: 1.1,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Gap(6),
                                      Container(
                                        key: _shotsFieldKey,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          border: Border.all(
                                            color: _shotsError
                                                ? colors.error
                                                : Colors.transparent,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _shotsFiredController,
                                          keyboardType: TextInputType.number,
                                          style: textStyles.titleMedium,
                                          onTap: () =>
                                              _shotsFiredController.selection =
                                                  TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        _shotsFiredController
                                                            .text
                                                            .length,
                                                  ),
                                          onChanged: (_) {
                                            final shots = int.tryParse(
                                              _shotsFiredController.text.trim(),
                                            );
                                            if (_shotsError &&
                                                shots != null &&
                                                shots > 0) {
                                              setState(
                                                () => _shotsError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.onSurface
                                                      .withAlpha(100),
                                                ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            filled: true,
                                            fillColor: Color.alphaBlend(
                                              colors.onSurface.withValues(
                                                alpha: 0.03,
                                              ),
                                              colors.surface,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.primary,
                                                width: 1.6,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.straighten_rounded,
                                            size: 14,
                                            color: colors.primary,
                                          ),
                                          const Gap(6),
                                          Text(
                                            strings.distanceLabel.toUpperCase(),
                                            style: textStyles.labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: colors.onSurface,
                                                  letterSpacing: 1.1,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Gap(6),
                                      Container(
                                        key: _distanceFieldKey,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          border: Border.all(
                                            color: _distanceError
                                                ? colors.error
                                                : Colors.transparent,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _distanceController,
                                          keyboardType: TextInputType.number,
                                          style: textStyles.titleMedium,
                                          onTap: () =>
                                              _distanceController.selection =
                                                  TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        _distanceController
                                                            .text
                                                            .length,
                                                  ),
                                          onChanged: (_) {
                                            final distance = int.tryParse(
                                              _distanceController.text.trim(),
                                            );
                                            if (_distanceError &&
                                                distance != null &&
                                                distance > 0) {
                                              setState(
                                                () => _distanceError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.onSurface
                                                      .withAlpha(100),
                                                ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            suffixText: converter.useMetric
                                                ? 'm'
                                                : 'yd',
                                            filled: true,
                                            fillColor: Color.alphaBlend(
                                              colors.onSurface.withValues(
                                                alpha: 0.03,
                                              ),
                                              colors.surface,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.primary,
                                                width: 1.6,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_shotsError || _distanceError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _shotsError
                                      ? strings.shotsFiredError
                                      : strings.distanceError,
                                  style: textStyles.bodySmall?.copyWith(
                                    color: colors.error,
                                  ),
                                ),
                              ),
                          ] else ...[
                            const Gap(AppSpacing.md),
                            // Badge Total
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Color.alphaBlend(
                                  colors.primary.withValues(alpha: 0.1),
                                  colors.surface,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      strings.exerciseAutoBadge,
                                      style: textStyles.labelSmall?.copyWith(
                                        color: colors.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Text(
                                      strings.exerciseAutoTotals(
                                        _computedTotalShots(),
                                        _steps.length,
                                        _computedMaxDistance(),
                                        converter.useMetric ? 'm' : 'yd',
                                      ),
                                      style: textStyles.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            // Header Steps
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  strings.exerciseStepsTitle.toUpperCase(),
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colors.onSurface,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final availablePlatforms =
                                        _availablePlatformsForStep(provider);
                                    final availableAmmos =
                                        _availableAmmosForStep(provider);
                                    final step =
                                        await showModalBottomSheet<
                                          ExerciseStep
                                        >(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => _AddExerciseStepSheet(
                                            availablePlatforms:
                                                availablePlatforms,
                                            availableAmmos: availableAmmos,
                                            defaultPlatformId:
                                                _platformSource == 'inventory'
                                                ? _selectedPlatformId
                                                : null,
                                            defaultAmmoId:
                                                _ammoSource == 'inventory'
                                                ? _selectedAmmoId
                                                : null,
                                          ),
                                        );
                                    if (!mounted || step == null) return;
                                    setState(() => _steps.add(step));
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 14),
                                  label: Text(
                                    strings.exerciseAddStep,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.sm),
                            if (_steps.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color.alphaBlend(
                                    colors.onSurface.withValues(alpha: 0.03),
                                    colors.surface,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  border: Border.all(color: colors.outline),
                                ),
                                child: Text(
                                  strings.exerciseNoSteps,
                                  style: textStyles.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                buildDefaultDragHandles: false,
                                itemCount: _steps.length,
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final item = _steps.removeAt(oldIndex);
                                    _steps.insert(newIndex, item);
                                  });
                                },
                                itemBuilder: (context, i) {
                                  final s = _steps[i];
                                  return Container(
                                    key: ValueKey(s.id),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      8,
                                      2,
                                      8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.alphaBlend(
                                        colors.onSurface.withValues(
                                          alpha: 0.03,
                                        ),
                                        colors.surface,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                      border: Border.all(
                                        color: colors.outline.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          (i + 1).toString().padLeft(2, '0'),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const Gap(10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _stepTitle(s.type),
                                                style: textStyles.labelLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 13,
                                                    ),
                                              ),
                                              Text(
                                                '${_positionShort(s.position)}${_positionShort(s.position).isEmpty ? '' : ' · '}${_stepSummary(s, strings, provider.useMetric)}',
                                                style: textStyles.bodySmall
                                                    ?.copyWith(
                                                      color: colors.secondary,
                                                      fontSize: 11,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(2),
                                        ReorderableDragStartListener(
                                          index: i,
                                          child: Icon(
                                            Icons.drag_indicator_rounded,
                                            size: 20,
                                            color: colors.onSurface,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_rounded,
                                            size: 18,
                                          ),
                                          onPressed: () => setState(
                                            () => _steps.removeAt(i),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          splashRadius: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ],
                      ),
                    ),

                    const Gap(AppSpacing.lg),

                    // Cible utilisée
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.usedTargetLabel.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    TextField(
                      controller: _targetNameController,
                      onTap: () =>
                          _targetNameController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _targetNameController.text.length,
                          ),
                      decoration: InputDecoration(
                        hintText: strings.targetNameHint,
                        hintStyle: textStyles.bodyMedium?.copyWith(
                          color: colors.onSurface.withAlpha(100),
                        ),
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
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.lg),

                    // Photo de la cible
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.photo_camera_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.targetPhotosTitle.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: _pickTargetPhoto,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(strings.addButton),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_targetPhotos.isEmpty) ...[
                              InkWell(
                                onTap: _pickTargetPhoto,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_rounded,
                                        color: colors.outline,
                                        size: 40,
                                      ),
                                      const Gap(8),
                                      Text(
                                        strings.targetPhotosHint,
                                        style: textStyles.bodySmall?.copyWith(
                                          color: colors.outline,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Gap(8),

                              ..._targetPhotos.map(
                                (photo) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      border: Border.all(color: colors.outline),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _photoControllers[photo.id],
                                                onChanged: (value) =>
                                                    setState(() {
                                                      _renameTargetPhoto(
                                                        photo.id,
                                                        value,
                                                      );
                                                    }),
                                                decoration: InputDecoration(
                                                  labelText: strings
                                                      .targetPhotoNameLabel,
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: colors.surface,
                                                  suffixIcon:
                                                      (_photoControllers[photo
                                                                  .id]
                                                              ?.text
                                                              .trim()
                                                              .isNotEmpty ??
                                                          false)
                                                      ? IconButton(
                                                          icon: const Icon(
                                                            Icons.clear_rounded,
                                                            size: 18,
                                                          ),
                                                          splashRadius: 18,
                                                          tooltip:
                                                              strings.clear,
                                                          onPressed: () {
                                                            final c =
                                                                _photoControllers[photo
                                                                    .id];
                                                            if (c == null)
                                                              return;
                                                            c.clear();
                                                            _renameTargetPhoto(
                                                              photo.id,
                                                              '',
                                                            );
                                                            setState(() {});
                                                          },
                                                        )
                                                      : null,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppRadius.sm,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: colors.outline,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppRadius.sm,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: colors.outline,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppRadius.sm,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: colors.primary,
                                                          width: 1.6,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const Gap(8),
                                            IconButton(
                                              onPressed: () =>
                                                  _removeTargetPhoto(photo.id),
                                              icon: Icon(Icons.delete_rounded),
                                              tooltip: strings.removePhoto,
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                            ),
                                          ],
                                        ),
                                        const Gap(8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 16 / 10,
                                            child: CrossPlatformImage(
                                              filePath: photo.path,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Gap(AppSpacing.lg),

                    // Mesurer la précision
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.measurePrecisionTitle.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _measurePrecision,
                          onChanged: (val) =>
                              setState(() => _measurePrecision = val),
                        ),
                      ],
                    ),
                    if (_measurePrecision) ...[
                      const Gap(AppSpacing.sm),
                      Slider(
                        value: _precision,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: "${_precision.toStringAsFixed(0)}%",
                        onChanged: (val) => setState(() => _precision = val),
                      ),
                      Text(
                        strings.precisionValueLabel(
                          '${_precision.toStringAsFixed(0)}%',
                        ),
                        textAlign: TextAlign.center,
                        style: textStyles.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const Gap(AppSpacing.lg),

                    // Observations
                    Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.observationsTitle.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    TextField(
                      controller: _observationsController,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.top,
                      onTap: () =>
                          _observationsController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _observationsController.text.length,
                          ),
                      decoration: InputDecoration(
                        hintText: strings.observationsExample,
                        hintStyle: textStyles.bodyMedium?.copyWith(
                          color: colors.onSurface.withAlpha(100),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
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
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.lg),

                    // Save buttons row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: FilledButton(
                                onPressed: _save,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                ),
                                child: Text(strings.saveExerciseButton),
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _saveAsTemplate,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              side: BorderSide(
                                color: colors.primary,
                                width: 1.6,
                              ),
                            ),
                            child: Icon(
                              Icons.bookmark_add_outlined,
                              size: 22,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.lg),
                    const Gap(AppSpacing.sm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAsTemplate() {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.templateNameDialogTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: strings.templateNameHint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final shots = _detailedMode
                  ? _computedTotalShots()
                  : (int.tryParse(_shotsFiredController.text.trim()) ?? 0);
              final distance = _detailedMode
                  ? _computedMaxDistance()
                  : (int.tryParse(_distanceController.text.trim()) ?? 0);
              final template = ExerciseTemplate(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name,
                createdAt: DateTime.now(),
                shotsFired: shots,
                distance: distance,
                detailedMode: _detailedMode,
                steps: _detailedMode ? List<ExerciseStep>.from(_steps) : null,
                observations: _observationsController.text.trim(),
              );
              Provider.of<ThotProvider>(
                context,
                listen: false,
              ).saveExerciseTemplate(template);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.templateSavedSnack),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text(strings.validate),
          ),
        ],
      ),
    );
  }

  void _save() async {
    final shots = int.tryParse(_shotsFiredController.text.trim());
    final distance = int.tryParse(_distanceController.text.trim());

    final computedShots = _detailedMode ? _computedTotalShots() : (shots ?? 0);
    final computedDistance = _detailedMode
        ? _computedMaxDistance()
        : (distance ?? 0);
    final hasTirStep =
        _detailedMode &&
        _steps.any((s) => s.type == StepType.tir && (s.shots ?? 0) > 0);
    final needsGlobalPlatform =
        !_detailedMode ||
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              (s.usedPlatformId ?? '').trim().isEmpty,
        );
    final needsGlobalAmmo =
        !_detailedMode ||
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              (s.usedAmmoId ?? '').trim().isEmpty,
        );
    final hasUnattributedTirStep =
        _detailedMode &&
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              ((s.usedPlatformId ?? '').trim().isEmpty &&
                      _platformSource == 'inventory' &&
                      _selectedPlatformId == null ||
                  (s.usedAmmoId ?? '').trim().isEmpty &&
                      _ammoSource == 'inventory' &&
                      _selectedAmmoId == null),
        );

    setState(() {
      _platformError =
          needsGlobalPlatform &&
          _platformSource == 'inventory' &&
          _selectedPlatformId == null;
      _ammoError =
          needsGlobalAmmo &&
          _ammoSource == 'inventory' &&
          _selectedAmmoId == null;
      _shotsError = _detailedMode
          ? (hasTirStep && computedShots <= 0)
          : (shots == null || shots <= 0);
      _distanceError = _detailedMode
          ? (_steps.isEmpty || (hasTirStep && computedDistance <= 0))
          : (distance == null || distance <= 0);
    });

    if (_platformError) {
      await Scrollable.ensureVisible(
        _platformFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_ammoError) {
      await Scrollable.ensureVisible(
        _ammoFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_shotsError) {
      await Scrollable.ensureVisible(
        _shotsFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_distanceError) {
      await Scrollable.ensureVisible(
        _distanceFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (hasUnattributedTirStep) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).stepPlatformAmmoRequired),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final effectivePlatformId = _platformSource == 'borrowed'
        ? 'borrowed'
        : (_selectedPlatformId ?? 'none');

    final effectiveAmmoId = _ammoSource == 'borrowed'
        ? 'borrowed'
        : (_selectedAmmoId ?? 'none');

    final effectiveSteps = _detailedMode
        ? List<ExerciseStep>.from(_steps)
        : null;
    final provider = Provider.of<ThotProvider>(context, listen: false);

    final effectivePlatformAssignments = <ExercisePlatformAssignment>[];
    final effectiveShotAllocations = <ExerciseShotAllocation>[];

    if (effectivePlatformId != 'borrowed' &&
        effectivePlatformId != 'none' &&
        effectivePlatformId.trim().isNotEmpty) {
      final linkedAccessoryIds = provider
          .linkedAccessoriesForPlatform(effectivePlatformId)
          .map((a) => a.id)
          .toSet();
      final effectiveAccessoryIds = {
        ...linkedAccessoryIds,
        ..._selectedEquipmentIds,
      };
      effectiveAccessoryIds.removeAll(_removedLinkedAccessoryIds);

      effectivePlatformAssignments.add(
        ExercisePlatformAssignment(
          platformId: effectivePlatformId,
          platformLabel: _platformSource == 'borrowed'
              ? _borrowedPlatformController.text.trim()
              : null,
          ammoIds: [
            if (effectiveAmmoId.trim().isNotEmpty &&
                effectiveAmmoId != 'none' &&
                effectiveAmmoId != 'borrowed')
              effectiveAmmoId,
          ],
          accessoryIds: effectiveAccessoryIds.toList(growable: false),
        ),
      );
    }

    if (effectiveSteps != null) {
      for (final step in effectiveSteps) {
        if (step.type != StepType.tir) continue;
        final stepShots = step.shots ?? 0;
        if (stepShots <= 0) continue;
        final usedPlatformId = (step.usedPlatformId ?? effectivePlatformId)
            .trim();
        final usedAmmoId = (step.usedAmmoId ?? effectiveAmmoId).trim();
        if (usedPlatformId.isEmpty ||
            usedPlatformId == 'none' ||
            usedPlatformId == 'borrowed') {
          continue;
        }
        if (usedAmmoId.isEmpty ||
            usedAmmoId == 'none' ||
            usedAmmoId == 'borrowed') {
          continue;
        }
        effectiveShotAllocations.add(
          ExerciseShotAllocation(
            platformId: usedPlatformId,
            ammoId: usedAmmoId,
            shots: stepShots,
          ),
        );
      }
    } else if (computedShots > 0 &&
        effectivePlatformId != 'borrowed' &&
        effectivePlatformId != 'none' &&
        effectiveAmmoId != 'borrowed' &&
        effectiveAmmoId != 'none') {
      effectiveShotAllocations.add(
        ExerciseShotAllocation(
          platformId: effectivePlatformId,
          ammoId: effectiveAmmoId,
          shots: computedShots,
        ),
      );
    }

    final exercise = Exercise(
      id:
          widget.exercise?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _exerciseNameController.text.trim(),
      platformId: effectivePlatformId,
      platformLabel: effectivePlatformId == 'borrowed'
          ? _borrowedPlatformController.text.trim()
          : null,
      ammoId: effectiveAmmoId,
      ammoLabel: effectiveAmmoId == 'borrowed'
          ? _borrowedAmmoController.text.trim()
          : null,
      equipmentIds: _selectedEquipmentIds
          .where((id) => !_removedLinkedAccessoryIds.contains(id))
          .toList(),
      targetName: _targetNameController.text.isEmpty
          ? null
          : _targetNameController.text,
      targetPhotos: List<ExercisePhoto>.from(_targetPhotos),
      shotsFired: computedShots,
      distance: computedDistance,
      precision: _measurePrecision ? _precision : null,
      precisionEnabled: _measurePrecision ? _precisionEnabled : true,
      observations: _observationsController.text,
      steps: effectiveSteps,
      platformAssignments: effectivePlatformAssignments,
      shotAllocations: effectiveShotAllocations,
    );

    widget.onSave(exercise);
  }
}

class _SourceToggleRow extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final String value;
  final ValueChanged<String> onChanged;

  const _SourceToggleRow({
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: _SlidingSegmentedSelector(
        selectedIndex: value == 'borrowed' ? 1 : 0,
        labels: [leftLabel, rightLabel],
        onSelected: (index) {
          onChanged(index == 1 ? 'borrowed' : 'inventory');
        },
      ),
    );
  }
}

class _SelectedSingleItemField extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String titleWhenEmpty;
  final String titleWhenSet;
  final String? subtitle;
  final VoidCallback onTap;

  const _SelectedSingleItemField({
    this.icon,
    this.leading,
    required this.titleWhenEmpty,
    required this.titleWhenSet,
    required this.onTap,
    this.subtitle,
  }) : assert(
         icon != null || leading != null,
         'Provide either icon or leading',
       );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final isEmpty = titleWhenSet == titleWhenEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Center(
                        child:
                            leading ??
                            Icon(icon!, size: 18, color: colors.primary),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        isEmpty ? titleWhenEmpty : titleWhenSet,
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.outline,
                    ),
                  ],
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const Gap(6),
                  Text(
                    subtitle!,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ],
                if (subtitle == null || subtitle!.trim().isEmpty) ...[
                  const Gap(6),
                  Text(
                    strings.tapToChooseFromInventory,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String? initialId;
  final IconData? icon;
  final Widget Function(bool selected, ColorScheme colors)? iconBuilder;
  final String Function(T item) primaryText;
  final String Function(T item) secondaryText;
  final bool Function(T item, String query) matchesQuery;
  final String Function(T item) getId;
  final bool Function(T item)? isLockedItem;

  const _SingleSelectSheet({
    required this.title,
    required this.items,
    required this.initialId,
    this.icon,
    this.iconBuilder,
    required this.primaryText,
    required this.secondaryText,
    required this.matchesQuery,
    required this.getId,
    this.isLockedItem,
  }) : assert(
         icon != null || iconBuilder != null,
         'Provide either icon or iconBuilder',
       );

  @override
  State<_SingleSelectSheet<T>> createState() => _SingleSelectSheetState<T>();
}

class _SingleSelectSheetState<T> extends State<_SingleSelectSheet<T>> {
  String _query = '';
  String? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialId;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    final filtered = widget.items.where((it) {
      if (_query.trim().isEmpty) return true;
      return widget.matchesQuery(it, _query.trim());
    }).toList();

    final canValidate = _selection != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: strings.actionClose,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                style: textStyles.bodyMedium?.copyWith(fontSize: 14),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: strings.searchSessionsHint,
                  hintStyle: textStyles.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colors.secondary,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: _query.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          splashRadius: 18,
                          onPressed: () {
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  filled: true,
                  fillColor: searchFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                ),
              ),
            ),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        strings.noResults,
                        style: textStyles.bodyMedium?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Gap(6),
                      itemBuilder: (context, index) {
                        final it = filtered[index];
                        final id = widget.getId(it);
                        final isLocked = widget.isLockedItem?.call(it) ?? false;

                        final tile = Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: isLocked ? 0.45 : 1,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  child: RadioListTile<String>(
                                    value: id,
                                    groupValue: _selection,
                                    onChanged: isLocked
                                        ? null
                                        : (v) => setState(() => _selection = v),
                                    fillColor: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return colors.primary;
                                      }
                                      return Colors.transparent;
                                    }),
                                    title: Text(
                                      widget.primaryText(it),
                                      style: textStyles.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      widget.secondaryText(it),
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    secondary: null,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                ),
                              ),
                              if (isLocked)
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
                                      AppStrings.of(context).proBadge,
                                      style: textStyles.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );

                        if (!isLocked) return tile;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/pro'),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: tile,
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: canValidate ? AppShadows.cardPremium : null,
                    ),
                    child: FilledButton(
                      onPressed: canValidate
                          ? () => context.pop(_selection)
                          : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        disabledBackgroundColor: colors.outline.withValues(
                          alpha: 0.18,
                        ),
                        disabledForegroundColor: colors.outline.withValues(
                          alpha: 0.85,
                        ),
                        overlayColor: Colors.transparent,
                      ),
                      child: Text(strings.validate),
                    ),
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

class _SelectedEquipmentField extends StatelessWidget {
  final List<Accessory> accessories;
  final Set<String> selectedIds;
  final Set<String> linkedIds;
  final VoidCallback onTap;
  final ValueChanged<String> onRemove;
  final ValueChanged<String>? onUnlinkForSession;

  const _SelectedEquipmentField({
    required this.accessories,
    required this.selectedIds,
    this.linkedIds = const {},
    required this.onTap,
    required this.onRemove,
    this.onUnlinkForSession,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final selected = selectedIds
        .map((id) => accessories.where((a) => a.id == id).firstOrNull)
        .whereType<Accessory>()
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.build_rounded, size: 18, color: colors.primary),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        selected.isEmpty
                            ? strings.noEquipmentSelected
                            : strings.selectedEquipmentCount(selected.length),
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.outline,
                    ),
                  ],
                ),
                if (selected.isNotEmpty) ...[
                  const Gap(10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected.map((a) {
                      final isLinked = linkedIds.contains(a.id);
                      return InputChip(
                        avatar: isLinked
                            ? Icon(
                                Icons.link_rounded,
                                size: 16,
                                color: colors.primary,
                              )
                            : null,
                        label: Text(a.name, overflow: TextOverflow.ellipsis),
                        onDeleted: () {
                          if (isLinked && onUnlinkForSession != null) {
                            onUnlinkForSession!(a.id);
                          } else {
                            onRemove(a.id);
                          }
                        },
                        deleteIcon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: colors.onSurface,
                        ),
                        backgroundColor: isLinked
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isLinked
                                ? colors.primary.withValues(alpha: 0.4)
                                : colors.outline,
                          ),
                        ),
                        labelStyle: textStyles.labelLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  const Gap(6),
                  Row(
                    children: [
                      if (accessories.isEmpty)
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: colors.secondary,
                        ),
                      if (accessories.isEmpty) const Gap(8),
                      Expanded(
                        child: Text(
                          accessories.isEmpty
                              ? strings.noAccessoryInStock
                              : strings.tapToChooseFromInventory,
                          style: textStyles.bodySmall?.copyWith(
                            color: colors.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddExerciseStepSheet extends StatefulWidget {
  final ExerciseStep? initialStep;
  final List<Platform> availablePlatforms;
  final List<Ammo> availableAmmos;
  final String? defaultPlatformId;
  final String? defaultAmmoId;

  const _AddExerciseStepSheet({
    // ignore: unused_element_parameter
    this.initialStep,
    this.availablePlatforms = const [],
    this.availableAmmos = const [],
    this.defaultPlatformId,
    this.defaultAmmoId,
  });

  @override
  State<_AddExerciseStepSheet> createState() => _AddExerciseStepSheetState();
}

class _AddExerciseStepSheetState extends State<_AddExerciseStepSheet> {
  static const String _noneValue = '__none__';
  static const String _customValue = '__custom__';
  static const String _customPrefix = 'custom:';

  StepType _type = StepType.tir;
  ShootingPosition? _position;

  final _distanceController = TextEditingController();
  final _shotsController = TextEditingController();
  final _targetController = TextEditingController();
  final _platformFromController = TextEditingController();
  final _platformToController = TextEditingController();
  final _customPlatformController = TextEditingController();
  final _customAmmoController = TextEditingController();
  String? _usedPlatformId;
  String? _usedAmmoId;
  ReloadType? _reloadType;
  final _durationController = TextEditingController();
  final _triggerController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialStep;
    if (initial == null) {
      _usedPlatformId = widget.defaultPlatformId;
      _usedAmmoId = widget.defaultAmmoId;
      return;
    }

    _type = initial.type;
    _position = initial.position;
    _reloadType = initial.reloadType;

    _distanceController.text = initial.distanceM?.toString() ?? '';
    _shotsController.text = initial.shots?.toString() ?? '';
    _targetController.text = initial.target ?? '';
    _platformFromController.text = initial.platformFrom ?? '';
    _platformToController.text = initial.platformTo ?? '';
    final initialPlatform = initial.usedPlatformId;
    if (initialPlatform != null && initialPlatform.startsWith(_customPrefix)) {
      _usedPlatformId = _customValue;
      _customPlatformController.text = initialPlatform
          .substring(_customPrefix.length)
          .trim();
    } else {
      _usedPlatformId = initialPlatform ?? widget.defaultPlatformId;
    }
    final initialAmmo = initial.usedAmmoId;
    if (initialAmmo != null && initialAmmo.startsWith(_customPrefix)) {
      _usedAmmoId = _customValue;
      _customAmmoController.text = initialAmmo
          .substring(_customPrefix.length)
          .trim();
    } else {
      _usedAmmoId = initialAmmo ?? widget.defaultAmmoId;
    }
    _durationController.text = initial.durationSeconds?.toString() ?? '';
    _triggerController.text = initial.trigger ?? '';
    _commentController.text = initial.comment ?? '';
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _shotsController.dispose();
    _targetController.dispose();
    _platformFromController.dispose();
    _platformToController.dispose();
    _customPlatformController.dispose();
    _customAmmoController.dispose();
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
    final availablePlatformIds = widget.availablePlatforms
        .map((w) => w.id)
        .toSet();
    final availableAmmoIds = widget.availableAmmos.map((a) => a.id).toSet();
    final selectedPlatformValue = _usedPlatformId == _customValue
        ? _customValue
        : availablePlatformIds.contains(_usedPlatformId)
        ? _usedPlatformId
        : _noneValue;
    final selectedAmmoValue = _usedAmmoId == _customValue
        ? _customValue
        : availableAmmoIds.contains(_usedAmmoId)
        ? _usedAmmoId
        : _noneValue;

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
                    style: textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
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
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.exerciseStepTypeTitle,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                        labelStyle: textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(AppSpacing.md),
                  Text(
                    strings.exerciseStepPositionTitle,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                              color: selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const Gap(AppSpacing.md),

                  if (_type == StepType.tir) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedPlatformValue,
                      decoration: decoration(strings.stepUsedPlatformLabel),
                      items: [
                        DropdownMenuItem<String>(
                          value: _noneValue,
                          child: Text(
                            '${strings.stepUsedPlatformLabel}${strings.exerciseOptionalHint}',
                          ),
                        ),
                        ...widget.availablePlatforms.map(
                          (w) => DropdownMenuItem<String>(
                            value: w.id,
                            child: Text(w.name),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: _customValue,
                          child: Text(
                            strings.exercisePositionLabel(
                              ShootingPosition.autre,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _usedPlatformId = v == _noneValue ? null : v;
                      }),
                    ),
                    if (_usedPlatformId == _customValue) ...[
                      const Gap(10),
                      TextField(
                        controller: _customPlatformController,
                        decoration: decoration(
                          '${strings.stepUsedPlatformLabel}${strings.exerciseOptionalHint}',
                        ),
                      ),
                    ],
                    const Gap(10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedAmmoValue,
                      decoration: decoration(strings.stepUsedAmmoLabel),
                      items: [
                        DropdownMenuItem<String>(
                          value: _noneValue,
                          child: Text(
                            '${strings.stepUsedAmmoLabel}${strings.exerciseOptionalHint}',
                          ),
                        ),
                        ...widget.availableAmmos.map(
                          (a) => DropdownMenuItem<String>(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: _customValue,
                          child: Text(
                            strings.exercisePositionLabel(
                              ShootingPosition.autre,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _usedAmmoId = v == _noneValue ? null : v;
                      }),
                    ),
                    if (_usedAmmoId == _customValue) ...[
                      const Gap(10),
                      TextField(
                        controller: _customAmmoController,
                        decoration: decoration(
                          '${strings.stepUsedAmmoLabel}${strings.exerciseOptionalHint}',
                        ),
                      ),
                    ],
                    const Gap(10),
                    TextField(
                      controller: _shotsController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldShots}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                        '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}',
                      ),
                    ),
                  ] else if (_type == StepType.deplacement) ...[
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                  ] else if (_type == StepType.rechargement) ...[
                    Text(
                      strings.exerciseFieldReloadType,
                      style: textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
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
                      controller: _platformFromController,
                      decoration: decoration(
                        '${strings.exerciseFieldPlatformFrom}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    if (_platformFromController.text.isNotEmpty &&
                        widget.defaultPlatformId == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        strings.exercisePlatformSelectionHint,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const Gap(10),
                    TextField(
                      controller: _platformToController,
                      decoration: decoration(
                        '${strings.exerciseFieldPlatformTo}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    if (_platformToController.text.isNotEmpty &&
                        widget.defaultPlatformId == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        strings.exercisePlatformSelectionHint,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ] else if (_type == StepType.miseEnJoue) ...[
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                        '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                  ] else if (_type == StepType.attente) ...[
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDuration} (s)${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _triggerController,
                      decoration: decoration(
                        '${strings.exerciseFieldTrigger}${strings.exerciseOptionalHint}',
                      ),
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
                          final distanceM = int.tryParse(
                            _distanceController.text.trim(),
                          );
                          final shots = int.tryParse(
                            _shotsController.text.trim(),
                          );
                          final durationSeconds = int.tryParse(
                            _durationController.text.trim(),
                          );

                          final customPlatformName = _customPlatformController
                              .text
                              .trim();
                          final customAmmoName = _customAmmoController.text
                              .trim();
                          final effectivePlatformId =
                              _usedPlatformId == _customValue
                              ? (customPlatformName.isEmpty
                                    ? null
                                    : '$_customPrefix$customPlatformName')
                              : (_usedPlatformId ?? '').trim().isEmpty
                              ? null
                              : _usedPlatformId!.trim();
                          final effectiveAmmoId = _usedAmmoId == _customValue
                              ? (customAmmoName.isEmpty
                                    ? null
                                    : '$_customPrefix$customAmmoName')
                              : (_usedAmmoId ?? '').trim().isEmpty
                              ? null
                              : _usedAmmoId!.trim();
                          final step = ExerciseStep(
                            id:
                                widget.initialStep?.id ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            type: _type,
                            position: _position,
                            distanceM: distanceM,
                            shots: shots,
                            target: _targetController.text.trim().isEmpty
                                ? null
                                : _targetController.text.trim(),
                            platformFrom:
                                _platformFromController.text.trim().isEmpty
                                ? null
                                : _platformFromController.text.trim(),
                            platformTo:
                                _platformToController.text.trim().isEmpty
                                ? null
                                : _platformToController.text.trim(),
                            usedPlatformId: effectivePlatformId,
                            usedAmmoId: effectiveAmmoId,
                            reloadType: _reloadType,
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

class _EquipmentMultiSelectSheet extends StatefulWidget {
  final List<Accessory> accessories;
  final Set<String> initialSelection;

  const _EquipmentMultiSelectSheet({
    required this.accessories,
    required this.initialSelection,
  });

  @override
  State<_EquipmentMultiSelectSheet> createState() =>
      _EquipmentMultiSelectSheetState();
}

class _EquipmentMultiSelectSheetState
    extends State<_EquipmentMultiSelectSheet> {
  late Set<String> _selection;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selection = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    final filtered = widget.accessories.where((a) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return a.name.toLowerCase().contains(q) ||
          a.type.toLowerCase().contains(q) ||
          a.brand.toLowerCase().contains(q) ||
          a.model.toLowerCase().contains(q);
    }).toList();

    final canValidate = _selection.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.equipmentsTitle,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: strings.actionClose,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                style: textStyles.bodyMedium?.copyWith(fontSize: 14),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: strings.searchEquipmentHint,
                  hintStyle: textStyles.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colors.secondary,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: _query.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          splashRadius: 18,
                          onPressed: () {
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  filled: true,
                  fillColor: searchFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                ),
              ),
            ),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        strings.noEquipmentFound,
                        style: textStyles.bodyMedium?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Gap(6),
                      itemBuilder: (context, index) {
                        final a = filtered[index];
                        final selected = _selection.contains(a.id);
                        final originalIndex = widget.accessories.indexOf(a);
                        final isLocked = provider.isAccessoryLockedForFree(
                          a,
                          originalIndex,
                        );

                        final tile = Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: isLocked ? 0.45 : 1,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  child: ListTile(
                                    enabled: !isLocked,
                                    leading: Icon(
                                      selected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      size: 20,
                                      color: selected
                                          ? colors.primary
                                          : colors.outline,
                                    ),
                                    title: Text(
                                      a.name,
                                      style: textStyles.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      [
                                        strings.itemAccessoryTypeLabel(a.type),
                                        if (a.brand.trim().isNotEmpty) a.brand,
                                        if (a.model.trim().isNotEmpty) a.model,
                                      ].join(' • '),
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: null,
                                    onTap: isLocked
                                        ? null
                                        : () {
                                            setState(() {
                                              if (selected) {
                                                _selection.remove(a.id);
                                              } else {
                                                _selection.add(a.id);
                                              }
                                            });
                                          },
                                  ),
                                ),
                              ),
                              if (isLocked)
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
                                      AppStrings.of(context).proBadge,
                                      style: textStyles.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );

                        if (!isLocked) return tile;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/pro'),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: tile,
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: canValidate ? AppShadows.cardPremium : null,
                    ),
                    child: FilledButton(
                      onPressed: canValidate
                          ? () => context.pop(_selection)
                          : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        disabledBackgroundColor: colors.outline.withValues(
                          alpha: 0.18,
                        ),
                        disabledForegroundColor: colors.outline.withValues(
                          alpha: 0.85,
                        ),
                        overlayColor: Colors.transparent,
                      ),
                      child: Text(strings.validate),
                    ),
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

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

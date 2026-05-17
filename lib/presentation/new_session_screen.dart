import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
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
import 'package:thot/utils/validators.dart';

part 'new_session/session_widgets.dart';
part 'new_session/import_exercise_template_sheet.dart';
part 'new_session/session_summary.dart';
part 'new_session/exercise_form.dart';
part 'new_session/selection_sheets.dart';
part 'new_session/exercise_step_sheet.dart';

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

  final _formKey = GlobalKey<FormState>();
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

  // Hash for unsaved changes detection
  String _initialSessionHash = '';

  @override
  void initState() {
    super.initState();

    if (widget.sessionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSession();
        _initialSessionHash = _computeSessionHash();
      });
    } else {
      // For new sessions, compute hash after first frame to ensure all defaults are set
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialSessionHash = _computeSessionHash();
      });
    }
  }

  /// Computes a hash of all session form fields to detect unsaved changes.
  String _computeSessionHash() {
    final data = {
      'name': _nameController.text,
      'date': _selectedDate.toIso8601String(),
      'sessionType': _sessionType,
      'location': _locationController.text,
      'latitude': _selectedCityLatitude,
      'longitude': _selectedCityLongitude,
      'shootingDistance': _shootingDistanceController.text,
      'weatherEnabled': _weatherEnabled,
      'temp': _tempController.text,
      'wind': _windController.text,
      'humidity': _humidityController.text,
      'pressure': _pressureController.text,
      'tempEnabled': _tempEnabled,
      'windEnabled': _windEnabled,
      'humidityEnabled': _humidityEnabled,
      'pressureEnabled': _pressureEnabled,
      'exerciseCount': _exercises.length,
      // Hash exercises' essential identity to catch additions/removals/changes
      'exerciseSig': _exercises
          .map((e) => '${e.name}|${e.distance}|${e.shotsFired}|${e.standardDrillId ?? ''}|${e.duration?.inSeconds ?? 0}')
          .join(';'),
    };
    return base64Encode(
      sha256.convert(utf8.encode(jsonEncode(data))).bytes,
    );
  }

  bool get _hasUnsavedChanges =>
      _initialSessionHash.isNotEmpty &&
      _computeSessionHash() != _initialSessionHash;

  Future<bool> _showUnsavedSessionDialog() async {
    final strings = AppStrings.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.unsavedChangesTitle),
        content: Text(strings.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(strings.unsavedChangesDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.unsavedChangesKeep),
          ),
        ],
      ),
    );
    return result ?? false;
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
            tooltip: strings.close,
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
              maxLength: 100,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              onChanged: (_) {
                if (_nameError && _nameController.text.trim().isNotEmpty) {
                  setState(() => _nameError = false);
                }
              },
              decoration: InputDecoration(
                counterText: '',
                labelText: strings.sessionNameLabel,
                hintText: strings.sessionNameHint,
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
                  maxLength: 100,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100),
                  ],
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
                    counterText: '',
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
        title: '${strings.exercisesSectionTitle} *',
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
                validator: _tempEnabled
                   ? (v) => ThotValidators.anyDouble(v, strings)
                    : null,
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
                validator: _windEnabled
                    ? (v) => ThotValidators.positiveDouble(v, strings)
                    : null,
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
                validator: _humidityEnabled
                    ? (v) => ThotValidators.humidityRange(v, strings)
                    : null,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          if (mounted) Navigator.of(context).pop();
          return;
        }
        final shouldLeave = await _showUnsavedSessionDialog();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                      child: Form(
                        key: _formKey,
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
                  ),
                ],
              ),
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
        shotsFired: 0,
        distance: 0,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
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
          if (attempt < maxRetries) {
            await Future.delayed(baseDelay * attempt);
            continue;
          }
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
          if (attempt < maxRetries) {
            await Future.delayed(baseDelay * attempt);
            continue;
          }
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
          if (attempt < maxRetries) {
            await Future.delayed(baseDelay * attempt);
            continue;
          }
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
        return; // Success, exit retry loop
      } catch (e) {
        debugPrint('Weather autofill attempt $attempt failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(baseDelay * attempt);
          continue;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.weatherRetrievalError),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    if (mounted) setState(() => _isWeatherLoading = false);
  }
}

class WeatherEditableField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final VoidCallback onToggleEnabled;
  final String? Function(String?)? validator;

  const WeatherEditableField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.enabled,
    required this.onToggleEnabled,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final radius = BorderRadius.circular(AppRadius.lg);

    final field = TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
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








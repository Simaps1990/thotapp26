import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/utils/unit_converter.dart';
import 'package:thot/presentation/shooting_timer_screen.dart';
import 'package:thot/widgets/cross_platform_image.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/app_date_formats.dart';

class NewSessionScreen extends StatefulWidget {
  final String? sessionId;

  const NewSessionScreen({Key? key, this.sessionId}) : super(key: key);

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
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
  String _sessionType = 'Personnel';

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

  bool _isLocating = false;
  bool _isWeatherLocating = false;
  double? _lastResolvedLatitude;
  double? _lastResolvedLongitude;

Future<String?> _reverseGeocodeCityCountry(
    {required double lat, required double lon}) async {
  try {
    // Web: prefer a CORS-friendly endpoint.
    if (kIsWeb) {
      final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client'
        '?latitude=$lat'
        '&longitude=$lon'
        '&localityLanguage=fr',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('Reverse geocode (web) failed with HTTP ${res.statusCode}.');
        return null;
      }

      final json = jsonDecode(utf8.decode(res.bodyBytes));
      if (json is! Map<String, dynamic>) return null;

      final city = (json['city'] as String?)?.trim();
      final locality = (json['locality'] as String?)?.trim();
      final countryCode =
          (json['countryCode'] as String?)?.trim().toUpperCase();

      final name = (city?.isNotEmpty == true ? city : locality);
      if (name == null || name.isEmpty) return null;
      return countryCode?.isNotEmpty == true ? '$name, $countryCode' : name;
    }

    // Mobile/desktop: use OpenStreetMap Nominatim.
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=jsonv2'
      '&lat=$lat'
      '&lon=$lon'
      '&zoom=10'
      '&addressdetails=1'
      '&accept-language=fr',
    );
    final res = await http.get(uri, headers: {
      'User-Agent': 'thot-app/1.0 (THOT)',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 10));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('Reverse geocode failed with HTTP ${res.statusCode}.');
      return null;
    }

    final json = jsonDecode(utf8.decode(res.bodyBytes));
    if (json is! Map<String, dynamic>) return null;
    final address = json['address'];
    if (address is! Map<String, dynamic>) return null;

    String? pickString(String key) => (address[key] as String?)?.trim();

    final city = pickString('city') ??
        pickString('town') ??
        pickString('village') ??
        pickString('municipality') ??
        pickString('county');
    final countryCode = (pickString('country_code'))?.toUpperCase();

    if (city == null || city.isEmpty) return null;
    return countryCode?.isNotEmpty == true ? '$city, $countryCode' : city;
  } catch (e) {
    debugPrint('Reverse geocode failed.');
    return null;
  }
}

LocationSettings _buildLocationSettings() {
  if (kIsWeb) {
    return WebSettings(
      accuracy: LocationAccuracy.high,
      maximumAge: const Duration(minutes: 5),
    );
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 2),
    );
  }

  return const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );
}

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
      final session =
          provider.sessions.firstWhere((s) => s.id == widget.sessionId);

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
      });
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Widget _buildHeader({
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: colors.onSurface,
            onPressed: () => context.pop(),
          ),
          Text(
            strings.newSessionTitle,
            style: textStyles.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 48),
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
          Icon(
            Icons.tune_rounded,
            size: 18,
            color: colors.primary,
          ),
          const Gap(8),
          Text(
            strings.sessionTypeLabel,
            style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _nameError ? colors.error : Colors.transparent,
            width: 1.4,
          ),
        ),
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
        onTap: () => _selectDateTime(context),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _locationError ? colors.error : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  onChanged: (_) {
                    if (_locationError &&
                        _locationController.text.trim().isNotEmpty) {
                      setState(() => _locationError = false);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: strings.locationLabel,
                    hintText: strings.locationHint,
                    errorText: null,
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
                ),
              ),
              const Gap(AppSpacing.md),
              SizedBox(
                width: 56,
                child: Material(
                  color: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    side: BorderSide(color: colors.primary),
                  ),
                  child: InkWell(
                    onTap: _isLocating || _isWeatherLocating
                        ? null
                        : _fillWithCurrentPosition,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: colors.onPrimary.withValues(alpha: 0.10),
                    child: Center(
                      child: _isLocating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.my_location_rounded,
                              color: colors.onPrimary,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      const Gap(AppSpacing.md),

      TextField(
        controller: _shootingDistanceController,
        decoration: InputDecoration(
          labelText: strings.shootingDistanceLabel,
          hintText: strings.shootingDistanceHint,
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

      Text(
        '${strings.locationUsageExplanation}\n\n${strings.reverseGeocodingExplanation}',
        style: textStyles.bodySmall?.copyWith(color: colors.secondary),
      ),

      const Gap(AppSpacing.sm),
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
          colorFilter: ColorFilter.mode(
            colors.primary,
            BlendMode.srcIn,
          ),
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
            child: Text(strings.saveSessionButton),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ),
      const Gap(AppSpacing.lg),
    ];
  }

  List<Widget> _buildExercisesSection({
    required ColorScheme colors,
    required TextTheme textStyles,
    required ThotProvider provider,
  }) {
    return [
      // Exercises Section
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SectionHeader(
            leading: SvgPicture.asset(
              'assets/images/train.svg',
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                colors.primary,
                BlendMode.srcIn,
              ),
            ),
            title: strings.exercisesSectionTitle,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add, size: 18),
                label: Text(strings.createExerciseButton),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const Gap(8),
              OutlinedButton.icon(
                onPressed: _importExerciseFromTemplate,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(strings.importExerciseButton),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
      const Gap(AppSpacing.md),
      Container(
        key: _exercisesFieldKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _exercisesError ? colors.error : Colors.transparent,
            width: 1.4,
          ),
        ),
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
                            colors.outline,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          strings.noExerciseAdded,
                          style: textStyles.bodyMedium?.copyWith(
                            color: _exercisesError ? colors.error : colors.outline,
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
    final hasWeatherData = _tempController.text.trim().isNotEmpty ||
        _windController.text.trim().isNotEmpty ||
        _humidityController.text.trim().isNotEmpty ||
        _pressureController.text.trim().isNotEmpty;

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
          Switch(
            value: _weatherEnabled,
            onChanged: _onWeatherToggled,
          ),
        ],
      ),
      if (_weatherEnabled) ...[
        const Gap(AppSpacing.md),
        if (!hasWeatherData) ...[
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: _isLocating || _isWeatherLocating
                  ? null
                  : _fillWeatherFromCurrentPosition,
              icon: _isWeatherLocating
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18, color: Colors.white),
              label: Text(strings.fetchLocalWeatherButton),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
            ),
          ),
          const Gap(AppSpacing.md),
        ],
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
                    style: textStyles.bodySmall
                        ?.copyWith(color: colors.secondary),
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
                onToggleEnabled: () => setState(
                    () => _pressureEnabled = !_pressureEnabled),
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
                hintText:
                    converter.useMetric ? '12 km/h' : '7 mph',
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
                onToggleEnabled: () => setState(
                    () => _humidityEnabled = !_humidityEnabled),
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
    final provider = Provider.of<ThotProvider>(context);
    final converter = UnitConverter(provider.useMetric);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors.surface,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(colors: colors, textStyles: textStyles),

              Expanded(
                child: SingleChildScrollView(
                  controller: _sessionScrollController,
                  padding: const EdgeInsets.all(20),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

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

  void _importExerciseFromTemplate() {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final templates = provider.exerciseTemplates;
    final strings = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            final colors = Theme.of(ctx).colorScheme;
            final textStyles = Theme.of(ctx).textTheme;
            final baseBackground = Theme.of(ctx).scaffoldBackgroundColor;
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
                  Padding(
                    padding: AppSpacing.paddingLg,
                    child: Text(
                      strings.importTemplateTitle,
                      style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: templates.isEmpty
                        ? Center(
                            child: Text(
                              strings.noTemplatesAvailable,
                              style: textStyles.bodyMedium?.copyWith(color: colors.outline),
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            padding: AppSpacing.paddingLg,
                            itemCount: templates.length,
                            itemBuilder: (_, i) {
                              final t = templates[i];
                              return ListTile(
                                title: Text(
                                  t.name,
                                  style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  t.detailedMode
                                      ? '${t.steps?.length ?? 0} étapes'
                                      : '${t.shotsFired} coups · ${t.distance} m',
                                  style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                                ),
                                trailing: FilledButton(
                                  onPressed: () {
                                    final exercise = Exercise(
                                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                                      name: t.name,
                                      weaponId: _exercises.isNotEmpty ? _exercises.last.weaponId : '',
                                      ammoId: _exercises.isNotEmpty ? _exercises.last.ammoId : '',
                                      shotsFired: t.shotsFired,
                                      distance: t.distance,
                                      observations: t.observations,
                                      steps: t.steps != null ? List<ExerciseStep>.from(t.steps!) : null,
                                      weaponLabel: null,
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
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text(strings.templateImportButton),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addExercise() {
    Exercise? template;
    if (_exercises.isNotEmpty) {
      final lastExercise = _exercises.last;
      template = Exercise(
        id: '',
        name: '',
        weaponId: lastExercise.weaponId,
        weaponLabel: lastExercise.weaponLabel,
        ammoId: lastExercise.ammoId,
        ammoLabel: lastExercise.ammoLabel,
        equipmentIds: List<String>.from(lastExercise.equipmentIds),
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
      builder: (context) => _ExerciseForm(
        exercise: template,
        onSave: (exercise) {
          setState(() {
            _exercises.add(exercise);
            _exercisesError = false;
          });
          context.pop();
        },
      ),
    );
  }

  void _editExercise(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseForm(
        exercise: _exercises[index],
        onSave: (exercise) {
          setState(() {
            _exercises[index] = exercise;
            _exercisesError = false;
          });
          context.pop();
        },
      ),
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
      id: widget.sessionId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      date: _selectedDate,
      location: _locationController.text.trim(),
      shootingDistance: _shootingDistanceController.text.isEmpty
          ? null
          : _shootingDistanceController.text,
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
    );

    assert(
      widget.sessionId == null || session.id == widget.sessionId,
      'Session id mismatch during update',
    );

    final provider = Provider.of<ThotProvider>(context, listen: false);

    if (!provider.isPremium) {
      for (final ex in _exercises) {
        if (ex.weaponId != 'none' && ex.weaponId != 'borrowed' && !provider.canUseWeaponId(ex.weaponId)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.freeVersionWeaponLimit)),
          );
          showProModal(context);
          return;
        }
        if (ex.ammoId != 'none' && ex.ammoId != 'borrowed' && !provider.canUseAmmoId(ex.ammoId)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.freeVersionAmmoLimit)),
          );
          showProModal(context);
          return;
        }
        for (final accId in ex.equipmentIds) {
          if (!provider.canUseAccessoryId(accId)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.freeVersionAccessoryLimit)),
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
          SnackBar(content: Text(provider.getLimitMessage('session'))),
        );
        showProModal(context);
        return;
      }
      provider.addSession(session);
    }

    context.pop();
  }

  Future<void> _fillWithCurrentPosition() async {
    setState(() => _isLocating = true);
    try {
      await _resolveLocationAndWeather(updateLocationField: true);
    } catch (e) {
      debugPrint('Failed to get current position: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.positionRetrievalFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _fillWeatherFromCurrentPosition() async {
    setState(() => _isWeatherLocating = true);
    try {
      await _resolveLocationAndWeather(updateLocationField: false);
    } catch (e) {
      debugPrint('Failed to get weather from current position: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.weatherRetrievalError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isWeatherLocating = false);
    }
  }

  Future<void> _onWeatherToggled(bool enabled) async {
    if (!enabled) {
      setState(() => _weatherEnabled = false);
      return;
    }

    setState(() {
      _weatherEnabled = true;
      // Re-enable everything when turning weather back on.
      _tempEnabled = true;
      _windEnabled = true;
      _humidityEnabled = true;
      _pressureEnabled = true;
    });
  }

  Future<Position?> _requestCurrentPosition({
    required String permissionDeniedMessage,
    required String permissionDeniedForeverMessage,
    required String servicesDisabledMessage,
  }) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(permissionDeniedForeverMessage),
              action: SnackBarAction(
                label: strings.openAppSettingsLabel,
                onPressed: () {
                  Geolocator.openAppSettings();
                },
              ),
            ),
          );
        }
        return null;
      }

      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(permissionDeniedMessage)),
          );
        }
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services disabled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(servicesDisabledMessage),
              action: SnackBarAction(
                label: strings.openAppSettingsLabel,
                onPressed: () {
                  Geolocator.openLocationSettings();
                },
              ),
            ),
          );
        }
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: _buildLocationSettings(),
      );
    } on TimeoutException {
      debugPrint('Location request timed out');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.positionRetrievalFailed)),
        );
      }
      return null;
    } on LocationServiceDisabledException {
      debugPrint('Location service disabled while requesting position');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(servicesDisabledMessage),
            action: SnackBarAction(
              label: strings.openAppSettingsLabel,
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Failed to retrieve current position: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.positionRetrievalFailed)),
        );
      }
      return null;
    }
  }

  Future<void> _resolveLocationAndWeather({
    required bool updateLocationField,
  }) async {
    // Check offline first
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.offlineLocationUnavailable)),
          );
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.offlineLocationUnavailable)),
        );
      }
      return;
    }

    final position = await _requestCurrentPosition(
      permissionDeniedMessage: strings.locationPermissionDenied,
      permissionDeniedForeverMessage: strings.locationPermissionDeniedForever,
      servicesDisabledMessage: strings.locationServicesDisabled,
    );
    if (position == null) return;

    final lat = position.latitude;
    final lon = position.longitude;

    _lastResolvedLatitude = lat;
    _lastResolvedLongitude = lon;

    if (updateLocationField) {
      _locationController.text =
          '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';

      final pretty = await _reverseGeocodeCityCountry(lat: lat, lon: lon);
      if (pretty != null && pretty.isNotEmpty) {
        _locationController.text = pretty;
      }
    } else {
      unawaited(_reverseGeocodeCityCountry(lat: lat, lon: lon));
    }

    await _autofillWeatherForCoordinates(lat: lat, lon: lon);
  }

  Future<void> _autofillWeatherForCoordinates({
    required double lat,
    required double lon,
  }) async {
    if (_isWeatherLoading) return;

    // Check offline first
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      if (result.isEmpty || result[0].rawAddress.isNotEmpty == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.offlineWeatherUnavailable)),
          );
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.offlineWeatherUnavailable)),
        );
      }
      return;
    }

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
            SnackBar(content: Text(strings.weatherNetworkError)),
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
            SnackBar(content: Text(strings.weatherInvalidResponse)),
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
            SnackBar(content: Text(strings.weatherUnavailable)),
          );
        }
        return;
      }

      setState(() {
        if (tempC != null)
          _tempController.text = converter.formatTemperature(tempC);
        if (windKmh != null)
          _windController.text = converter.formatWindSpeed(windKmh);
        if (humidity != null) _humidityController.text = '${humidity.round()}%';
        if (pressureHpa != null)
          _pressureController.text = converter.formatPressure(pressureHpa);
      });
    } catch (e) {
      debugPrint('Weather autofill failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.weatherRetrievalError)),
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
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
final distUnit = provider.useMetric ? 'm' : 'yd';
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
          borderSide: BorderSide(color: colors.primary, width: 1.6),
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
        const Gap(AppSpacing.sm),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
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
            border: Border.all(
              color: subtleBorderColor,
            ),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
    
    final weapon = provider.getWeaponById(exercise.weaponId);
    final ammo = provider.getAmmoById(exercise.ammoId);
    final equipmentNames = exercise.equipmentIds
        .map((id) =>
            provider.accessories.where((a) => a.id == id).firstOrNull?.name)
        .whereType<String>()
        .where((name) => name.trim().isNotEmpty)
        .toList();

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
                      backgroundColor:
                          dialogColors.surface.withValues(alpha: 0.85),
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
      borderRadius: BorderRadius.circular(16),
      border: isDark
          ? null
          : Border.all(
              color: LightColors.surfaceHighlight,
              width: 1.35,
            ),
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
                    Text(exerciseTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    if (exerciseSubtitle != null) ...[
                      const Gap(2),
                      Text(exerciseSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.labelSmall?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (onMoveUp != null)
                    IconButton(
                      onPressed: onMoveUp,
                      icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
                      color: colors.secondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onMoveDown != null)
                    IconButton(
                      onPressed: onMoveDown,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
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
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: colors.error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const Gap(AppSpacing.md),

          // Card 1: weapon & equipment details
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
                  strings.exerciseDetailsTitle,
                  style: textStyles.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Gap(AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: weapon & ammo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: strings.weaponTitle,
                            value: exercise.weaponId == 'borrowed'
                                ? ((exercise.weaponLabel?.trim().isNotEmpty ??
                                        false)
                                    ? exercise.weaponLabel!.trim()
                                    : strings.borrowedWeaponFallback)
                                : (weapon?.name ?? '—'),
                          ),
                          _InfoRow(
                            label: strings.ammoTitle,
                            value: exercise.ammoId == 'borrowed'
                                ? ((exercise.ammoLabel?.trim().isNotEmpty ??
                                        false)
                                    ? exercise.ammoLabel!.trim()
                                    : strings.borrowedAmmoFallback)
                                : (ammo?.name ?? '—'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 56,
                      color: colors.outline,
                    ),
                    const Gap(AppSpacing.md),
                    // Right column: equipment & target
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (equipmentNames.isNotEmpty)
                            _InfoRow(
                              label: strings.equipmentTitle,
                              value: equipmentNames.join(', '),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Gap(AppSpacing.md),

          // Card 2: shooting results (main target photo + shots & distance)
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
                  style: textStyles.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
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
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
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
                      Container(
                        width: 1,
                        height: 120,
                        color: colors.outline,
                      ),
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
                                : '${(exercise.distance * 1.09361).round()} yd',                          ),
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
            Text(strings.observationsTitle,
                style:
                    textStyles.labelSmall?.copyWith(color: colors.secondary)),
            Text(exercise.observations,
                style: textStyles.bodySmall
                    ?.copyWith(color: colors.secondary)),
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
            style:
                textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _SessionSummary extends StatelessWidget {
  final List<Exercise> exercises;
  final ThotProvider provider;

  const _SessionSummary({required this.exercises, required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final totalShots = exercises.fold(0, (sum, ex) => sum + ex.shotsFired);

    // Impact on ammo (inventory only)
    final Map<String, int> ammoImpact = {};
    for (final ex in exercises) {
      final ammo = provider.getAmmoById(ex.ammoId);
      if (ammo == null) continue; // none / borrowed / deleted
      ammoImpact[ammo.id] = (ammoImpact[ammo.id] ?? 0) + ex.shotsFired;
    }

    // Impact on weapons (inventory only)
    final Map<String, int> weaponImpact = {};
    for (final ex in exercises) {
      final weapon = provider.getWeaponById(ex.weaponId);
      if (weapon == null) continue; // none / borrowed / deleted
      weaponImpact[weapon.id] = (weaponImpact[weapon.id] ?? 0) + ex.shotsFired;
    }

    // Impact on equipment
    final Map<String, int> equipmentImpact = {};
    for (final ex in exercises) {
      for (final id in ex.equipmentIds) {
        equipmentImpact[id] = (equipmentImpact[id] ?? 0) + ex.shotsFired;
      }
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.sessionSummaryTotalShots(totalShots),
            style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (ammoImpact.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Text(
              strings.sessionSummaryAmmoImpactTitle,
              style: textStyles.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(4),
            ...ammoImpact.entries.map((e) {
              final ammo = provider.getAmmoById(e.key);
              if (ammo == null) return const SizedBox.shrink();
              final remaining = (ammo.quantity - e.value).clamp(0, 1 << 30);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  strings.sessionSummaryAmmoImpactLine(
                    ammo.name,
                    e.value,
                    remaining,
                  ),
                  style: textStyles.bodySmall,
                ),
              );
            }),
          ],
          if (weaponImpact.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Text(
              strings.sessionSummaryWeaponsImpactTitle,
              style: textStyles.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(4),
            ...weaponImpact.entries.map((e) {
              final weapon = provider.getWeaponById(e.key);
              if (weapon == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  strings.sessionSummaryWeaponImpactLine(
                    weapon.name,
                    e.value,
                  ),
                  style: textStyles.bodySmall,
                ),
              );
            }),
          ],
          if (equipmentImpact.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Text(
              strings.sessionSummaryAccessoriesImpactTitle,
              style: textStyles.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
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

  const _ExerciseForm({this.exercise, required this.onSave});

  @override
  State<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<_ExerciseForm> {
  final _exerciseNameController = TextEditingController();
  final _exerciseScrollController = ScrollController();
  final _weaponFieldKey = GlobalKey();
  final _ammoFieldKey = GlobalKey();
  final _shotsFieldKey = GlobalKey();
  final _distanceFieldKey = GlobalKey();

  bool _detailedMode = false;
  final List<ExerciseStep> _steps = [];

  bool _weaponError = false;
  bool _ammoError = false;
  bool _shotsError = false;
  bool _distanceError = false;

  String _weaponSource = 'inventory'; // inventory | borrowed
  String _ammoSource = 'inventory'; // inventory | borrowed
  String? _selectedWeaponId;
  String? _selectedAmmoId;
  final _borrowedWeaponController = TextEditingController();
  final _borrowedAmmoController = TextEditingController();
  final Set<String> _selectedEquipmentIds = {};
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

      final weaponId = widget.exercise!.weaponId;
      if (weaponId == 'borrowed' || weaponId == 'none') {
        _weaponSource = 'borrowed';
        _selectedWeaponId = null;
        _borrowedWeaponController.text = widget.exercise!.weaponLabel ?? '';
      } else {
        _weaponSource = 'inventory';
        _selectedWeaponId = weaponId;
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
      _targetNameController.text = widget.exercise!.targetName ?? '';
      _targetPhotos
        ..clear()
        ..addAll(widget.exercise!.targetPhotos);
      for (var photo in _targetPhotos) {
        _photoControllers[photo.id] = TextEditingController(text: photo.name);
      }
      _shotsFiredController.text = widget.exercise!.shotsFired.toString();      _distanceController.text = widget.exercise!.distance.toString();
      _observationsController.text = widget.exercise!.observations;
      _measurePrecision = widget.exercise!.precision != null;
      _precision = widget.exercise!.precision ?? 0;
      _precisionEnabled = widget.exercise!.precisionEnabled;

      _detailedMode = widget.exercise!.steps != null;
      _steps
        ..clear()
        ..addAll(widget.exercise!.steps ?? const []);
    } else {
      _distanceController.text = '0';
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

String _stepTitle(StepType type) {
    return AppStrings.of(context).exerciseStepTypeLabel(type);
  }

  String _stepIcon(StepType type) {
    return switch (type) {
      StepType.tir => '💥',
      StepType.deplacement => '🏃🏻‍♂️‍➡️',
      StepType.rechargement => '🔄',
      StepType.transition => '🔃',
      StepType.miseEnJoue => '⏺️',
      StepType.attente => '⏸️',
      StepType.securite => '🛡️',
      StepType.autre => '⚙️',
    };
  }

String _positionShort(ShootingPosition? pos) {
    if (pos == null) return '';
    final strings = AppStrings.of(context);
    return strings.exercisePositionLabel(pos);
  }

String _stepSummary(ExerciseStep s, AppStrings strings, bool useMetric) {
    final parts = <String>[];
    if (s.type == StepType.tir && s.shots != null) {
      parts.add('${s.shots} ${strings.exerciseNarrativeShotsWord}');
    }
    if (s.distanceM != null) {
      final dist = useMetric
          ? '${s.distanceM} m'
          : '${(s.distanceM! * 1.09361).round()} yd';
      parts.add(dist);
    }
    if ((s.target ?? '').trim().isNotEmpty) parts.add(s.target!.trim());
    if (s.type == StepType.transition) {
      if ((s.weaponFrom ?? '').trim().isNotEmpty) {
        parts.add('${strings.exerciseNarrativeFrom.trim()} ${s.weaponFrom!.trim()}');
      }
      if ((s.weaponTo ?? '').trim().isNotEmpty) {
        parts.add('${strings.exerciseNarrativeTo.trim()} ${s.weaponTo!.trim()}');
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
        if (_weaponSource == 'inventory') {
          final exists = _selectedWeaponId != null &&
              provider.weapons.any((w) => w.id == _selectedWeaponId);
          final allowed = _selectedWeaponId != null
              ? provider.canUseWeaponId(_selectedWeaponId!)
              : true;
          if (!exists || !allowed) {
            _selectedWeaponId = provider.weapons.isNotEmpty
                ? provider.weapons.first.id
                : null;
            if (provider.weapons.isEmpty) _weaponSource = 'borrowed';
          }
        }

        if (_ammoSource == 'inventory') {
          final exists = _selectedAmmoId != null &&
              provider.ammos.any((a) => a.id == _selectedAmmoId);
          final allowed = _selectedAmmoId != null
              ? provider.canUseAmmoId(_selectedAmmoId!)
              : true;
          if (!exists || !allowed) {
            _selectedAmmoId =
                provider.ammos.isNotEmpty ? provider.ammos.first.id : null;
            if (provider.ammos.isEmpty) _ammoSource = 'borrowed';
          }
        }
      });
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
    _borrowedWeaponController.dispose();
    _borrowedAmmoController.dispose();
    _targetNameController.dispose();
    _shotsFiredController.dispose();
    _distanceController.dispose();
    _observationsController.dispose();
    for (var c in _photoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
  Future<void> _pickTargetPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;

      final List<ExercisePhoto> picked = [];

      for (final file in result.files) {
        String? path;

        if (kIsWeb) {
          final bytes = file.bytes;
          if (bytes == null) continue;
          final base64 = base64Encode(bytes);
          path = 'data:image/${file.extension ?? "png"};base64,$base64';
        } else {
          path = file.path;
        }

        if (path == null || path.isEmpty) continue;

        picked.add(
          ExercisePhoto(
            id: DateTime.now().microsecondsSinceEpoch.toString() + file.name,
            name: file.name,
            path: path,
          ),
        );
      }

      if (picked.isEmpty) return;

      for (final photo in picked) {
        _photoControllers[photo.id] = TextEditingController(text: photo.name);
      }

      setState(() {
        _targetPhotos.addAll(picked);
      });
    } catch (e) {
      debugPrint('Target photo pick failed: $e');
    }
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: colors.onSurface,
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      strings.addExerciseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.timer_rounded),
                  color: colors.primary,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ShootingTimerScreen(),
                    );
                  },
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
              controller: _exerciseScrollController,
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
                        strings.exerciseNameLabel,
                        style: textStyles.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.sm),

                  TextField(
                    controller: _exerciseNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: strings.exerciseNameHint,
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
                    ),
                  ),
                  const Gap(AppSpacing.md),

                  // Arme
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/gun.svg',
                        width: 18,
                        height: 18,
                        colorFilter:
                            ColorFilter.mode(colors.primary, BlendMode.srcIn),
                      ),
                      const Gap(8),
                      Text(
                        strings.weaponTitle,
                        style: textStyles.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.sm),
                  _SourceToggleRow(
                    leftLabel: strings.myInventory,
                    rightLabel: strings.borrowed,
                    value: _weaponSource,
                    onChanged: (v) => setState(() {
                      _weaponSource = v;
                      if (_weaponSource == 'borrowed') _selectedWeaponId = null;
                      if (_weaponSource != 'borrowed') {
                        _borrowedWeaponController.text = '';
                      }
                    }),
                  ),
                  const Gap(10),

                      Container(
                        key: _weaponFieldKey,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: _weaponError ? colors.error : Colors.transparent,
                            width: 1.4,
                          ),
                        ),
                        child: _weaponSource == 'inventory'
                            ? (provider.weapons.isEmpty
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
                                            strings.noWeaponInStock,
                                            style: textStyles.bodySmall?.copyWith(
                                              color: colors.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _SelectedSingleItemField(
                                    leading: _selectedWeaponId == null
                                        ? SvgPicture.asset(
                                            'assets/images/gun.svg',
                                            width: 18,
                                            height: 18,
                                            colorFilter: ColorFilter.mode(
                                                colors.primary, BlendMode.srcIn),
                                          )
                                        : Icon(
                                            Icons.radio_button_checked_rounded,
                                            size: 18,
                                            color: colors.primary,
                                          ),
                                    titleWhenEmpty:
                                        strings.chooseWeaponFromInventory,
                                    titleWhenSet: (_selectedWeaponId == null
                                            ? null
                                            : provider.getWeaponById(
                                                _selectedWeaponId!))
                                        ?.name ??
                                        strings.chooseWeaponFromInventory,
                                    subtitle: (_selectedWeaponId == null
                                                ? null
                                                : provider.getWeaponById(
                                                    _selectedWeaponId!)) ==
                                            null
                                        ? null
                                        : strings.tapToChange,
                                    onTap: () async {
                                      if (provider.weapons.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                strings.noWeaponInStockSwitchBorrowed),
                                          ),
                                        );
                                        return;
                                      }
                                      final selected =
                                          await showModalBottomSheet<String>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            _SingleSelectSheet<Weapon>(
                                          title: strings.weaponsTab,
                                          items: provider.weapons,
                                          initialId: _selectedWeaponId,
                                          isLockedItem: (w) {
                                            final idx = provider.weapons.indexOf(w);
                                            return idx >= 0
                                                ? provider.isWeaponLockedForFree(
                                                    w, idx)
                                                : false;
                                          },
                                          iconBuilder: (selected, colors) =>
                                              SvgPicture.asset(
                                            'assets/images/gun.svg',
                                            width: 20,
                                            height: 20,
                                            colorFilter: ColorFilter.mode(
                                              selected
                                                  ? colors.primary
                                                  : colors.outline,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          primaryText: (w) => w.name,
                                          secondaryText: (w) =>
                                              [
                                                strings.itemWeaponTypeLabel(
                                                    w.type),
                                                if (w.model.trim().isNotEmpty)
                                                  w.model,
                                                if (w.caliber.trim().isNotEmpty)
                                                  w.caliber,
                                              ].join(' • '),
                                          matchesQuery: (w, q) {
                                            final qq = q.toLowerCase();
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
                                      if (!mounted || selected == null) return;
                                      setState(() {
                                        _selectedWeaponId = selected;
                                        _weaponError = false;
                                      });
                                    },
                                  ))
                            : TextField(
                                controller: _borrowedWeaponController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: strings.borrowedWeaponOptional,
                                  hintText: strings.borrowedWeaponHint,
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.radio_button_checked_rounded,
                                      size: 18,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(color: colors.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(color: colors.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                      color: colors.primary,
                                      width: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const Gap(AppSpacing.md),

            // Munition
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/bullet.svg',
                  width: 18,
                  height: 18,
                  colorFilter:
                      ColorFilter.mode(colors.primary, BlendMode.srcIn),
                ),
                const Gap(8),
                Text(
                  strings.ammoTitle,
                  style: textStyles.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Gap(AppSpacing.sm),
            _SourceToggleRow(
              leftLabel: strings.myInventory,
              rightLabel: strings.borrowed,
              value: _ammoSource,
              onChanged: (v) => setState(() {
                _ammoSource = v;
                if (_ammoSource == 'borrowed') _selectedAmmoId = null;
                if (_ammoSource != 'borrowed') _borrowedAmmoController.text = '';
              }),
            ),
            const Gap(10),
            Container(
              key: _ammoFieldKey,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: _ammoError ? colors.error : Colors.transparent,
                  width: 1.4,
                ),
              ),
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
                                  style: textStyles.bodySmall?.copyWith(
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
                          titleWhenEmpty: strings.chooseAmmoFromInventory,
                          titleWhenSet: (_selectedAmmoId == null
                                  ? null
                                  : provider.getAmmoById(_selectedAmmoId!))
                              ?.name ??
                              strings.chooseAmmoFromInventory,
                          subtitle: (_selectedAmmoId == null
                                      ? null
                                      : provider.getAmmoById(
                                          _selectedAmmoId!)) ==
                                  null
                              ? null
                              : strings.tapToChange,
                          onTap: () async {
                            if (provider.ammos.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    strings.noAmmoInStockSwitchBorrowed,
                                  ),
                                ),
                              );
                              return;
                            }

                            final selected =
                                await showModalBottomSheet<String>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _SingleSelectSheet<Ammo>(
                                title: strings.ammosTab,
                                items: provider.ammos,
                                initialId: _selectedAmmoId,
                                isLockedItem: (a) {
                                  final idx = provider.ammos.indexOf(a);
                                  return idx >= 0
                                      ? provider.isAmmoLockedForFree(a, idx)
                                      : false;
                                },
                                icon: Icons.trip_origin_rounded,
                                primaryText: (a) => a.name,
                                secondaryText: (a) =>
                                    [
                                      a.caliber,
                                      if (a.brand.trim().isNotEmpty) a.brand,
                                      if (a.projectileType.trim().isNotEmpty)
                                        strings.itemProjectileTypeLabel(
                                          a.projectileType,
                                        ),
                                    ].join(' • '),
                                matchesQuery: (a, q) {
                                  final qq = q.toLowerCase();
                                  return a.name.toLowerCase().contains(qq) ||
                                      a.caliber.toLowerCase().contains(qq) ||
                                      a.brand.toLowerCase().contains(qq) ||
                                      a.projectileType
                                          .toLowerCase()
                                          .contains(qq);
                                },
                                getId: (a) => a.id,
                              ),
                            );

                            if (!mounted || selected == null) return;
                            setState(() {
                              _selectedAmmoId = selected;
                              _ammoError = false;
                            });
                          },
                        ))
                  : TextField(
                      controller: _borrowedAmmoController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: strings.borrowedAmmoOptional,
                        hintText: strings.borrowedAmmoHint,
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
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide(color: colors.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide(color: colors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.6),
                        ),
                      ),
                    ),
            ),
            const Gap(AppSpacing.md),

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
                  strings.usedEquipmentLabel,
                  style: textStyles.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Gap(AppSpacing.sm),
            _SelectedEquipmentField(
              accessories: provider.accessories,
              selectedIds: _selectedEquipmentIds,
              onTap: () => _editEquipments(provider),
              onRemove: (id) =>
                  setState(() => _selectedEquipmentIds.remove(id)),
            ),
            const Gap(AppSpacing.md),

            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: colors.primary,
                ),
                const Gap(8),
                Text(
                  strings.exerciseModeLabel,
                  style: textStyles.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Gap(10),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/hit.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                  colors.primary, BlendMode.srcIn),
                            ),
                            const Gap(8),
                            Text(
                              strings.shotsCountLabel,
                              style: textStyles.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.sm),
                        Container(
                          key: _shotsFieldKey,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: _shotsError
                                  ? colors.error
                                  : Colors.transparent,
                              width: 1.4,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _shotsFiredController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) {
                                  final shots = int.tryParse(
                                      _shotsFiredController.text.trim());
                                  if (_shotsError &&
                                      shots != null &&
                                      shots > 0) {
                                    setState(() => _shotsError = false);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: '0',
                                  errorText: null,
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                      color: colors.primary,
                                      width: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                              if (_shotsError)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      12, 8, 12, 10),
                                  child: Text(
                                    strings.shotsFiredError,
                                    style: textStyles.bodySmall
                                        ?.copyWith(color: colors.error),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.straighten_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.distanceLabel,
                              style: textStyles.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.sm),
                        Container(
                          key: _distanceFieldKey,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: _distanceError
                                  ? colors.error
                                  : Colors.transparent,
                              width: 1.4,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _distanceController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) {
                                  final distance = int.tryParse(
                                      _distanceController.text.trim());
                                  if (_distanceError &&
                                      distance != null &&
                                      distance > 0) {
                                    setState(() => _distanceError = false);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      converter.useMetric ? '25' : '27',
                                  errorText: null,
                                  suffixIcon: Padding(
                                    padding:
                                        const EdgeInsets.only(right: 12),
                                    child: Text(
                                      converter.useMetric ? 'm' : 'yd',
                                      style: textStyles.bodyMedium?.copyWith(
                                        color: colors.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  suffixIconConstraints:
                                      const BoxConstraints(minWidth: 42),
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                      color: colors.primary,
                                      width: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                              if (_distanceError)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      12, 8, 12, 10),
                                  child: Text(
                                    strings.distanceError,
                                    style: textStyles.bodySmall
                                        ?.copyWith(color: colors.error),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (_detailedMode) ...[
              const Gap(AppSpacing.md),
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    colors.primary.withValues(alpha: 0.12),
                    colors.surface,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: 1.1,
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
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: LightColors.surfaceHighlight,
                          width: 1.35,
                        ),
                      ),
                      child: Text(
                        strings.exerciseAutoBadge,
                        style: textStyles.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onPrimary,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.exerciseStepsTitle,
                    style: textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      final step = await showModalBottomSheet<ExerciseStep>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const _AddExerciseStepSheet(),
                      );
                      if (!mounted || step == null) return;
                      setState(() => _steps.add(step));
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(strings.exerciseAddStep),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.sm),
              if (_steps.isEmpty)
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Text(
                    strings.exerciseNoSteps,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.secondary,
                    ),
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
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Row(
                        children: [
                          Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: textStyles.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            _stepIcon(s.type),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _stepTitle(s.type),
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  '${_positionShort(s.position)}${_positionShort(s.position).isEmpty ? '' : ' · '}${_stepSummary(s, strings, provider.useMetric)}',
                                  style: textStyles.bodySmall?.copyWith(
                                    color: colors.secondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              size: 18,
                              color: colors.secondary,
                            ),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final updated = await showModalBottomSheet<ExerciseStep>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _AddExerciseStepSheet(initialStep: s),
                                );
                                if (!mounted || updated == null) return;
                                setState(() {
                                  _steps[i] = updated;
                                });
                              } else if (value == 'duplicate') {
                                setState(() {
                                  final copy = ExerciseStep(
                                    id: DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString(),
                                    type: s.type,
                                    position: s.position,
                                    distanceM: s.distanceM,
                                    shots: s.shots,
                                    target: s.target,
                                    weaponFrom: s.weaponFrom,
                                    weaponTo: s.weaponTo,
                                    reloadType: s.reloadType,
                                    durationSeconds: s.durationSeconds,
                                    trigger: s.trigger,
                                    comment: s.comment,
                                  );
                                  _steps.insert(i + 1, copy);
                                });
                              } else if (value == 'delete') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(strings.confirmDeleteTitle),
                                    content: Text(
                                      strings.exerciseConfirmDeleteStepMessage(
                                        _stepTitle(s.type),
                                      ),
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
                                if (confirmed != true) return;
                                if (!mounted) return;
                                setState(() => _steps.removeAt(i));
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text(strings.edit),
                              ),
                              PopupMenuItem<String>(
                                value: 'duplicate',
                                child: Text(strings.duplicate),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(strings.delete),
                              ),
                            ],
                          ),
                          const Gap(2),
                          ReorderableDragStartListener(
                            index: i,
                            child: Icon(
                              Icons.menu_rounded,
                              color: colors.secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
            const Gap(AppSpacing.md),

            // Cible utilisée
            Row(
              children: [
                Icon(Icons.adjust_rounded, size: 20, color: colors.primary),
                const Gap(8),
                Text(strings.usedTargetLabel,
                    style: textStyles.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const Gap(AppSpacing.sm),
            TextField(
              controller: _targetNameController,
              decoration: InputDecoration(
                hintText: strings.targetNameHint,
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
              ),
            ),
            const Gap(AppSpacing.md),

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
                      strings.targetPhotosTitle,
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _pickTargetPhoto,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(strings.addButton),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: colors.outline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _photoControllers[photo.id],
                                        onChanged: (value) => setState(() {
                                          _renameTargetPhoto(photo.id, value);
                                        }),
                                        decoration: InputDecoration(
                                          labelText: strings.targetPhotoNameLabel,
                                          isDense: true,
                                          filled: true,
                                          fillColor: colors.surface,
                                          suffixIcon: (_photoControllers[photo.id]?.text.trim().isNotEmpty ?? false)
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                                  splashRadius: 18,
                                                  tooltip: strings.clear,
                                                  onPressed: () {
                                                    final c = _photoControllers[photo.id];
                                                    if (c == null) return;
                                                    c.clear();
                                                    _renameTargetPhoto(photo.id, '');
                                                    setState(() {});
                                                  },
                                                )
                                              : null,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            borderSide: BorderSide(color: colors.outline),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            borderSide: BorderSide(color: colors.outline),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            borderSide: BorderSide(color: colors.primary, width: 1.6),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Gap(8),
                                    IconButton(
                                      onPressed: () => _removeTargetPhoto(photo.id),
                                      icon: Icon(
                                        Icons.delete_rounded,
                                        color: colors.error,
                                      ),
                                      tooltip: strings.removePhoto,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                  ],
                                ),
                                const Gap(8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
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

            const Gap(AppSpacing.md),

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
                      strings.measurePrecisionTitle,
                      style: textStyles.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Switch(
                  value: _measurePrecision,
                  onChanged: (val) => setState(() => _measurePrecision = val),
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
                      '${_precision.toStringAsFixed(0)}%'),
                  textAlign: TextAlign.center,
                  style: textStyles.titleMedium?.copyWith(
                      color: colors.primary, fontWeight: FontWeight.bold)),
            ],
            const Gap(AppSpacing.md),

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
                  strings.observationsTitle,
                  style: textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.sm),
            TextField(
              controller: _observationsController,
              maxLines: 3,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: strings.observationsExample,
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
                  borderSide: BorderSide(color: colors.primary, width: 1.6),
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
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.cardPremium,
                      ),
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(strings.saveExerciseButton),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
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
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      side: BorderSide(color: colors.primary, width: 1.6),
                    ),
                    child: Icon(Icons.bookmark_add_outlined, size: 22, color: colors.primary),
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.lg),
          ],
        ),
      ),
    ),
        ],
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
          decoration: InputDecoration(hintText: strings.templateNameHint),
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
              Provider.of<ThotProvider>(context, listen: false)
                  .saveExerciseTemplate(template);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.templateSavedSnack)),
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
    final computedDistance =
        _detailedMode ? _computedMaxDistance() : (distance ?? 0);
    final hasTirStep = _detailedMode &&
        _steps.any((s) => s.type == StepType.tir && (s.shots ?? 0) > 0);

    setState(() {
      _weaponError = _weaponSource == 'inventory' && _selectedWeaponId == null;
      _ammoError = _ammoSource == 'inventory' && _selectedAmmoId == null;
      _shotsError = _detailedMode
          ? (hasTirStep && computedShots <= 0)
          : (shots == null || shots <= 0);
      _distanceError = _detailedMode
          ? (computedDistance <= 0)
          : (distance == null || distance <= 0);
    });

    if (_weaponError) {
      await Scrollable.ensureVisible(
        _weaponFieldKey.currentContext!,
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

    final effectiveWeaponId =
        _weaponSource == 'borrowed' ? 'borrowed' : _selectedWeaponId!;

    final effectiveAmmoId =
        _ammoSource == 'borrowed' ? 'borrowed' : _selectedAmmoId!;

    final effectiveSteps =
        _detailedMode ? List<ExerciseStep>.from(_steps) : null;

    final exercise = Exercise(
      id: widget.exercise?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _exerciseNameController.text.trim(),
      weaponId: effectiveWeaponId,
      weaponLabel:
          effectiveWeaponId == 'borrowed' ? _borrowedWeaponController.text.trim() : null,
      ammoId: effectiveAmmoId,
      ammoLabel: effectiveAmmoId == 'borrowed' ? _borrowedAmmoController.text.trim() : null,
      equipmentIds: _selectedEquipmentIds.toList(),
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
    return _SlidingSegmentedSelector(
      selectedIndex: value == 'borrowed' ? 1 : 0,
      labels: [leftLabel, rightLabel],
      onSelected: (index) {
        onChanged(index == 1 ? 'borrowed' : 'inventory');
      },
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SourceChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border:
                Border.all(color: selected ? colors.primary : colors.outline),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
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
  }) : assert(icon != null || leading != null,
            'Provide either icon or leading');

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
                        child: leading ??
                            Icon(icon!, size: 18, color: colors.primary),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        isEmpty ? titleWhenEmpty : titleWhenSet,
                        style: textStyles.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: colors.outline),
                  ],
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const Gap(6),
                  Text(subtitle!,
                      style: textStyles.bodySmall
                          ?.copyWith(color: colors.secondary)),
                ],
                if (subtitle == null || subtitle!.trim().isEmpty) ...[
                  const Gap(6),
                  Text(strings.tapToChooseFromInventory,
                      style: textStyles.bodySmall
                          ?.copyWith(color: colors.outline)),
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
  }) : assert(icon != null || iconBuilder != null,
            'Provide either icon or iconBuilder');

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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
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
                    child: Text(widget.title,
                        style: textStyles.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900)),
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
                style: textStyles.bodyMedium?.copyWith(
                  fontSize: 14,
                ),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: strings.sessionsSearchHint,
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
                      child: Text(strings.noResults,
                          style: textStyles.bodyMedium
                              ?.copyWith(color: colors.secondary)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Gap(6),
                      itemBuilder: (context, index) {
                        final it = filtered[index];
                        final id = widget.getId(it);
                        final selected = _selection == id;
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
                                      splashFactory: NoSplash.splashFactory),
                                  child: RadioListTile<String>(
                                    value: id,
                                    groupValue: _selection,
                                    onChanged: isLocked
                                        ? null
                                        : (v) => setState(() => _selection = v),
                                    activeColor: colors.primary,
                                    title: Text(widget.primaryText(it),
                                        style: textStyles.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                    subtitle: Text(
                                      widget.secondaryText(it),
                                      style: textStyles.bodySmall
                                          ?.copyWith(color: colors.secondary),
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
                                        horizontal: 8, vertical: 4),
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
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
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
                      onPressed: canValidate ? () => context.pop(_selection) : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        disabledBackgroundColor:
                            colors.outline.withValues(alpha: 0.18),
                        disabledForegroundColor:
                            colors.outline.withValues(alpha: 0.85),
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
  final VoidCallback onTap;
  final ValueChanged<String> onRemove;

  const _SelectedEquipmentField({
    required this.accessories,
    required this.selectedIds,
    required this.onTap,
    required this.onRemove,
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
                        style: textStyles.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: colors.outline),
                  ],
                ),
                if (selected.isNotEmpty) ...[
                  const Gap(10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected
                        .map(
                          (a) => InputChip(
                            label:
                                Text(a.name, overflow: TextOverflow.ellipsis),
                            onDeleted: () => onRemove(a.id),
                            deleteIcon: Icon(Icons.close_rounded,
                                size: 18, color: colors.onSurface),
                            backgroundColor: colors.surface,
                            shape: StadiumBorder(
                                side: BorderSide(color: colors.outline)),
                            labelStyle: textStyles.labelLarge
                                ?.copyWith(color: colors.onSurface),
                          ),
                        )
                        .toList(),
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
                          style: textStyles.bodySmall
                              ?.copyWith(color: colors.outline),
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

  const _AddExerciseStepSheet({this.initialStep});

  @override
  State<_AddExerciseStepSheet> createState() => _AddExerciseStepSheetState();
}

class _AddExerciseStepSheetState extends State<_AddExerciseStepSheet> {
  StepType _type = StepType.tir;
  ShootingPosition? _position;

  final _distanceController = TextEditingController();
  final _shotsController = TextEditingController();
  final _targetController = TextEditingController();
  final _weaponFromController = TextEditingController();
  final _weaponToController = TextEditingController();
  ReloadType? _reloadType;
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
                      decoration: decoration('${strings.exerciseFieldShots}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration('${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _targetController,
                      decoration: decoration('${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.deplacement) ...[
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration('${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.rechargement) ...[
                    Text(
                      strings.exerciseFieldReloadType,
                      style: textStyles.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
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
                              color:
                                  selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ] else if (_type == StepType.transition) ...[
                    TextField(
                      controller: _weaponFromController,
                      decoration: decoration('${strings.exerciseFieldWeaponFrom}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _weaponToController,
                      decoration: decoration('${strings.exerciseFieldWeaponTo}${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.miseEnJoue) ...[
                    TextField(
                      controller: _targetController,
                      decoration: decoration('${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration('${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.attente) ...[
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: decoration('${strings.exerciseFieldDuration} (s)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration('${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _triggerController,
                      decoration: decoration('${strings.exerciseFieldTrigger}${strings.exerciseOptionalHint}'),
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

  const _EquipmentMultiSelectSheet(
      {required this.accessories, required this.initialSelection});

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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
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
                    child: Text(strings.equipmentsTitle,
                        style: textStyles.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900)),
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
                style: textStyles.bodyMedium?.copyWith(
                  fontSize: 14,
                ),
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
                      child: Text(strings.noEquipmentFound,
                          style: textStyles.bodyMedium
                              ?.copyWith(color: colors.secondary)),
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
                                      splashFactory: NoSplash.splashFactory),
                                  child: ListTile(
                                    enabled: !isLocked,
                                    leading: Icon(
                                      selected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_unchecked_rounded,
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
                                        if (a.model.trim().isNotEmpty) a.model
                                      ].join(' • '),
                                      style: textStyles.bodySmall
                                          ?.copyWith(color: colors.secondary),
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
                                        horizontal: 8, vertical: 4),
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
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
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
                      onPressed:
                          canValidate ? () => context.pop(_selection) : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        disabledBackgroundColor:
                            colors.outline.withValues(alpha: 0.18),
                        disabledForegroundColor:
                            colors.outline.withValues(alpha: 0.85),
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

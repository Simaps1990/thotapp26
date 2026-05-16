import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models.dart';
import '../data/thot_provider.dart';
import '../l10n/app_strings.dart';
import 'pdf_export_options.dart';
import 'document_hash.dart';
import 'platform_history_label.dart';

/// Génère et partage un PDF complet avec toutes les données THOT.
/// Fonctionnalité réservée aux abonnés Pro.
class PdfExporter {
  static final _dfFile = DateFormat('yyyyMMdd');

  // Couleurs
  static const _headerBg = PdfColor.fromInt(0xFF505136);
  static const _sectionBg = PdfColor.fromInt(0xFF505136);
  static const _accent = PdfColor.fromInt(0xFFC5B987);
  static const _surface = PdfColor.fromInt(0xFFF7F4EA);
  static const _cardBorder = PdfColor.fromInt(0xFFD9D1B8);
  static const _textDark = PdfColor.fromInt(0xFF202114);
  static const _textMuted = PdfColor.fromInt(0xFF77725F);
  static const _white = PdfColors.white;

  // Styles
  static pw.TextStyle _bold(double size, {PdfColor? color}) => pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: size,
    color: color,
  );
  static pw.TextStyle _normal(double size, {PdfColor? color}) =>
      pw.TextStyle(fontSize: size, color: color);
  static String _emptyIfMissing(String value) =>
      value.trim().isEmpty ? '' : value;
  static String _logoSvgWhite(String svg) {
    final converted = svg
        .replaceAll(
          RegExp(r'fill="#000000"', caseSensitive: false),
          'fill="#FFFFFF"',
        )
        .replaceAll(
          RegExp(r'fill="#000"', caseSensitive: false),
          'fill="#FFFFFF"',
        )
        .replaceAll(
          RegExp(r'fill="black"', caseSensitive: false),
          'fill="#FFFFFF"',
        )
        .replaceAll(
          RegExp(r'fill: ?#000000', caseSensitive: false),
          'fill:#FFFFFF',
        )
        .replaceAll(
          RegExp(r'fill: ?#000', caseSensitive: false),
          'fill:#FFFFFF',
        );
    if (converted.contains(RegExp(r'fill=', caseSensitive: false))) {
      return converted;
    }
    return converted.replaceFirst('<svg', '<svg fill="#FFFFFF"');
  }

  // ─── Widget helpers ─────────────────────────────────────────────────────────

  static pw.Widget _header(
    pw.Context ctx,
    String title,
    String localeTag, {
    String? logoSvg,
  }) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _cardBorder, width: 0.5)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            if (logoSvg != null)
              pw.SvgImage(svg: logoSvg, width: 30, height: 14)
            else
              pw.Text('THOT', style: _bold(9, color: _sectionBg)),
            pw.SizedBox(width: 8),
            pw.Container(width: 1, height: 12, color: _cardBorder),
            pw.SizedBox(width: 8),
            pw.Text(title, style: _normal(8, color: _textMuted)),
          ],
        ),
        pw.Text(
          '${_label('Page', localeTag)} ${ctx.pageNumber}',
          style: _normal(8, color: _textMuted),
        ),
      ],
    ),
  );

  static pw.Widget _footer(String localeTag, {String? hashPrefix}) =>
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _cardBorder, width: 0.5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              _footerLabel(localeTag, _formatDateShort(localeTag)),
              style: _normal(7, color: _textMuted),
            ),
          ],
        ),
      );

  static String _formatDateShort(String localeTag) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', localeTag);
    return dateFormat.format(now);
  }

  static String _footerLabel(String localeTag, String dateShort) {
    final strings = AppStrings.forLocale(Locale(localeTag));
    return strings.pdfFooterLabel(dateShort);
  }

  static pw.Widget _sectionTitle(String text) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 12),
    decoration: pw.BoxDecoration(
      color: _sectionBg,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Text(text, style: _bold(11, color: _white)),
  );

  static pw.Widget _field(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 94,
          child: pw.Text(label, style: _bold(8, color: _textMuted)),
        ),
        pw.Expanded(child: pw.Text(value, style: _normal(8))),
      ],
    ),
  );

  static pw.Widget _inlineField(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: _bold(8, color: _textMuted)),
        pw.SizedBox(width: 6),
        pw.Text(value, style: _normal(8)),
      ],
    ),
  );

  static pw.Widget _statBox(String label, String value) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _surface,
        border: pw.Border.all(color: _cardBorder, width: 0.4),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: _normal(7.5, color: _textMuted)),
          pw.SizedBox(height: 3),
          pw.Text(value, style: _bold(14, color: _textDark)),
        ],
      ),
    ),
  );

  static pw.Widget _card(pw.Widget child) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      border: pw.Border.all(color: _cardBorder, width: 0.6),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: child,
  );

  // ─── Localization helpers ─────────────────────────────────────────────────────

  static String _label(String key, String localeTag) {
    final strings = AppStrings.forLocale(Locale(localeTag));
    return strings.pdfLabel(key);
  }

  static String _pluralize(String singular, int count, String localeTag) {
    if (count == 1) return singular;
    switch (singular) {
      case 'plateforme': return _label('plateformes', localeTag);
      case 'consommable': return _label('consommables', localeTag);
      case 'accessoire': return _label('accessoires', localeTag);
      case 'session': return _label('sessions', localeTag);
      default: return singular + 's';
    }
  }

  // ─── Entry point ────────────────────────────────────────────────────────────

  /// Build export data for hash computation.
  static Map<String, dynamic> _buildExportData(
    ThotProvider provider,
    PdfExportOptions options,
  ) {
    final data = <String, dynamic>{
      'exportDate': DateTime.now().toIso8601String(),
      'userName': provider.userName,
      'licenseNumber': provider.licenseNumber,
    };

    if (options.includePlatforms && provider.platforms.isNotEmpty) {
      data['platforms'] = provider.platforms
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'type': p.type,
              'model': p.model,
              'caliber': p.caliber,
              'serialNumber': p.serialNumber,
              'weight': p.weight,
              'totalRounds': p.totalRounds,
              'cleaningProgress': p.cleaningProgress,
              'roundsSinceCleaning': p.roundsSinceCleaning,
              'revisionProgress': p.revisionProgress,
              'roundsSinceRevision': p.roundsSinceRevision,
              'lastUsed': p.lastUsed?.toIso8601String(),
              'comment': p.comment,
              'history': p.history
                  .map(
                    (h) => {
                      'date': h.date.toIso8601String(),
                      'type': h.type,
                      'label': h.label,
                    },
                  )
                  .toList(),
            },
          )
          .toList();
    }

    if (options.includeAmmos && provider.ammos.isNotEmpty) {
      data['ammos'] = provider.ammos
          .map(
            (a) => {
              'id': a.id,
              'name': a.name,
              'brand': a.brand,
              'caliber': a.caliber,
              'projectileType': a.projectileType,
              'quantity': a.quantity,
              'lowStockThreshold': a.lowStockThreshold,
              'lastUsed': a.lastUsed?.toIso8601String(),
              'comment': a.comment,
            },
          )
          .toList();
    }

    if (options.includeAccessories && provider.accessories.isNotEmpty) {
      data['accessories'] = provider.accessories
          .map(
            (ac) => {
              'id': ac.id,
              'name': ac.name,
              'type': ac.type,
              'brand': ac.brand,
              'model': ac.model,
              'totalRounds': ac.totalRounds,
              'trackBattery': ac.trackBattery,
              'batteryChangedAt': ac.batteryChangedAt?.toIso8601String(),
              'lastUsed': ac.lastUsed?.toIso8601String(),
              'comment': ac.comment,
            },
          )
          .toList();
    }

    if (options.includeSessions && provider.sessions.isNotEmpty) {
      data['sessions'] = provider.sessions
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'date': s.date.toIso8601String(),
              'location': s.location,
              'averagePrecision': s.averagePrecision,
              'shootingDistance': s.shootingDistance,
              'temperature': s.temperature,
              'wind': s.wind,
              'humidity': s.humidity,
              'pressure': s.pressure,
              'exercises': s.exercises
                  .map(
                    (e) => {
                      'id': e.id,
                      'platformId': e.platformId,
                      'ammoId': e.ammoId,
                      'shotsFired': e.shotsFired,
                      'distance': e.distance,
                      'precision': e.precision,
                      'targetName': e.targetName,
                      'observations': e.observations,
                    },
                  )
                  .toList(),
            },
          )
          .toList();
    }

    return data;
  }

  static Future<void> exportAll(
    ThotProvider provider, {
    PdfExportOptions options = const PdfExportOptions(),
  }) async {
    if (!provider.isPremium) {
      throw Exception('Premium required');
    }
    final now = DateTime.now();
    final filename = 'THOT_Export_${_dfFile.format(now)}.pdf';
    final localeTag = (provider.appLocale ?? const Locale('fr'))
        .toLanguageTag();
    final exportDate = _formatDateForLocaleTag(localeTag, now);
    final logoSvg = await rootBundle.loadString('assets/images/LOGO.svg');

    // Compute hash if authentication is enabled
    String? hash;
    if (options.includeAuth) {
      final data = _buildExportData(provider, options);
      hash = DocumentHash.compute(data);
    }

    final doc = pw.Document(
      title: filename,
      author: provider.userName.isEmpty ? 'THOT' : provider.userName,
      subject: hash != null ? 'Hash: $hash' : null,
      keywords: hash != null ? 'thot,carnet-tir,hash:$hash' : 'thot,carnet-tir',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(34, 28, 34, 28),
        header: (ctx) => ctx.pageNumber == 1
            ? pw.SizedBox()
            : _header(
                ctx,
                _label('Carnet de Tir Numérique', localeTag),
                localeTag,
                logoSvg: logoSvg,
              ),
        footer: (ctx) => _footer(
          localeTag,
          hashPrefix: hash != null ? hash.substring(0, 8) : null,
        ),
        build: (_) => [
          _coverBlock(provider, exportDate, localeTag, _logoSvgWhite(logoSvg)),
          if (options.includePlatforms && provider.platforms.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _sectionTitle(
              '${_label('PLATEFORMES', localeTag)}  (${provider.platforms.length})',
            ),
            pw.SizedBox(height: 8),
            for (final w in provider.platforms) ...[
              _card(_platformContent(w, localeTag)),
              pw.SizedBox(height: 8),
            ],
          ],
          if (options.includeAmmos && provider.ammos.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _sectionTitle(
              '${_label('CONSOMMABLES', localeTag)}  (${provider.ammos.length})',
            ),
            pw.SizedBox(height: 8),
            for (final a in provider.ammos) ...[
              _card(_ammoContent(a, localeTag)),
              pw.SizedBox(height: 8),
            ],
          ],
          if (options.includeAccessories &&
              provider.accessories.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _sectionTitle(
              '${_label('ACCESSOIRES', localeTag)}  (${provider.accessories.length})',
            ),
            pw.SizedBox(height: 8),
            for (final ac in provider.accessories) ...[
              _card(_accessoryContent(ac, localeTag)),
              pw.SizedBox(height: 8),
            ],
          ],
          if (options.includeSessions && provider.sessions.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _sectionTitle(
              '${_label('SESSIONS DE TIR', localeTag)}  (${provider.sessions.length})',
            ),
            pw.SizedBox(height: 8),
            for (final s in provider.sessions) ...[
              _card(_sessionContent(s, provider, localeTag)),
              pw.SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ─── Cover page ─────────────────────────────────────────────────────────────

  static pw.Widget _coverBlock(
    ThotProvider provider,
    String exportDate,
    String localeTag,
    String logoSvg,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: const pw.BoxDecoration(
          color: _headerBg,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SvgImage(svg: logoSvg, width: 88, height: 34),
                pw.SizedBox(height: 8),
                pw.Text(
                  _label('Carnet de Tir Numérique', localeTag),
                  style: _bold(12, color: _white),
                ),
              ],
            ),
            pw.Container(width: 54, height: 4, color: _accent),
          ],
        ),
      ),
      pw.SizedBox(height: 18),
      pw.Text(
        _label('Export complet des données', localeTag),
        style: _bold(18, color: _textDark),
      ),
      pw.SizedBox(height: 12),
      if (provider.userName.isNotEmpty)
        _field(_label('Tireur', localeTag), provider.userName),
      if (provider.licenseNumber.isNotEmpty)
        _field(_label('Licence', localeTag), provider.licenseNumber),
      _inlineField(_label("Date d'export", localeTag), exportDate),
      pw.SizedBox(height: 14),
      pw.Divider(color: _cardBorder, height: 1),
      pw.SizedBox(height: 12),
      pw.Text(
        _label('SOMMAIRE', localeTag),
        style: _bold(11, color: _sectionBg),
      ),
      pw.SizedBox(height: 6),
      _summaryLine(
        '${provider.platforms.length} ${_pluralize('plateforme', provider.platforms.length, localeTag)}',
      ),
      _summaryLine(
        '${provider.ammos.length} ${_pluralize('consommable', provider.ammos.length, localeTag)}',
      ),
      _summaryLine(
        '${provider.accessories.length} ${_pluralize('accessoire', provider.accessories.length, localeTag)}',
      ),
      _summaryLine(
        '${provider.sessions.length} ${_pluralize('session', provider.sessions.length, localeTag)} - ${provider.totalRoundsFired} ${_label('coups au total', localeTag)}',
      ),
      pw.SizedBox(height: 14),
      pw.Divider(color: _cardBorder, height: 1),
      pw.SizedBox(height: 12),
      pw.Text(
        _label('STATISTIQUES', localeTag),
        style: _bold(11, color: _sectionBg),
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          _statBox(_label('Sessions', localeTag), '${provider.totalSessions}'),
          pw.SizedBox(width: 10),
          _statBox(
            _label('Coups tirés', localeTag),
            '${provider.totalRoundsFired}',
          ),
          pw.SizedBox(width: 10),
          _statBox(
            _label('Plateformes', localeTag),
            '${provider.platforms.length}',
          ),
        ],
      ),
    ],
  );

  static pw.Widget _summaryLine(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Text(text, style: _normal(10)),
  );

  static String _formatDateForLocaleTag(String localeTag, DateTime date) {
    final dateFormat = DateFormat('d MMMM yyyy', localeTag);
    final value = dateFormat.format(date);
    return value.replaceFirstMapped(
      RegExp(r'[A-Za-zÀ-ÿ]'),
      (match) => match.group(0)!.toUpperCase(),
    );
  }

  // ─── Platform block ────────────────────────────────────────────────────────────

  static pw.Widget _platformContent(Platform w, String localeTag) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(w.name, style: _bold(12)),
      pw.SizedBox(height: 2),
      pw.Text(w.type, style: _normal(8.5, color: _textMuted)),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _field(_label('Modèle', localeTag), _emptyIfMissing(w.model)),
                _field(
                  _label('Calibre', localeTag),
                  _emptyIfMissing(w.caliber),
                ),
                _field(
                  _label('N° de série', localeTag),
                  _emptyIfMissing(w.serialNumber),
                ),
                _field(
                  _label('Poids', localeTag),
                  '${w.weight.toStringAsFixed(0)} g',
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _field(_label('Total coups', localeTag), '${w.totalRounds}'),
                _field(
                  _label('Entretien', localeTag),
                  '${(w.cleaningProgress * 100).toInt()}%  (${w.roundsSinceCleaning} coups)',
                ),
                _field(
                  _label('Révision', localeTag),
                  '${(w.revisionProgress * 100).toInt()}%  (${w.roundsSinceRevision} coups)',
                ),
                _field(
                  _label('Dernière utilisation', localeTag),
                  w.lastUsed != null
                      ? _formatDateForLocaleTag(localeTag, w.lastUsed!)
                      : _label('Jamais utilisé', localeTag),
                ),
              ],
            ),
          ),
        ],
      ),
      if (w.comment.isNotEmpty) ...[
        pw.SizedBox(height: 6),
        _field(_label('Note', localeTag), w.comment),
      ],
      if (w.history.isNotEmpty) ...[
        pw.SizedBox(height: 8),
        pw.Text(
          '${_label('Historique', localeTag)} (${w.history.length} ${_label('entrées', localeTag)})',
          style: _bold(8.5),
        ),
        pw.SizedBox(height: 4),
        for (final h in w.history.take(8))
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Row(
              children: [
                pw.Text(
                  _formatDateForLocaleTag(localeTag, h.date),
                  style: _normal(7.5, color: _textMuted),
                ),
                pw.SizedBox(width: 8),
                pw.Text('[${h.type}]', style: _bold(7.5)),
                pw.SizedBox(width: 6),
                pw.Expanded(child: pw.Text(h.label, style: _normal(7.5))),
              ],
            ),
          ),
        if (w.history.length > 8)
          pw.Text(
            'et ${w.history.length - 8} ${_label('autres entrées', localeTag)}',
            style: _normal(7.5, color: _textMuted),
          ),
      ],
    ],
  );

  // ─── Ammo block ─────────────────────────────────────────────────────────────

  static pw.Widget _ammoContent(Ammo a, String localeTag) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(a.name, style: _bold(11)),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _field(_label('Marque', localeTag), _emptyIfMissing(a.brand)),
                _field(
                  _label('Calibre', localeTag),
                  _emptyIfMissing(a.caliber),
                ),
                _field(
                  _label('Projectile', localeTag),
                  _emptyIfMissing(a.projectileType),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _field(
                  _label('Stock actuel', localeTag),
                  '${a.quantity} ${_label('consommables', localeTag)}',
                ),
                _field(
                  _label("Seuil d'alerte", localeTag),
                  '${a.lowStockThreshold} ${_label('consommables', localeTag)}',
                ),
                _field(
                  _label('Dernière utilisation', localeTag),
                  a.lastUsed != null
                      ? _formatDateForLocaleTag(localeTag, a.lastUsed!)
                      : _label('Jamais utilisé', localeTag),
                ),
              ],
            ),
          ),
        ],
      ),
      if (a.comment.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        _field(_label('Note', localeTag), a.comment),
      ],
    ],
  );

  // ─── Accessory block ─────────────────────────────────────────────────────────

  static pw.Widget _accessoryContent(
    Accessory ac,
    String localeTag,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(ac.name, style: _bold(11)),
      pw.SizedBox(height: 8),
      _field(_label('Type', localeTag), _emptyIfMissing(ac.type)),
      if (ac.brand.isNotEmpty) _field(_label('Marque', localeTag), ac.brand),
      if (ac.model.isNotEmpty) _field(_label('Modèle', localeTag), ac.model),
      _field(_label('Total coups', localeTag), '${ac.totalRounds}'),
      if (ac.trackBattery && ac.batteryChangedAt != null)
        _field(
          _label('Dernière pile', localeTag),
          _formatDateForLocaleTag(localeTag, ac.batteryChangedAt!),
        ),
      _field(
        _label('Dernière utilisation', localeTag),
        ac.lastUsed != null
            ? _formatDateForLocaleTag(localeTag, ac.lastUsed!)
            : _label('Jamais utilisé', localeTag),
      ),
      if (ac.comment.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        _field(_label('Note', localeTag), ac.comment),
      ],
    ],
  );

  // ─── Session block ───────────────────────────────────────────────────────────

  static pw.Widget _sessionContent(
    Session s,
    ThotProvider provider,
    String localeTag,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(s.name, style: _bold(11))),
          pw.Text(
            _formatDateForLocaleTag(localeTag, s.date),
            style: _normal(8.5, color: _textMuted),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _field(_label('Lieu', localeTag), _emptyIfMissing(s.location)),
                _field(_label('Type', localeTag), s.sessionType),
                _field(_label('Total coups', localeTag), '${s.totalRounds}'),
                if (s.hasCountedPrecision)
                  _field(
                    _label('Précision moy.', localeTag),
                    '${s.averagePrecision.toStringAsFixed(1)} %',
                  ),
                if (s.shootingDistance != null &&
                    s.shootingDistance!.isNotEmpty)
                  _field(_label('Pas de tir', localeTag), s.shootingDistance!),
              ],
            ),
          ),
          if (s.weatherEnabled)
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (s.temperatureEnabled && s.temperature.isNotEmpty)
                    _field(_label('Température', localeTag), s.temperature),
                  if (s.windEnabled && s.wind.isNotEmpty)
                    _field(_label('Vent', localeTag), s.wind),
                  if (s.humidityEnabled && s.humidity.isNotEmpty)
                    _field(_label('Humidité', localeTag), s.humidity),
                  if (s.pressureEnabled && s.pressure.isNotEmpty)
                    _field(_label('Pression', localeTag), s.pressure),
                ],
              ),
            ),
        ],
      ),
      if (s.exercises.isNotEmpty) ...[
        pw.SizedBox(height: 8),
        pw.Text(
          '${_label('Exercices', localeTag)} (${s.exercises.length})',
          style: _bold(9, color: _sectionBg),
        ),
        pw.SizedBox(height: 4),
        for (final e in s.exercises)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF5F5F5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (e.name.isNotEmpty) pw.Text(e.name, style: _bold(9)),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _field(
                            _label('Plateforme', localeTag),
                            e.platformLabel ??
                                (provider.getPlatformById(e.platformId)?.name ??
                                    e.platformId),
                          ),
                          _field(
                            _label('Consommable', localeTag),
                            e.ammoLabel ??
                                (provider.getAmmoById(e.ammoId)?.name ??
                                    e.ammoId),
                          ),
                          _field(
                            _label('Coups tirés', localeTag),
                            '${e.shotsFired}',
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _field(
                            _label('Distance', localeTag),
                            '${e.distance} m',
                          ),
                          if (e.isPrecisionCounted)
                            _field(
                              _label('Précision', localeTag),
                              '${e.precision!.toStringAsFixed(1)} %',
                            ),
                          if (e.targetName != null && e.targetName!.isNotEmpty)
                            _field(_label('Cible', localeTag), e.targetName!),
                        ],
                      ),
                    ),
                  ],
                ),
                if (e.observations.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  _field(_label('Observations', localeTag), e.observations),
                ],
              ],
            ),
          ),
      ],
    ],
  );
}

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models.dart';
import '../data/thot_provider.dart';
import 'pdf_export_options.dart';
/// Génère et partage un PDF complet avec toutes les données THOT.
/// Fonctionnalité réservée aux abonnés Pro.
class PdfExporter {
  static final _dfFile = DateFormat('yyyyMMdd');

  // Couleurs
  static const _headerBg = PdfColor.fromInt(0xFF263238); // blueGrey 900
  static const _sectionBg = PdfColor.fromInt(0xFF37474F); // blueGrey 800
  static const _cardBorder = PdfColor.fromInt(0xFFB0BEC5); // blueGrey 200
  static const _textMuted = PdfColor.fromInt(0xFF78909C); // blueGrey 400
  static const _white = PdfColors.white;

  // Styles
  static pw.TextStyle _bold(double size, {PdfColor? color}) =>
      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: size, color: color);
  static pw.TextStyle _normal(double size, {PdfColor? color}) =>
      pw.TextStyle(fontSize: size, color: color);

  // ─── Widget helpers ─────────────────────────────────────────────────────────

  static pw.Widget _header(pw.Context ctx, String title) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _cardBorder, width: 0.5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('THOT — $title', style: _normal(8, color: _textMuted)),
            pw.Text('Page ${ctx.pageNumber}', style: _normal(8, color: _textMuted)),
          ],
        ),
      );

  static pw.Widget _sectionTitle(String text) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 12),
        decoration: pw.BoxDecoration(
          color: _sectionBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(text, style: _bold(12, color: _white)),
      );

  static pw.Widget _field(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(label, style: _bold(8.5, color: _textMuted)),
          ),
          pw.Expanded(child: pw.Text(value, style: _normal(8.5))),
        ]),
      );

  static pw.Widget _statBox(String label, String value) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFECEFF1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: _normal(7.5, color: _textMuted)),
              pw.SizedBox(height: 3),
              pw.Text(value, style: _bold(15)),
            ],
          ),
        ),
      );

  static pw.Widget _card(pw.Widget child) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _cardBorder, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: child,
      );

  // ─── Entry point ────────────────────────────────────────────────────────────

static Future<void> exportAll(ThotProvider provider, {PdfExportOptions options = const PdfExportOptions()}) async {
      if (!provider.isPremium) {
      throw Exception('Premium required');
    }
    final now = DateTime.now();
    final filename = 'THOT_Export_${_dfFile.format(now)}.pdf';
    final localeTag = (provider.appLocale ?? const Locale('fr')).toLanguageTag();
    final exportDate = _formatDateForLocaleTag(localeTag, now);
    
    final doc = pw.Document(
      title: filename,
      author: provider.userName.isEmpty ? 'THOT' : provider.userName,
    );

    // 1. Page de couverture
    doc.addPage(_coverPage(provider, exportDate));

// 2. Armes
    if (options.includeWeapons && provider.weapons.isNotEmpty) {
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => _header(ctx, 'ARMES'),
        build: (_) => [
          _sectionTitle('ARMES  (${provider.weapons.length})'),
          pw.SizedBox(height: 14),
          for (final w in provider.weapons) ...[
            _card(_weaponContent(w, localeTag)),
            pw.SizedBox(height: 14),
          ],
        ],
      ));
    }

    // 3. Munitions
if (options.includeAmmos && provider.ammos.isNotEmpty) {
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => _header(ctx, 'MUNITIONS'),
        build: (_) => [
          _sectionTitle('MUNITIONS  (${provider.ammos.length})'),
          pw.SizedBox(height: 14),
          for (final a in provider.ammos) ...[
            _card(_ammoContent(a, localeTag)),
            pw.SizedBox(height: 10),
          ],
        ],
      ));
    }

    // 4. Accessoires
if (options.includeAccessories && provider.accessories.isNotEmpty) {
        doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => _header(ctx, 'ACCESSOIRES'),
        build: (_) => [
          _sectionTitle('ACCESSOIRES  (${provider.accessories.length})'),
          pw.SizedBox(height: 14),
          for (final ac in provider.accessories) ...[
            _card(_accessoryContent(ac, localeTag)),
            pw.SizedBox(height: 10),
          ],
        ],
      ));
    }

    // 5. Séances
if (options.includeSessions && provider.sessions.isNotEmpty) {
        doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => _header(ctx, 'SÉANCES'),
        build: (_) => [
          _sectionTitle('SÉANCES DE TIR  (${provider.sessions.length})'),
          pw.SizedBox(height: 14),
          for (final s in provider.sessions) ...[
            _card(_sessionContent(s, provider, localeTag)),
            pw.SizedBox(height: 14),
          ],
        ],
      ));
    }

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }

  // ─── Cover page ─────────────────────────────────────────────────────────────

  static pw.Page _coverPage(ThotProvider provider, String exportDate) => pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Bandeau haut
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
              color: _headerBg,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('THOT', style: _bold(40, color: _white)),
                pw.SizedBox(height: 6),
                pw.Text('Carnet de Tir Numérique', style: _normal(14, color: _white)),
              ]),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Export complet des données', style: _bold(18)),
                pw.SizedBox(height: 20),
                if (provider.userName.isNotEmpty)
                  _field('Tireur', provider.userName),
                if (provider.licenseNumber.isNotEmpty)
                  _field('Licence', provider.licenseNumber),
                _field("Date d'export", exportDate),
                pw.SizedBox(height: 24),
                pw.Divider(color: _cardBorder, height: 1),
                pw.SizedBox(height: 20),
                // Sommaire
                pw.Text('SOMMAIRE', style: _bold(11, color: _sectionBg)),
                pw.SizedBox(height: 10),
                _summaryLine('${provider.weapons.length} arme${provider.weapons.length != 1 ? "s" : ""}'),
                _summaryLine('${provider.ammos.length} munition${provider.ammos.length != 1 ? "s" : ""}'),
                _summaryLine('${provider.accessories.length} accessoire${provider.accessories.length != 1 ? "s" : ""}'),
                _summaryLine('${provider.sessions.length} séance${provider.sessions.length != 1 ? "s" : ""} — ${provider.totalRoundsFired} coups au total'),
                pw.SizedBox(height: 24),
                pw.Divider(color: _cardBorder, height: 1),
                pw.SizedBox(height: 20),
                // Stats rapides
                pw.Text('STATISTIQUES', style: _bold(11, color: _sectionBg)),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  _statBox('Séances', '${provider.totalSessions}'),
                  pw.SizedBox(width: 10),
                  _statBox('Coups tirés', '${provider.totalRoundsFired}'),
                  pw.SizedBox(width: 10),
                  _statBox('Armes', '${provider.weapons.length}'),
                ]),
              ]),
            ),
          ],
        ),
      );

  static pw.Widget _summaryLine(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(children: [
          pw.Container(
            width: 5, height: 5,
            decoration: const pw.BoxDecoration(
              color: _sectionBg,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(text, style: _normal(10)),
        ]),
      );

  static String _formatDateForLocaleTag(String localeTag, DateTime date) {
    final dateFormat = DateFormat('d MMMM yyyy', localeTag);
    final value = dateFormat.format(date);
    return value.replaceFirstMapped(
      RegExp(r'[A-Za-zÀ-ÿ]'),
      (match) => match.group(0)!.toUpperCase(),
    );
  }

  // ─── Weapon block ────────────────────────────────────────────────────────────

  static pw.Widget _weaponContent(Weapon w, String localeTag) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(w.name, style: _bold(12)),
          pw.SizedBox(height: 2),
          pw.Text(w.type, style: _normal(8.5, color: _textMuted)),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _field('Modèle', w.model.isEmpty ? '—' : w.model),
              _field('Calibre', w.caliber.isEmpty ? '—' : w.caliber),
              _field('N° de série', w.serialNumber.isEmpty ? '—' : w.serialNumber),
              _field('Poids', '${w.weight.toStringAsFixed(0)} g'),
            ])),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _field('Total coups', '${w.totalRounds}'),
              _field('Entretien', '${(w.cleaningProgress * 100).toInt()}%  (${w.roundsSinceCleaning} coups)'),
              _field('Révision', '${(w.revisionProgress * 100).toInt()}%  (${w.roundsSinceRevision} coups)'),
              _field('Dernière utilisation', _formatDateForLocaleTag(localeTag, w.lastUsed)),
            ])),
          ]),
          if (w.comment.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            _field('Note', w.comment),
          ],
          if (w.history.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Historique (${w.history.length} entrées)', style: _bold(8.5)),
            pw.SizedBox(height: 4),
            for (final h in w.history.take(8))
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1),
                child: pw.Row(children: [
                  pw.Text(_formatDateForLocaleTag(localeTag, h.date), style: _normal(7.5, color: _textMuted)),
                  pw.SizedBox(width: 8),
                  pw.Text('[${h.type}]', style: _bold(7.5)),
                  pw.SizedBox(width: 6),
                  pw.Expanded(child: pw.Text(h.label, style: _normal(7.5))),
                ]),
              ),
            if (w.history.length > 8)
              pw.Text('… et ${w.history.length - 8} autres entrées',
                  style: _normal(7.5, color: _textMuted)),
          ],
        ],
      );

  // ─── Ammo block ─────────────────────────────────────────────────────────────

  static pw.Widget _ammoContent(Ammo a, String localeTag) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(a.name, style: _bold(11)),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _field('Marque', a.brand.isEmpty ? '—' : a.brand),
              _field('Calibre', a.caliber.isEmpty ? '—' : a.caliber),
              _field('Projectile', a.projectileType.isEmpty ? '—' : a.projectileType),
            ])),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _field('Stock actuel', '${a.quantity} munitions'),
              _field("Seuil d'alerte", '${a.lowStockThreshold} munitions'),
              _field('Dernière utilisation', _formatDateForLocaleTag(localeTag, a.lastUsed)),
            ])),
          ]),
          if (a.comment.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            _field('Note', a.comment),
          ],
        ],
      );

  // ─── Accessory block ─────────────────────────────────────────────────────────

  static pw.Widget _accessoryContent(Accessory ac, String localeTag) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(ac.name, style: _bold(11)),
          pw.SizedBox(height: 8),
          _field('Type', ac.type.isEmpty ? '—' : ac.type),
          if (ac.brand.isNotEmpty) _field('Marque', ac.brand),
          if (ac.model.isNotEmpty) _field('Modèle', ac.model),
          _field('Total coups', '${ac.totalRounds}'),
          if (ac.trackBattery && ac.batteryChangedAt != null)
            _field('Dernière pile', _formatDateForLocaleTag(localeTag, ac.batteryChangedAt!)),
          _field('Dernière utilisation', _formatDateForLocaleTag(localeTag, ac.lastUsed)),
          if (ac.comment.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            _field('Note', ac.comment),
          ],
        ],
      );

  // ─── Session block ───────────────────────────────────────────────────────────

  static pw.Widget _sessionContent(
        Session s,
        ThotProvider provider,
        String localeTag,
      ) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Expanded(child: pw.Text(s.name, style: _bold(11))),
          pw.Text(
            _formatDateForLocaleTag(localeTag, s.date),
            style: _normal(8.5, color: _textMuted),
          ),
        ]),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _field('Lieu', s.location.isEmpty ? '—' : s.location),
            _field('Type', s.sessionType),
            _field('Total coups', '${s.totalRounds}'),
            if (s.hasCountedPrecision)
              _field('Précision moy.', '${s.averagePrecision.toStringAsFixed(1)} %'),
            if (s.shootingDistance != null && s.shootingDistance!.isNotEmpty)
              _field('Pas de tir', s.shootingDistance!),
          ])),
          if (s.weatherEnabled)
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (s.temperatureEnabled && s.temperature.isNotEmpty)
                _field('Température', s.temperature),
              if (s.windEnabled && s.wind.isNotEmpty)
                _field('Vent', s.wind),
              if (s.humidityEnabled && s.humidity.isNotEmpty)
                _field('Humidité', s.humidity),
              if (s.pressureEnabled && s.pressure.isNotEmpty)
                _field('Pression', s.pressure),
            ])),
        ]),
        if (s.exercises.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text('Exercices (${s.exercises.length})',
              style: _bold(9, color: _sectionBg)),
          pw.SizedBox(height: 4),
          for (final e in s.exercises)
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 5),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFF5F5F5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (e.name.isNotEmpty)
                  pw.Text(e.name, style: _bold(9)),
                pw.Row(children: [
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    _field('Arme', e.weaponLabel ?? (provider.getWeaponById(e.weaponId)?.name ?? e.weaponId)),
                    _field('Munition', e.ammoLabel ?? (provider.getAmmoById(e.ammoId)?.name ?? e.ammoId)),
                    _field('Coups tirés', '${e.shotsFired}'),
                  ])),
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    _field('Distance', '${e.distance} m'),
                    if (e.isPrecisionCounted)
                      _field('Précision', '${e.precision!.toStringAsFixed(1)} %'),
                    if (e.targetName != null && e.targetName!.isNotEmpty)
                      _field('Cible', e.targetName!),
                  ])),
                ]),
                if (e.observations.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  _field('Observations', e.observations),
                ],
              ]),
            ),
        ],
      ]);
}

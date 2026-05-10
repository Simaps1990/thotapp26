import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models.dart';
import '../data/thot_provider.dart';
import 'pdf_export_options.dart';
import 'document_hash.dart';
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

  static pw.Widget _header(pw.Context ctx, String title, String localeTag) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _cardBorder, width: 0.5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('THOT — $title', style: _normal(8, color: _textMuted)),
            pw.Text('${_label('Page', localeTag)} ${ctx.pageNumber}', style: _normal(8, color: _textMuted)),
          ],
        ),
      );

  static pw.Widget _footer(String localeTag, {String? hashPrefix}) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _cardBorder, width: 0.5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (hashPrefix != null)
              pw.Text('THOT — Document non-falsifiable — Hash: $hashPrefix — ${_formatDateShort(localeTag)}', style: _normal(7, color: _textMuted))
            else
              pw.Text('THOT — Document non-falsifiable — ${_formatDateShort(localeTag)}', style: _normal(7, color: _textMuted)),
          ],
        ),
      );

  static String _formatDateShort(String localeTag) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', localeTag);
    return dateFormat.format(now);
  }

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

  // ─── Localization helpers ─────────────────────────────────────────────────────

  static String _label(String key, String localeTag) {
    final locale = localeTag.toLowerCase();
    switch (key) {
      case 'Page':
        switch (locale) {
          case 'en': return 'Page';
          case 'de': return 'Seite';
          case 'it': return 'Pagina';
          case 'es': return 'Página';
          default: return 'Page';
        }
      case 'PLATEFORMES':
        switch (locale) {
          case 'en': return 'PLATFORMS';
          case 'de': return 'PLATTFORMEN';
          case 'it': return 'PIATTAFORME';
          case 'es': return 'PLATAFORMAS';
          default: return 'PLATEFORMES';
        }
      case 'CONSOMMABLES':
        switch (locale) {
          case 'en': return 'CONSUMABLES';
          case 'de': return 'VERBRAUCHSMATERIAL';
          case 'it': return 'CONSUMABILI';
          case 'es': return 'CONSUMIBLES';
          default: return 'CONSOMMABLES';
        }
      case 'ACCESSOIRES':
        switch (locale) {
          case 'en': return 'ACCESSORIES';
          case 'de': return 'ZUBEHÖR';
          case 'it': return 'ACCESSORI';
          case 'es': return 'ACCESORIOS';
          default: return 'ACCESSOIRES';
        }
      case 'SESSIONS':
        switch (locale) {
          case 'en': return 'SESSIONS';
          case 'de': return 'SITZUNGEN';
          case 'it': return 'SESSIONI';
          case 'es': return 'SESIONES';
          default: return 'SESSIONS';
        }
      case 'SESSIONS DE TIR':
        switch (locale) {
          case 'en': return 'SHOOTING SESSIONS';
          case 'de': return 'SCHIESSSITZUNGEN';
          case 'it': return 'SESSIONI DI TIRO';
          case 'es': return 'SESIONES DE TIRO';
          default: return 'SESSIONS DE TIR';
        }
      case 'Carnet de Tir Numérique':
        switch (locale) {
          case 'en': return 'Digital Shooting Log';
          case 'de': return 'Digitales Schießtagebuch';
          case 'it': return 'Diario di Tiro Digitale';
          case 'es': return 'Diario de Tiro Digital';
          default: return 'Carnet de Tir Numérique';
        }
      case 'Export complet des données':
        switch (locale) {
          case 'en': return 'Complete Data Export';
          case 'de': return 'Vollständiger Datenexport';
          case 'it': return 'Esportazione completa dei dati';
          case 'es': return 'Exportación completa de datos';
          default: return 'Export complet des données';
        }
      case 'Tireur':
        switch (locale) {
          case 'en': return 'Shooter';
          case 'de': return 'Schütze';
          case 'it': return 'Tiratore';
          case 'es': return 'Tirador';
          default: return 'Tireur';
        }
      case 'Licence':
        switch (locale) {
          case 'en': return 'License';
          case 'de': return 'Lizenz';
          case 'it': return 'Licenza';
          case 'es': return 'Licencia';
          default: return 'Licence';
        }
      case "Date d'export":
        switch (locale) {
          case 'en': return 'Export date';
          case 'de': return 'Exportdatum';
          case 'it': return 'Data di esportazione';
          case 'es': return 'Fecha de exportación';
          default: return "Date d'export";
        }
      case 'SOMMAIRE':
        switch (locale) {
          case 'en': return 'SUMMARY';
          case 'de': return 'ZUSAMMENFASSUNG';
          case 'it': return 'RIEPILOGO';
          case 'es': return 'RESUMEN';
          default: return 'SOMMAIRE';
        }
      case 'STATISTIQUES':
        switch (locale) {
          case 'en': return 'STATISTICS';
          case 'de': return 'STATISTIK';
          case 'it': return 'STATISTICHE';
          case 'es': return 'ESTADÍSTICAS';
          default: return 'STATISTIQUES';
        }
      case 'Modèle':
        switch (locale) {
          case 'en': return 'Model';
          case 'de': return 'Modell';
          case 'it': return 'Modello';
          case 'es': return 'Modelo';
          default: return 'Modèle';
        }
      case 'Calibre':
        switch (locale) {
          case 'en': return 'Caliber';
          case 'de': return 'Kaliber';
          case 'it': return 'Calibro';
          case 'es': return 'Calibre';
          default: return 'Calibre';
        }
      case 'N° de série':
        switch (locale) {
          case 'en': return 'Serial number';
          case 'de': return 'Seriennummer';
          case 'it': return 'Numero di serie';
          case 'es': return 'Número de serie';
          default: return 'N° de série';
        }
      case 'Poids':
        switch (locale) {
          case 'en': return 'Weight';
          case 'de': return 'Gewicht';
          case 'it': return 'Peso';
          case 'es': return 'Peso';
          default: return 'Poids';
        }
      case 'Total coups':
        switch (locale) {
          case 'en': return 'Total shots';
          case 'de': return 'Gesamtschüsse';
          case 'it': return 'Totale colpi';
          case 'es': return 'Total disparos';
          default: return 'Total coups';
        }
      case 'Entretien':
        switch (locale) {
          case 'en': return 'Maintenance';
          case 'de': return 'Wartung';
          case 'it': return 'Manutenzione';
          case 'es': return 'Mantenimiento';
          default: return 'Entretien';
        }
      case 'Révision':
        switch (locale) {
          case 'en': return 'Revision';
          case 'de': return 'Revision';
          case 'it': return 'Revisione';
          case 'es': return 'Revisión';
          default: return 'Révision';
        }
      case 'Dernière utilisation':
        switch (locale) {
          case 'en': return 'Last used';
          case 'de': return 'Zuletzt verwendet';
          case 'it': return 'Ultimo utilizzo';
          case 'es': return 'Último uso';
          default: return 'Dernière utilisation';
        }
      case 'Note':
        switch (locale) {
          case 'en': return 'Note';
          case 'de': return 'Notiz';
          case 'it': return 'Nota';
          case 'es': return 'Nota';
          default: return 'Note';
        }
      case 'Historique':
        switch (locale) {
          case 'en': return 'History';
          case 'de': return 'Verlauf';
          case 'it': return 'Storico';
          case 'es': return 'Historial';
          default: return 'Historique';
        }
      case 'entrées':
        switch (locale) {
          case 'en': return 'entries';
          case 'de': return 'Einträge';
          case 'it': return 'voci';
          case 'es': return 'entradas';
          default: return 'entrées';
        }
      case 'autres entrées':
        switch (locale) {
          case 'en': return 'more entries';
          case 'de': return 'weitere Einträge';
          case 'it': return 'altre voci';
          case 'es': return 'más entradas';
          default: return 'autres entrées';
        }
      case 'Marque':
        switch (locale) {
          case 'en': return 'Brand';
          case 'de': return 'Marke';
          case 'it': return 'Marca';
          case 'es': return 'Marca';
          default: return 'Marque';
        }
      case 'Projectile':
        switch (locale) {
          case 'en': return 'Projectile';
          case 'de': return 'Geschoss';
          case 'it': return 'Proiettile';
          case 'es': return 'Proyectil';
          default: return 'Projectile';
        }
      case 'Stock actuel':
        switch (locale) {
          case 'en': return 'Current stock';
          case 'de': return 'Aktueller Bestand';
          case 'it': return 'Scorta attuale';
          case 'es': return 'Stock actual';
          default: return 'Stock actuel';
        }
      case 'consommables':
        switch (locale) {
          case 'en': return 'consumables';
          case 'de': return 'Verbrauchsmaterial';
          case 'it': return 'consumabili';
          case 'es': return 'consumibles';
          default: return 'consommables';
        }
      case "Seuil d'alerte":
        switch (locale) {
          case 'en': return 'Alert threshold';
          case 'de': return 'Warnschwelle';
          case 'it': return 'Soglia di allarme';
          case 'es': return 'Umbral de alerta';
          default: return "Seuil d'alerte";
        }
      case 'Type':
        switch (locale) {
          case 'en': return 'Type';
          case 'de': return 'Typ';
          case 'it': return 'Tipo';
          case 'es': return 'Tipo';
          default: return 'Type';
        }
      case 'Dernière pile':
        switch (locale) {
          case 'en': return 'Last battery';
          case 'de': return 'Letzte Batterie';
          case 'it': return 'Ultima batteria';
          case 'es': return 'Última batería';
          default: return 'Dernière pile';
        }
      case 'Lieu':
        switch (locale) {
          case 'en': return 'Location';
          case 'de': return 'Ort';
          case 'it': return 'Luogo';
          case 'es': return 'Ubicación';
          default: return 'Lieu';
        }
      case 'Précision moy.':
        switch (locale) {
          case 'en': return 'Avg. precision';
          case 'de': return 'Durchschn. Präzision';
          case 'it': return 'Precisione media';
          case 'es': return 'Precisión media';
          default: return 'Précision moy.';
        }
      case 'Pas de tir':
        switch (locale) {
          case 'en': return 'Shooting distance';
          case 'de': return 'Schießentfernung';
          case 'it': return 'Distanza di tiro';
          case 'es': return 'Distancia de tiro';
          default: return 'Pas de tir';
        }
      case 'Température':
        switch (locale) {
          case 'en': return 'Temperature';
          case 'de': return 'Temperatur';
          case 'it': return 'Temperatura';
          case 'es': return 'Temperatura';
          default: return 'Température';
        }
      case 'Vent':
        switch (locale) {
          case 'en': return 'Wind';
          case 'de': return 'Wind';
          case 'it': return 'Vento';
          case 'es': return 'Viento';
          default: return 'Vent';
        }
      case 'Humidité':
        switch (locale) {
          case 'en': return 'Humidity';
          case 'de': return 'Feuchtigkeit';
          case 'it': return 'Umidità';
          case 'es': return 'Humedad';
          default: return 'Humidité';
        }
      case 'Pression':
        switch (locale) {
          case 'en': return 'Pressure';
          case 'de': return 'Druck';
          case 'it': return 'Pressione';
          case 'es': return 'Presión';
          default: return 'Pression';
        }
      case 'Exercices':
        switch (locale) {
          case 'en': return 'Exercises';
          case 'de': return 'Übungen';
          case 'it': return 'Esercizi';
          case 'es': return 'Ejercicios';
          default: return 'Exercices';
        }
      case 'Coups tirés':
        switch (locale) {
          case 'en': return 'Shots fired';
          case 'de': return 'Abgegebene Schüsse';
          case 'it': return 'Colpi sparati';
          case 'es': return 'Disparos realizados';
          default: return 'Coups tirés';
        }
      case 'Distance':
        switch (locale) {
          case 'en': return 'Distance';
          case 'de': return 'Entfernung';
          case 'it': return 'Distanza';
          case 'es': return 'Distancia';
          default: return 'Distance';
        }
      case 'Précision':
        switch (locale) {
          case 'en': return 'Precision';
          case 'de': return 'Präzision';
          case 'it': return 'Precisione';
          case 'es': return 'Precisión';
          default: return 'Précision';
        }
      case 'Cible':
        switch (locale) {
          case 'en': return 'Target';
          case 'de': return 'Ziel';
          case 'it': return 'Bersaglio';
          case 'es': return 'Objetivo';
          default: return 'Cible';
        }
      case 'Observations':
        switch (locale) {
          case 'en': return 'Observations';
          case 'de': return 'Beobachtungen';
          case 'it': return 'Osservazioni';
          case 'es': return 'Observaciones';
          default: return 'Observations';
        }
      case 'Sessions':
        switch (locale) {
          case 'en': return 'Sessions';
          case 'de': return 'Sitzungen';
          case 'it': return 'Sessioni';
          case 'es': return 'Sesiones';
          default: return 'Sessions';
        }
      case 'Plateformes':
        switch (locale) {
          case 'en': return 'Platforms';
          case 'de': return 'Plattformen';
          case 'it': return 'Piattaforme';
          case 'es': return 'Plataformas';
          default: return 'Plateformes';
        }
      case 'coups au total':
        switch (locale) {
          case 'en': return 'total shots';
          case 'de': return 'Gesamtschüsse';
          case 'it': return 'colpi totali';
          case 'es': return 'disparos totales';
          default: return 'coups au total';
        }
      default:
        return key;
    }
  }

  static String _pluralize(String singular, int count, String localeTag) {
    if (count == 1) return singular;
    final locale = localeTag.toLowerCase();
    switch (singular) {
      case 'plateforme':
        switch (locale) {
          case 'en': return 'platforms';
          case 'de': return 'Plattformen';
          case 'it': return 'piattaforme';
          case 'es': return 'plataformas';
          default: return 'plateformes';
        }
      case 'consommable':
        switch (locale) {
          case 'en': return 'consumables';
          case 'de': return 'Verbrauchsmaterial';
          case 'it': return 'consumabili';
          case 'es': return 'consumibles';
          default: return 'consommables';
        }
      case 'accessoire':
        switch (locale) {
          case 'en': return 'accessories';
          case 'de': return 'Zubehör';
          case 'it': return 'accessori';
          case 'es': return 'accesorios';
          default: return 'accessoires';
        }
      case 'session':
        switch (locale) {
          case 'en': return 'sessions';
          case 'de': return 'Sitzungen';
          case 'it': return 'sessioni';
          case 'es': return 'sesiones';
          default: return 'sessions';
        }
      default:
        return singular + 's';
    }
  }

  // ─── Entry point ────────────────────────────────────────────────────────────

  /// Build export data for hash computation.
  static Map<String, dynamic> _buildExportData(ThotProvider provider, PdfExportOptions options) {
    final data = <String, dynamic>{
      'exportDate': DateTime.now().toIso8601String(),
      'userName': provider.userName,
      'licenseNumber': provider.licenseNumber,
    };
    
    if (options.includePlatforms && provider.platforms.isNotEmpty) {
      data['platforms'] = provider.platforms.map((p) => {
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
        'lastUsed': p.lastUsed.toIso8601String(),
        'comment': p.comment,
        'history': p.history.map((h) => {
          'date': h.date.toIso8601String(),
          'type': h.type,
          'label': h.label,
        }).toList(),
      }).toList();
    }
    
    if (options.includeAmmos && provider.ammos.isNotEmpty) {
      data['ammos'] = provider.ammos.map((a) => {
        'id': a.id,
        'name': a.name,
        'brand': a.brand,
        'caliber': a.caliber,
        'projectileType': a.projectileType,
        'quantity': a.quantity,
        'lowStockThreshold': a.lowStockThreshold,
        'lastUsed': a.lastUsed.toIso8601String(),
        'comment': a.comment,
      }).toList();
    }
    
    if (options.includeAccessories && provider.accessories.isNotEmpty) {
      data['accessories'] = provider.accessories.map((ac) => {
        'id': ac.id,
        'name': ac.name,
        'type': ac.type,
        'brand': ac.brand,
        'model': ac.model,
        'totalRounds': ac.totalRounds,
        'trackBattery': ac.trackBattery,
        'batteryChangedAt': ac.batteryChangedAt?.toIso8601String(),
        'lastUsed': ac.lastUsed.toIso8601String(),
        'comment': ac.comment,
      }).toList();
    }
    
    if (options.includeSessions && provider.sessions.isNotEmpty) {
      data['sessions'] = provider.sessions.map((s) => {
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
        'exercises': s.exercises.map((e) => {
          'id': e.id,
          'platformId': e.platformId,
          'ammoId': e.ammoId,
          'shotsFired': e.shotsFired,
          'distance': e.distance,
          'precision': e.precision,
          'targetName': e.targetName,
          'observations': e.observations,
        }).toList(),
      }).toList();
    }
    
    return data;
  }

static Future<void> exportAll(ThotProvider provider, {PdfExportOptions options = const PdfExportOptions()}) async {
      if (!provider.isPremium) {
      throw Exception('Premium required');
    }
    final now = DateTime.now();
    final filename = 'THOT_Export_${_dfFile.format(now)}.pdf';
    final localeTag = (provider.appLocale ?? const Locale('fr')).toLanguageTag();
    final exportDate = _formatDateForLocaleTag(localeTag, now);
    
    // Compute hash and serial if authentication is enabled
    String? hash;
    String? serial;
    if (options.includeAuth) {
      final data = _buildExportData(provider, options);
      hash = DocumentHash.compute(data);
      serial = now.microsecondsSinceEpoch.toString();
    }
    
    final doc = pw.Document(
      title: filename,
      author: provider.userName.isEmpty ? 'THOT' : provider.userName,
      subject: hash != null ? 'Hash: $hash' : null,
      keywords: hash != null ? 'thot,carnet-tir,hash:$hash' : 'thot,carnet-tir',
    );

    // 1. Page de couverture
    doc.addPage(_coverPage(provider, exportDate, localeTag, hash: hash, serial: serial));

// 2. Plateformes
    if (options.includePlatforms && provider.platforms.isNotEmpty) {
      final hashPrefix = hash != null ? hash.substring(0, 8) : null;
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => _header(ctx, _label('PLATEFORMES', localeTag), localeTag),
        footer: (ctx) => _footer(localeTag, hashPrefix: hashPrefix),
        build: (_) => [
          _sectionTitle('${_label('PLATEFORMES', localeTag)}  (${provider.platforms.length})'),
          pw.SizedBox(height: 14),
          for (final w in provider.platforms) ...[
            _card(_platformContent(w, localeTag)),
            pw.SizedBox(height: 14),
          ],
        ],
      ));
    }

    // 3. Consommables
if (options.includeAmmos && provider.ammos.isNotEmpty) {
      final hashPrefix = hash != null ? hash.substring(0, 8) : null;
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => _header(ctx, _label('CONSOMMABLES', localeTag), localeTag),
        footer: (ctx) => _footer(localeTag, hashPrefix: hashPrefix),
        build: (_) => [
          _sectionTitle('${_label('CONSOMMABLES', localeTag)}  (${provider.ammos.length})'),
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
        header: (ctx) => _header(ctx, _label('ACCESSOIRES', localeTag), localeTag),
        footer: (ctx) => _footer(localeTag, hashPrefix: hash != null ? hash.substring(0, 8) : null),
        build: (_) => [
          _sectionTitle('${_label('ACCESSOIRES', localeTag)}  (${provider.accessories.length})'),
          pw.SizedBox(height: 14),
          for (final ac in provider.accessories) ...[
            _card(_accessoryContent(ac, localeTag)),
            pw.SizedBox(height: 10),
          ],
        ],
      ));
    }

    // 5. Sessions
if (options.includeSessions && provider.sessions.isNotEmpty) {
        doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => _header(ctx, _label('SESSIONS', localeTag), localeTag),
        footer: (ctx) => _footer(localeTag, hashPrefix: hash != null ? hash.substring(0, 8) : null),
        build: (_) => [
          _sectionTitle('${_label('SESSIONS DE TIR', localeTag)}  (${provider.sessions.length})'),
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

  static pw.Page _coverPage(ThotProvider provider, String exportDate, String localeTag, {String? hash, String? serial}) => pw.Page(
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
                pw.Text(_label('Carnet de Tir Numérique', localeTag), style: _normal(14, color: _white)),
              ]),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(_label('Export complet des données', localeTag), style: _bold(18)),
                pw.SizedBox(height: 20),
                if (provider.userName.isNotEmpty)
                  _field(_label('Tireur', localeTag), provider.userName),
                if (provider.licenseNumber.isNotEmpty)
                  _field(_label('Licence', localeTag), provider.licenseNumber),
                _field(_label("Date d'export", localeTag), exportDate),
                pw.SizedBox(height: 24),
                pw.Divider(color: _cardBorder, height: 1),
                pw.SizedBox(height: 20),
                // Sommaire
                pw.Text(_label('SOMMAIRE', localeTag), style: _bold(11, color: _sectionBg)),
                pw.SizedBox(height: 10),
                _summaryLine('${provider.platforms.length} ${_pluralize('plateforme', provider.platforms.length, localeTag)}'),
                _summaryLine('${provider.ammos.length} ${_pluralize('consommable', provider.ammos.length, localeTag)}'),
                _summaryLine('${provider.accessories.length} ${_pluralize('accessoire', provider.accessories.length, localeTag)}'),
                _summaryLine('${provider.sessions.length} ${_pluralize('session', provider.sessions.length, localeTag)} — ${provider.totalRoundsFired} ${_label('coups au total', localeTag)}'),
                pw.SizedBox(height: 24),
                pw.Divider(color: _cardBorder, height: 1),
                pw.SizedBox(height: 20),
                // Stats rapides
                pw.Text(_label('STATISTIQUES', localeTag), style: _bold(11, color: _sectionBg)),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  _statBox(_label('Sessions', localeTag), '${provider.totalSessions}'),
                  pw.SizedBox(width: 10),
                  _statBox(_label('Coups tirés', localeTag), '${provider.totalRoundsFired}'),
                  pw.SizedBox(width: 10),
                  _statBox(_label('Plateformes', localeTag), '${provider.platforms.length}'),
                ]),
                if (hash != null && serial != null) ...[
                  pw.SizedBox(height: 24),
                  pw.Divider(color: _cardBorder, height: 1),
                  pw.SizedBox(height: 20),
                  // Authentication block
                  pw.Text('AUTHENTIFICATION', style: _bold(11, color: _sectionBg)),
                  pw.SizedBox(height: 10),
                  _field('Numéro de série', serial),
                  _field('Empreinte SHA-256', hash),
                  _field('Généré le', DateTime.now().toIso8601String()),
                  _field('Vérifiable sur', 'https://thotbook.fr/verify'),
                ],
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

  // ─── Platform block ────────────────────────────────────────────────────────────

  static pw.Widget _platformContent(Platform w, String localeTag) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(w.name, style: _bold(12)),
          pw.SizedBox(height: 2),
          pw.Text(w.type, style: _normal(8.5, color: _textMuted)),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _field(_label('Modèle', localeTag), w.model.isEmpty ? '—' : w.model),
              _field(_label('Calibre', localeTag), w.caliber.isEmpty ? '—' : w.caliber),
              _field(_label('N° de série', localeTag), w.serialNumber.isEmpty ? '—' : w.serialNumber),
              _field(_label('Poids', localeTag), '${w.weight.toStringAsFixed(0)} g'),
            ])),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _field(_label('Total coups', localeTag), '${w.totalRounds}'),
              _field(_label('Entretien', localeTag), '${(w.cleaningProgress * 100).toInt()}%  (${w.roundsSinceCleaning} coups)'),
              _field(_label('Révision', localeTag), '${(w.revisionProgress * 100).toInt()}%  (${w.roundsSinceRevision} coups)'),
              _field(_label('Dernière utilisation', localeTag), _formatDateForLocaleTag(localeTag, w.lastUsed)),
            ])),
          ]),
          if (w.comment.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            _field(_label('Note', localeTag), w.comment),
          ],
          if (w.history.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('${_label('Historique', localeTag)} (${w.history.length} ${_label('entrées', localeTag)})', style: _bold(8.5)),
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
              pw.Text('… et ${w.history.length - 8} ${_label('autres entrées', localeTag)}',
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
              _field(_label('Marque', localeTag), a.brand.isEmpty ? '—' : a.brand),
              _field(_label('Calibre', localeTag), a.caliber.isEmpty ? '—' : a.caliber),
              _field(_label('Projectile', localeTag), a.projectileType.isEmpty ? '—' : a.projectileType),
            ])),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _field(_label('Stock actuel', localeTag), '${a.quantity} ${_label('consommables', localeTag)}'),
              _field(_label("Seuil d'alerte", localeTag), '${a.lowStockThreshold} ${_label('consommables', localeTag)}'),
              _field(_label('Dernière utilisation', localeTag), _formatDateForLocaleTag(localeTag, a.lastUsed)),
            ])),
          ]),
          if (a.comment.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            _field(_label('Note', localeTag), a.comment),
          ],
        ],
      );

  // ─── Accessory block ─────────────────────────────────────────────────────────

  static pw.Widget _accessoryContent(Accessory ac, String localeTag) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(ac.name, style: _bold(11)),
          pw.SizedBox(height: 8),
          _field(_label('Type', localeTag), ac.type.isEmpty ? '—' : ac.type),
          if (ac.brand.isNotEmpty) _field(_label('Marque', localeTag), ac.brand),
          if (ac.model.isNotEmpty) _field(_label('Modèle', localeTag), ac.model),
          _field(_label('Total coups', localeTag), '${ac.totalRounds}'),
          if (ac.trackBattery && ac.batteryChangedAt != null)
            _field(_label('Dernière pile', localeTag), _formatDateForLocaleTag(localeTag, ac.batteryChangedAt!)),
          _field(_label('Dernière utilisation', localeTag), _formatDateForLocaleTag(localeTag, ac.lastUsed)),
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
            _field(_label('Lieu', localeTag), s.location.isEmpty ? '—' : s.location),
            _field(_label('Type', localeTag), s.sessionType),
            _field(_label('Total coups', localeTag), '${s.totalRounds}'),
            if (s.hasCountedPrecision)
              _field(_label('Précision moy.', localeTag), '${s.averagePrecision.toStringAsFixed(1)} %'),
            if (s.shootingDistance != null && s.shootingDistance!.isNotEmpty)
              _field(_label('Pas de tir', localeTag), s.shootingDistance!),
          ])),
          if (s.weatherEnabled)
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (s.temperatureEnabled && s.temperature.isNotEmpty)
                _field(_label('Température', localeTag), s.temperature),
              if (s.windEnabled && s.wind.isNotEmpty)
                _field(_label('Vent', localeTag), s.wind),
              if (s.humidityEnabled && s.humidity.isNotEmpty)
                _field(_label('Humidité', localeTag), s.humidity),
              if (s.pressureEnabled && s.pressure.isNotEmpty)
                _field(_label('Pression', localeTag), s.pressure),
            ])),
        ]),
        if (s.exercises.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text('${_label('Exercices', localeTag)} (${s.exercises.length})',
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
                    _field(_label('Plateforme', localeTag), e.platformLabel ?? (provider.getPlatformById(e.platformId)?.name ?? e.platformId)),
                    _field(_label('Consommable', localeTag), e.ammoLabel ?? (provider.getAmmoById(e.ammoId)?.name ?? e.ammoId)),
                    _field(_label('Coups tirés', localeTag), '${e.shotsFired}'),
                  ])),
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    _field(_label('Distance', localeTag), '${e.distance} m'),
                    if (e.isPrecisionCounted)
                      _field(_label('Précision', localeTag), '${e.precision!.toStringAsFixed(1)} %'),
                    if (e.targetName != null && e.targetName!.isNotEmpty)
                      _field(_label('Cible', localeTag), e.targetName!),
                  ])),
                ]),
                if (e.observations.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  _field(_label('Observations', localeTag), e.observations),
                ],
              ]),
            ),
        ],
      ]);
}

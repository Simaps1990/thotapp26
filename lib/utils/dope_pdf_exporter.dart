import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models.dart';
import '../data/thot_provider.dart';
import '../l10n/app_strings.dart';

class DopePdfExporter {
  /// Export a DOPE card as a PDF in A6 format.
  static Future<void> exportDopeCard(
    ShootingAdjustmentTable table,
    ThotProvider provider,
    AppStrings strings,
  ) async {
    final now = DateTime.now();
    final localeTag = (provider.appLocale ?? const Locale('fr')).toLanguageTag();
    final dateFormat = DateFormat('dd/MM/yyyy', localeTag);
    final filename = 'THOT_DOPE_${_sanitizeFileName(table.name)}_${_dfFile.format(now)}.pdf';

    final doc = pw.Document(
      title: table.name.trim().isEmpty ? 'THOT DOPE Card' : table.name,
      author: provider.userName.isEmpty ? 'THOT' : provider.userName,
      subject: 'DOPE Card',
      keywords: 'thot,dope,shooting,card',
    );

    // Sort entries by distance
    final entries = [...table.entries]
      ..sort((a, b) => a.distance.compareTo(b.distance));

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      table.name.trim().isEmpty ? _label('untitled_table', localeTag) : table.name,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '${_platformName(provider, table.platformId, localeTag, customPlatformName: table.customPlatformName)} / ${_ammoName(provider, table.ammoId, strings, localeTag)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${strings.dateLabel}: ${dateFormat.format(table.updatedAt)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableCell(_label('distance', localeTag), isHeader: true),
                      _tableCell(_label('drop', localeTag), isHeader: true),
                      _tableCell(_label('wind', localeTag), isHeader: true),
                    ],
                  ),
                  // Data rows
                  ...entries.map((entry) {
                    final distance = provider.useMetric
                        ? '${entry.distance}m'
                        : '${(entry.distance * 1.09361).toStringAsFixed(0)}yd';
                    final drop = provider.useMetric
                        ? '${entry.verticalOffset.toStringAsFixed(1)}cm'
                        : '${(entry.verticalOffset / 2.54).toStringAsFixed(1)}in';
                    final drift = provider.useMetric
                        ? '${entry.horizontalOffset.toStringAsFixed(1)}cm'
                        : '${(entry.horizontalOffset / 2.54).toStringAsFixed(1)}in';
                    return pw.TableRow(
                      children: [
                        _tableCell(distance),
                        _tableCell(drop),
                        _tableCell(drift),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(flex: 1),
              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey400, width: 1),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'THOT — DOPE Card',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      dateFormat.format(now),
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: filename,
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _platformName(
    ThotProvider provider,
    String platformId,
    String localeTag, {
    String? customPlatformName,
  }) {
    if (customPlatformName != null && customPlatformName.trim().isNotEmpty) {
      return customPlatformName;
    }
    final platform = provider.platforms.firstWhere(
      (p) => p.id == platformId,
      orElse: () => Platform(
        id: '',
        name: _label('unknown', localeTag),
        type: '',
        model: '',
        caliber: '',
        serialNumber: '',
        weight: 0,
        totalRounds: 0,
        lastUsed: DateTime.now(),
        comment: '',
        lastCleaned: DateTime.now(),
      ),
    );
    return platform.name;
  }

  static String _ammoName(ThotProvider provider, String? ammoId, AppStrings strings, String localeTag) {
    if (ammoId == null) return strings.shootingTableNoAmmo;
    final ammo = provider.ammos.firstWhere(
      (a) => a.id == ammoId,
      orElse: () => Ammo(
        id: '',
        name: _label('unknown', localeTag),
        brand: '',
        caliber: '',
        projectileType: '',
        quantity: 0,
        lowStockThreshold: 0,
        lastUsed: DateTime.now(),
        comment: '',
      ),
    );
    return ammo.name;
  }

  static String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, 30);
  }

  static final DateFormat _dfFile = DateFormat('yyyyMMdd_HHmmss');

  static String _label(String key, String localeTag) {
    final lang = localeTag.split('-').first.split('_').first;
    switch (key) {
      case 'untitled_table':
        switch (lang) {
          case 'en': return 'Untitled table';
          case 'de': return 'Unbenannte Tabelle';
          case 'it': return 'Tabella senza nome';
          case 'es': return 'Tabla sin nombre';
          default: return 'Table sans nom';
        }
      case 'distance':
        switch (lang) {
          case 'en': return 'Distance';
          case 'de': return 'Entfernung';
          case 'it': return 'Distanza';
          case 'es': return 'Distancia';
          default: return 'Distance';
        }
      case 'drop':
        switch (lang) {
          case 'en': return 'Drop';
          case 'de': return 'Abfall';
          case 'it': return 'Caduta';
          case 'es': return 'Caída';
          default: return 'Drop';
        }
      case 'wind':
        switch (lang) {
          case 'en': return 'Wind';
          case 'de': return 'Drift';
          case 'it': return 'Deriva';
          case 'es': return 'Deriva';
          default: return 'Dérive';
        }
      case 'unknown':
        switch (lang) {
          case 'en': return 'Unknown';
          case 'de': return 'Unbekannt';
          case 'it': return 'Sconosciuto';
          case 'es': return 'Desconocido';
          default: return 'Inconnu';
        }
      default:
        return key;
    }
  }
}

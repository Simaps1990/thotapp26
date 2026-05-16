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
    final localeTag = (provider.appLocale ?? const Locale('fr'))
        .toLanguageTag();
    final dateFormat = DateFormat('dd/MM/yyyy', localeTag);
    final filename =
        'THOT_DOPE_${_sanitizeFileName(table.name)}_${_dfFile.format(now)}.pdf';

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
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey400),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      table.name.trim().isEmpty
                          ? strings.dopeLabelUntitledTable
                          : table.name,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '${_platformName(provider, table.platformId, strings, localeTag, customPlatformName: table.customPlatformName)} / ${_ammoName(provider, table.ammoId, strings, localeTag)}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${strings.dateLabel}: ${dateFormat.format(table.updatedAt)}',
                      style: const pw.TextStyle(
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
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FlexColumnWidth(),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _tableCell(strings.dopeTableHeaderDistance, isHeader: true),
                      _tableCell(strings.dopeTableHeaderDrop, isHeader: true),
                      _tableCell(strings.dopeTableHeaderWind, isHeader: true),
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
              pw.Spacer(),
              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey400),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'THOT — DOPE Card',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      dateFormat.format(now),
                      style: const pw.TextStyle(
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

    await Printing.sharePdf(bytes: await doc.save(), filename: filename);
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
    AppStrings strings,
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
        name: strings.dopeLabelUnknown,
        type: '',
        model: '',
        caliber: '',
        serialNumber: '',
        weight: 0,
        totalRounds: 0,
        lastCleaned: DateTime.now(),
      ),
    );
    return platform.name;
  }

  static String _ammoName(
    ThotProvider provider,
    String? ammoId,
    AppStrings strings,
    String localeTag,
  ) {
    if (ammoId == null) return strings.shootingTableNoAmmo;
    final ammo = provider.ammos.firstWhere(
      (a) => a.id == ammoId,
      orElse: () => Ammo(
        id: '',
        name: strings.dopeLabelUnknown,
        brand: '',
        caliber: '',
        quantity: 0,
        lowStockThreshold: 0,
      ),
    );
    return ammo.name;
  }

  static String _sanitizeFileName(String name) {
    // Defensive sanitiser. The previous version called .substring(0, 30)
    // unconditionally which throws RangeError for any name shorter than
    // 30 chars after stripping forbidden characters.
    final cleaned = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    if (cleaned.isEmpty) return 'table';
    return cleaned.length <= 30 ? cleaned : cleaned.substring(0, 30);
  }

  static final DateFormat _dfFile = DateFormat('yyyyMMdd_HHmmss');
}

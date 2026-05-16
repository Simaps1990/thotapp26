import 'package:thot/data/models.dart';
import 'package:thot/l10n/app_strings.dart';

/// Localized label + details for a [PlatformHistoryEntry].
///
/// Generates the display strings at view time using [AppStrings] so the
/// app honours the user's current locale — never the locale at the time
/// the entry was originally created.
///
/// Falls back to the entry's [legacyLabel] / [legacyDetails] when the
/// entry comes from a pre-i18n version of the app and has no [data].
class PlatformHistoryDisplay {
  PlatformHistoryDisplay({required this.label, this.details});

  final String label;
  final String? details;

  static PlatformHistoryDisplay from(
    PlatformHistoryEntry entry,
    AppStrings strings,
  ) {
    // Legacy entries (saved before the refactor) have no structured data
    // but kept the formatted string. Return them as-is rather than
    // breaking older users.
    final isLegacy = entry.data.isEmpty && entry.legacyLabel.isNotEmpty;
    if (isLegacy) {
      return PlatformHistoryDisplay(
        label: entry.legacyLabel,
        details: entry.legacyDetails,
      );
    }

    switch (entry.type) {
      case PlatformHistoryType.shot:
        final sessionName = entry.data[PlatformHistoryDataKey.sessionName]
                ?.toString() ??
            '';
        final shotCountRaw =
            entry.data[PlatformHistoryDataKey.shotCount];
        final shotCount = shotCountRaw is int
            ? shotCountRaw
            : int.tryParse(shotCountRaw?.toString() ?? '') ?? 0;
        return PlatformHistoryDisplay(
          label: strings.platformHistoryShotLabel(sessionName),
          details: strings.platformHistoryShotDetails(shotCount),
        );

      case PlatformHistoryType.cleaning:
        return PlatformHistoryDisplay(
          label: strings.platformHistoryCleaningLabel,
          details: strings.platformHistoryCleaningDetails,
        );

      case PlatformHistoryType.revision:
        return PlatformHistoryDisplay(
          label: strings.platformHistoryRevisionLabel,
          details: strings.platformHistoryRevisionDetails,
        );

      case PlatformHistoryType.partReplacement:
        final partName =
            entry.data[PlatformHistoryDataKey.partName]?.toString() ?? '';
        return PlatformHistoryDisplay(
          label: strings.platformHistoryPartReplacementLabel(partName),
          // Comment is stored on PlatformReplacementPart, not here.
          details: null,
        );

      default:
        // Unknown type — show something rather than crashing. This can
        // happen if a future version writes a new type that the current
        // build doesn't know about.
        return PlatformHistoryDisplay(
          label: entry.legacyLabel.isEmpty ? entry.type : entry.legacyLabel,
          details: entry.legacyDetails,
        );
    }
  }
}

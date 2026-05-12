import 'package:flutter/material.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';

/// Display helpers for exercises when platform/ammo may be:
/// - an inventory item (id exists)
/// - borrowed (id == 'borrowed')
/// - none (id == 'none')
String platformDisplayName(
  BuildContext context,
  ThotProvider provider,
  Exercise ex,
) {
  final strings = AppStrings.of(context);
  if (ex.platformId == 'none') return strings.noPlatform;
  if (ex.platformId == 'borrowed') {
    final label = (ex.platformLabel ?? '').trim();
    return label.isEmpty
        ? strings.borrowedPlatform
        : '${strings.borrowedPlatform} — $label';
  }
  return provider.getPlatformById(ex.platformId)?.name ??
      strings.unknownPlatform;
}

String ammoDisplayName(
  BuildContext context,
  ThotProvider provider,
  Exercise ex,
) {
  final strings = AppStrings.of(context);
  if (ex.ammoId == 'none') return strings.noConsumable;
  if (ex.ammoId == 'borrowed') {
    final label = (ex.ammoLabel ?? '').trim();
    return label.isEmpty
        ? strings.borrowedConsumable
        : '${strings.borrowedConsumable} — $label';
  }
  return provider.getAmmoById(ex.ammoId)?.name ?? strings.unknownConsumable;
}

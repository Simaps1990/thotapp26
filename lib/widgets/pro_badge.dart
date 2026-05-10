import 'package:flutter/material.dart';
import 'package:thot/l10n/app_strings.dart';

/// Small "PRO" pill displayed next to feature titles that are locked
/// behind the Pro plan. Visible only when the freemium flag is active —
/// today (`_kFreeLimitsDisabled = true`) it is never displayed because
/// callers gate it on `provider.isXLockedForFree(...)` which always
/// returns false while the flag is on.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.compact = false});

  /// When true, renders a more discreet badge (smaller font + tighter padding).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        strings.proBadgeLabel,
        style: TextStyle(
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: colors.primary,
          letterSpacing: 0.5,
          height: 1.0,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';


/// A lightweight, consistent page header matching the Home screen style.
///
/// Displays a primary [title] (brand / page name) and a secondary [subtitle]
/// underneath, with an optional [trailing] widget (e.g. avatar, actions).
class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textStyles.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                  height: 1,
                ),
              ),
              Text(
                subtitle,
                style: textStyles.labelSmall?.copyWith(color: colors.secondary),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

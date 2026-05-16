part of '../add_item_screen.dart';

class ItemLinkMultiSelectSheet<T> extends StatefulWidget {
  const ItemLinkMultiSelectSheet({
    super.key,
    required this.title,
    required this.items,
    required this.initialSelection,
    required this.labelOf,
    required this.subtitleOf,
    required this.idOf,
    required this.icon,
  });

  final String title;
  final List<T> items;
  final Set<String> initialSelection;
  final String Function(T item) labelOf;
  final String Function(T item) subtitleOf;
  final String Function(T item) idOf;
  final IconData icon;

  @override
  State<ItemLinkMultiSelectSheet<T>> createState() =>
      _ItemLinkMultiSelectSheetState<T>();
}

class _ItemLinkMultiSelectSheetState<T> extends State<ItemLinkMultiSelectSheet<T>> {
  late final Set<String> _selectedIds = {...widget.initialSelection};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: strings.close,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final id = widget.idOf(item);
                    final selected = _selectedIds.contains(id);
                    final subtitle = widget.subtitleOf(item);
                    return CheckboxListTile(
                      value: selected,
                      secondary: Icon(widget.icon),
                      title: Text(widget.labelOf(item)),
                      subtitle: subtitle.trim().isEmpty ? null : Text(subtitle),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedIds.add(id);
                          } else {
                            _selectedIds.remove(id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selectedIds),
                    child: Text(strings.itemSavedSuccess),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension _AddItemLinking on _AddItemScreenState {
  Future<void> _editLinkedAccessories(ThotProvider provider) async {
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemLinkMultiSelectSheet<Accessory>(
        title: AppStrings.of(context).linkAccessories,
        items: provider.accessories,
        initialSelection: _linkedAccessoryIds,
        labelOf: (a) => a.name,
        subtitleOf: (a) => [
          if (a.type.trim().isNotEmpty) a.type,
          if (a.brand.trim().isNotEmpty) a.brand,
        ].join(' • '),
        idOf: (a) => a.id,
        icon: Icons.inventory_2_rounded,
      ),
    );
    if (!mounted || updated == null) return;
    setState(() {
      _linkedAccessoryIds
        ..clear()
        ..addAll(updated);
    });
  }

  Future<void> _editLinkedPlatforms(ThotProvider provider) async {
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemLinkMultiSelectSheet<Platform>(
        title: AppStrings.of(context).linkPlatforms,
        items: provider.platforms,
        initialSelection: _linkedPlatformIds,
        labelOf: (w) => w.name,
        subtitleOf: (w) => [
          if (w.type.trim().isNotEmpty) w.type,
          if (w.caliber.trim().isNotEmpty) w.caliber,
        ].join(' • '),
        idOf: (w) => w.id,
        icon: Icons.link_rounded,
      ),
    );
    if (!mounted || updated == null) return;
    setState(() {
      _linkedPlatformIds
        ..clear()
        ..addAll(updated);
    });
  }

  Future<bool> _confirmUnlink() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(AppStrings.of(context).unlinkConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.of(context).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppStrings.of(context).delete),
              ),
            ],
          ),
        ) ??
        false;
  }
}

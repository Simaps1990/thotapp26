import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thot/presentation/add_item_screen.dart';
import '../theme.dart';
import '../data/thot_provider.dart';
import '../data/models.dart';
import 'package:thot/widgets/cross_platform_image.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/data/material_types.dart';
import 'package:thot/utils/native_picker.dart';
import 'package:thot/utils/platform_history_label.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  String _selectedPeriod = 'month'; // 'week', 'month', 'year'

  String _getCurrencySymbol(String? currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'CAD':
        return 'CA\$';
      case 'GBP':
        return '£';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'EUR':
      default:
        return '€';
    }
  }


  Future<void> _showRestockSheet(Ammo ammo, ThotProvider provider) async {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final controller = TextEditingController();
    int? addQty;

    try {
      addQty = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.add_circle_outline_rounded,
                        color: colors.primary,
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: Text(
                        strings.restock,
                        style: textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop<int>(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: strings.close,
                      color: colors.onSurfaceVariant,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.md),
                Text(
                  '${strings.currentStock}: ${ammo.quantity} ${strings.cartridges}',
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.secondary,
                  ),
                ),
                const Gap(AppSpacing.md),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    labelText: strings.quantityToAdd,
                    hintText: strings.example250,
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                  ),
                ),
                const Gap(AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () {
                    final raw = controller.text.trim();
                    final qty = int.tryParse(raw);
                    if (qty == null || qty <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(strings.enterValidQuantity),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop<int>(qty);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(strings.addToStock),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                const Gap(AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop<int>(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    side: BorderSide(color: colors.outline),
                  ),
                  child: Text(strings.cancel),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Failed to show restock sheet: $e');
    }

    // ── CRITICAL ─────────────────────────────────────────────────────────────
    // await showModalBottomSheet résout dès que pop() est appelé, PAS quand
    // l'animation de fermeture finit (~300ms). Le TextField référence encore
    // `controller` pendant cette animation.
    // Disposer le controller dans finally = crash RenderObject (renderObject.child).
    //
    // Fix : attendre la fin de l'animation AVANT de disposer le controller
    // ET avant d'appeler notifyListeners().
    // ─────────────────────────────────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 350));
    controller.dispose(); // TextField complètement sorti de l'arbre

    if (addQty != null && addQty > 0 && mounted) {
      final newQty = ammo.quantity + addQty;
      final successMsg =
          '${strings.stockUpdated}: $newQty ${strings.cartridges}';
      provider.restockAmmo(ammoId: ammo.id, addQty: addQty);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  PlatformFile? _normalizePickedPdf(PlatformFile file) {
    if (file.path == null) return null;
    return file;
  }

  String _stripPdfExtension(String name) {
    final trimmed = name.trim();
    if (trimmed.toLowerCase().endsWith('.pdf')) {
      return trimmed.substring(0, trimmed.length - 4);
    }
    return trimmed;
  }

  Future<(String, String, DateTime?, int)?> _askDocumentDetails({
    required String initialName,
    String? initialType,
    DateTime? initialExpiryDate,
    int initialNotifyDays = 0,
    String? title,
    String? confirmLabel,
  }) async {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final nameController = TextEditingController(
      text: initialName.isEmpty ? strings.itemDefaultDocumentName : initialName,
    );
    int selectedNotifyDays = initialNotifyDays;
    String selectedType = DocumentTypeKey.all.contains(initialType)
        ? initialType!
        : DocumentTypeKey.invoice;
    DateTime? expiryDate = initialExpiryDate;

    return showDialog<(String, String, DateTime?, int)?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title ?? strings.settingsDocumentDetailsTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.settingsDocumentNameLabel,
                style: textStyles.labelMedium?.copyWith(
                  color: colors.secondary,
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    tooltip: strings.clear,
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              const Gap(16),
              Text(
                strings.settingsDocumentTypeLabel,
                style: textStyles.labelMedium?.copyWith(
                  color: colors.secondary,
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(),
                items: DocumentTypeKey.all
                    .map(
                      (key) => DropdownMenuItem(
                        value: key,
                        child: Text(strings.documentTypeLabel(key)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => selectedType = v);
                },
              ),
              const Gap(16),
              Text(
                strings.docExpiryDateLabel,
                style: textStyles.labelMedium?.copyWith(
                  color: colors.secondary,
                ),
              ),
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: expiryDate == null
                        ? OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: expiryDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 3650),
                                ),
                              );
                              if (picked != null) {
                                setState(
                                  () => expiryDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                            ),
                            label: Text(strings.selectDateLabel),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.outline),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    AppDateFormats.formatDateShort(
                                      context,
                                      expiryDate!,
                                    ),
                                    style: textStyles.bodyMedium,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    expiryDate = null;
                                    selectedNotifyDays = 0;
                                  }),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: colors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              if (expiryDate != null) ...[
                const Gap(16),
                Text(
                  strings.docExpiryNotifyLabel,
                  style: textStyles.labelMedium?.copyWith(
                    color: colors.secondary,
                  ),
                ),
                const Gap(8),
                DropdownButtonFormField<int>(
                  initialValue: selectedNotifyDays > 0 ? selectedNotifyDays : 0,
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(),
                  items: [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text(strings.docExpiryNotifyNone),
                    ),
                    DropdownMenuItem<int>(
                      value: 7,
                      child: Text(strings.docExpiryNotifyOneWeek),
                    ),
                    DropdownMenuItem<int>(
                      value: 30,
                      child: Text(strings.docExpiryNotifyOneMonth),
                    ),
                    DropdownMenuItem<int>(
                      value: 90,
                      child: Text(strings.docExpiryNotifyThreeMonths),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => selectedNotifyDays = v ?? 0);
                  },
                ),
                const Gap(8),
                Text(
                  strings.docExpiryNotifyHint,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final remindersReady = await provider
                    .ensureDocumentReminderEnabled(
                      notifyBeforeDays: selectedNotifyDays,
                    );
                if (!remindersReady) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(strings.documentPushPermissionDenied),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                final name = nameController.text.trim();
                navigator.pop((
                  name.isEmpty ? strings.itemDefaultDocumentName : name,
                  selectedType,
                  expiryDate,
                  selectedNotifyDays,
                ));
              },
              child: Text(confirmLabel ?? strings.settingsAdd),
            ),
          ],
        ),
      ),
    );
  }

  Future<ItemDocument?> _pickItemDocument({
    required int currentDocumentsCount,
  }) async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final strings = AppStrings.of(context);

    if (!provider.canAddDocumentToItem(
      currentDocumentsCount: currentDocumentsCount,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.itemFreePdfLimitSingle),
          duration: const Duration(seconds: 3),
        ),
      );
      context.push('/pro');
      return null;
    }

    final picked = await NativePicker.pick(
      context,
      mode: PickerMode.photoOrDocument,
    );
    if (!mounted || picked.isCancelled) return null;

    final resolvedPath = picked.path;
    if (resolvedPath == null || resolvedPath.isEmpty) return null;

    final details = await _askDocumentDetails(
      initialName: _stripPdfExtension(picked.name ?? 'document'),
    );
    if (!mounted || details == null) return null;

    return ItemDocument(
      path: resolvedPath,
      name: details.$1,
      type: details.$2,
      expiryDate: details.$3,
      notifyBeforeDays: details.$4,
    );
  }

  Future<void> _addDocumentToCurrentItem({
    required List<ItemDocument> documents,
    Platform? platform,
    Ammo? ammo,
    Accessory? accessory,
  }) async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final strings = AppStrings.of(context);

    final document = await _pickItemDocument(
      currentDocumentsCount: documents.length,
    );
    if (!mounted || document == null) return;

    if (platform != null) {
      provider.updatePlatform(
        platform.copyWith(documents: [...platform.documents, document]),
      );
    } else if (ammo != null) {
      provider.updateAmmo(
        ammo.copyWith(documents: [...ammo.documents, document]),
      );
    } else if (accessory != null) {
      provider.updateAccessory(
        accessory.copyWith(documents: [...accessory.documents, document]),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.settingsDocumentAddedSuccess),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _updateDocumentToCurrentItem({
    required List<ItemDocument> documents,
    required ItemDocument document,
    Platform? platform,
    Ammo? ammo,
    Accessory? accessory,
  }) async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final strings = AppStrings.of(context);

    final details = await _askDocumentDetails(
      initialName: document.name,
      initialType: document.type,
      initialExpiryDate: document.expiryDate,
      initialNotifyDays: document.notifyBeforeDays,
      title: strings.settingsEditDocument,
      confirmLabel: strings.settingsDialogSave,
    );
    if (!mounted || details == null) return;

    final updatedDocuments = documents
        .map(
          (doc) => doc == document
              ? ItemDocument(
                  path: doc.path,
                  name: details.$1,
                  type: details.$2,
                  expiryDate: details.$3,
                  notifyBeforeDays: details.$4,
                )
              : doc,
        )
        .toList();

    if (platform != null) {
      provider.updatePlatform(platform.copyWith(documents: updatedDocuments));
    } else if (ammo != null) {
      provider.updateAmmo(ammo.copyWith(documents: updatedDocuments));
    } else if (accessory != null) {
      provider.updateAccessory(accessory.copyWith(documents: updatedDocuments));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.settingsDocumentUpdatedSuccess),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _removeDocumentFromCurrentItem({
    required List<ItemDocument> documents,
    required ItemDocument document,
    Platform? platform,
    Ammo? ammo,
    Accessory? accessory,
  }) async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final strings = AppStrings.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmDeleteTitle),
        content: Text(
          strings.deleteConfirmationMessage.replaceFirst(
            '{name}',
            document.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final updatedDocuments = documents.where((doc) => doc != document).toList();

    if (platform != null) {
      provider.updatePlatform(platform.copyWith(documents: updatedDocuments));
    } else if (ammo != null) {
      provider.updateAmmo(ammo.copyWith(documents: updatedDocuments));
    } else if (accessory != null) {
      provider.updateAccessory(accessory.copyWith(documents: updatedDocuments));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.settingsDocumentDeleted(document.name)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _syncPlatformAccessoryLinks({
    required ThotProvider provider,
    required String platformId,
    required Set<String> desiredAccessoryIds,
  }) {
    final currentAccessoryIds = provider
        .linkedAccessoriesForPlatform(platformId)
        .map((a) => a.id)
        .toSet();

    for (final accessoryId in desiredAccessoryIds) {
      if (!currentAccessoryIds.contains(accessoryId)) {
        provider.linkPlatformToAccessory(
          platformId: platformId,
          accessoryId: accessoryId,
        );
      }
    }

    for (final accessoryId in currentAccessoryIds.difference(
      desiredAccessoryIds,
    )) {
      provider.unlinkPlatformFromAccessory(
        platformId: platformId,
        accessoryId: accessoryId,
      );
    }
  }

  void _syncAccessoryPlatformLinks({
    required ThotProvider provider,
    required String accessoryId,
    required Set<String> desiredPlatformIds,
  }) {
    final currentPlatformIds = provider
        .linkedPlatformsForAccessory(accessoryId)
        .map((w) => w.id)
        .toSet();

    for (final platformId in desiredPlatformIds) {
      if (!currentPlatformIds.contains(platformId)) {
        provider.linkPlatformToAccessory(
          platformId: platformId,
          accessoryId: accessoryId,
        );
      }
    }

    for (final platformId in currentPlatformIds.difference(
      desiredPlatformIds,
    )) {
      provider.unlinkPlatformFromAccessory(
        platformId: platformId,
        accessoryId: accessoryId,
      );
    }
  }

  Future<void> _editLinkedAccessories(
    ThotProvider provider,
    String platformId,
  ) async {
    final initialSelection = provider
        .linkedAccessoriesForPlatform(platformId)
        .map((a) => a.id)
        .toSet();
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemLinkMultiSelectSheet(
        title: AppStrings.of(context).linkAccessories,
        items: provider.accessories,
        initialSelection: initialSelection,
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

    _syncPlatformAccessoryLinks(
      provider: provider,
      platformId: platformId,
      desiredAccessoryIds: updated,
    );
  }

  Future<void> _editLinkedPlatforms(
    ThotProvider provider,
    String accessoryId,
  ) async {
    final initialSelection = provider
        .linkedPlatformsForAccessory(accessoryId)
        .map((w) => w.id)
        .toSet();
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemLinkMultiSelectSheet(
        title: AppStrings.of(context).linkPlatforms,
        items: provider.platforms,
        initialSelection: initialSelection,
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

    _syncAccessoryPlatformLinks(
      provider: provider,
      accessoryId: accessoryId,
      desiredPlatformIds: updated,
    );
  }

  Future<void> _showPartReplacementDialog({
    required ThotProvider provider,
    required Platform platform,
    PlatformReplacementPart? part,
  }) async {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final partController = TextEditingController(text: part?.name ?? '');
    final commentController = TextEditingController(text: part?.comment ?? '');
    final roundsAtChangeController = TextEditingController(
      text: '${part?.roundsAtChange ?? 0}',
    );
    DateTime selectedDate = part?.changedAt ?? DateTime.now();
    String? errorText;

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setStateDlg) {
            InputDecoration fieldDecoration({
              required String labelText,
              String? hintText,
              String? errorText,
              String? suffixText,
            }) {
              return InputDecoration(
                labelText: labelText,
                hintText: hintText,
                errorText: errorText,
                suffixText: suffixText,
                hintStyle: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.38),
                ),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.outline),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.error),
                ),
              );
            }

            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            (part == null
                                    ? strings.partChangeTitle
                                    : strings.editPartReplacement)
                                .toUpperCase(),
                            style: textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: strings.close,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Divider(
                      height: 1,
                      color: colors.outline.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: partController,
                        decoration: fieldDecoration(
                          labelText: strings.partNameLabel,
                          hintText: strings.partNameHint,
                        ),
                      ),
                      const Gap(16),
                      Text(
                        strings.dateLabel,
                        style: textStyles.labelMedium?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                      const Gap(8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final firstDate = DateTime(2000);
                          final initialDate = selectedDate.isBefore(firstDate)
                              ? firstDate
                              : selectedDate.isAfter(now)
                              ? now
                              : selectedDate;
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: firstDate,
                            lastDate: now,
                          );
                          if (picked != null) {
                            setStateDlg(
                              () => selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                        ),
                        label: Text(
                          AppDateFormats.formatDateShort(context, selectedDate),
                        ),
                      ),
                      const Gap(16),
                      TextField(
                        controller: roundsAtChangeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          if (errorText != null) {
                            setStateDlg(() => errorText = null);
                          }
                        },
                        decoration: fieldDecoration(
                          labelText: strings.partStartingRoundsLabel,
                          errorText: errorText,
                          suffixText: strings.shotsLower,
                        ),
                      ),
                      const Gap(16),
                      TextField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: fieldDecoration(
                          labelText: strings.partChangeCommentLabel,
                          hintText: strings.partChangeCommentHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(ctx, false);
                  },
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (partController.text.trim().isEmpty) return;
                    final roundsAtChange = int.tryParse(
                      roundsAtChangeController.text.trim(),
                    );
                    if (roundsAtChange == null) {
                      setStateDlg(
                        () => errorText = strings.partStartingRoundsInvalid,
                      );
                      return;
                    }
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(ctx, true);
                  },
                  child: Text(strings.settingsDialogSave),
                ),
              ],
            );
          },
        ),
      );

      if (result != true) return;

      final name = partController.text.trim();
      final comment = commentController.text.trim();
      final roundsAtChange =
          int.tryParse(roundsAtChangeController.text.trim()) ??
          (part?.roundsAtChange ?? platform.totalRounds);
      if (part == null) {
        provider.recordPlatformPartChange(
          platformId: platform.id,
          partName: name,
          date: selectedDate,
          comment: comment,
          roundsAtChange: roundsAtChange,
        );
      } else {
        provider.updatePlatformReplacementPart(
          platformId: platform.id,
          part: part.copyWith(
            name: name,
            changedAt: selectedDate,
            roundsAtChange: roundsAtChange,
            platformRoundsAtChange: part.platformRoundsAtChange,
            comment: comment,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.partChangeRecordedSuccess),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        partController.dispose();
        commentController.dispose();
        roundsAtChangeController.dispose();
      });
    }
  }

  Future<void> _deletePlatformReplacementPart({
    required ThotProvider provider,
    required Platform platform,
    required PlatformReplacementPart part,
  }) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmation),
        content: Text(strings.confirmDeletePartReplacement),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    provider.deletePlatformReplacementPart(
      platformId: platform.id,
      partId: part.id,
    );
  }

  Map<String, int> _calculateUsageHistory(
    ThotProvider provider,
    String itemId,
    String itemType,
  ) {
    final Map<String, int> history = {};
    final now = DateTime.now();
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final sessions = provider.sessions;

    if (_selectedPeriod == 'week') {
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final key = DateFormat.E(localeTag).format(date);
        history[key] = 0;
      }

      for (var session in sessions) {
        final daysDiff = now.difference(session.date).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          final key = DateFormat.E(localeTag).format(session.date);
          for (var exercise in session.exercises) {
            bool isMatch = false;
            if (itemType == 'PLATEFORME') {
              isMatch = exercise.platformId == itemId;
            } else if (itemType == 'CONSOMMABLE') {
              isMatch = exercise.ammoId == itemId;
            } else if (itemType == 'ACCESSOIRE') {
              isMatch = exercise.equipmentIds.contains(itemId);
            }

            if (isMatch) {
              history[key] = (history[key] ?? 0) + exercise.shotsFired;
            }
          }
        }
      }
    } else if (_selectedPeriod == 'month') {
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i);
        final key = DateFormat.MMM(localeTag).format(date);
        history[key] = 0;
      }

      for (var session in sessions) {
        final monthsDiff =
            (now.year - session.date.year) * 12 +
            (now.month - session.date.month);
        if (monthsDiff >= 0 && monthsDiff < 6) {
          final key = DateFormat.MMM(localeTag).format(session.date);
          for (var exercise in session.exercises) {
            bool isMatch = false;
            if (itemType == 'PLATEFORME') {
              isMatch = exercise.platformId == itemId;
            } else if (itemType == 'CONSOMMABLE') {
              isMatch = exercise.ammoId == itemId;
            } else if (itemType == 'ACCESSOIRE') {
              isMatch = exercise.equipmentIds.contains(itemId);
            }

            if (isMatch) {
              history[key] = (history[key] ?? 0) + exercise.shotsFired;
            }
          }
        }
      }
    } else {
      // Year
      for (int i = 5; i >= 0; i--) {
        final year = now.year - i;
        final key = year.toString();
        history[key] = 0;
      }

      for (var session in sessions) {
        final yearsDiff = now.year - session.date.year;
        if (yearsDiff >= 0 && yearsDiff < 6) {
          final key = session.date.year.toString();
          for (var exercise in session.exercises) {
            bool isMatch = false;
            if (itemType == 'PLATEFORME') {
              isMatch = exercise.platformId == itemId;
            } else if (itemType == 'CONSOMMABLE') {
              isMatch = exercise.ammoId == itemId;
            } else if (itemType == 'ACCESSOIRE') {
              isMatch = exercise.equipmentIds.contains(itemId);
            }

            if (isMatch) {
              history[key] = (history[key] ?? 0) + exercise.shotsFired;
            }
          }
        }
      }
    }

    return history;
  }

  int _roundsSincePartReplacement({
    required ThotProvider provider,
    required Platform platform,
    required PlatformReplacementPart part,
  }) {
    final changedAtDay = DateTime(
      part.changedAt.year,
      part.changedAt.month,
      part.changedAt.day,
    );
    var total = 0;
    for (final session in provider.sessions) {
      final sessionDay = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      if (sessionDay.isBefore(changedAtDay)) continue;
      for (final exercise in session.exercises) {
        total += exercise.platformShotImpact[platform.id] ?? 0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final provider = Provider.of<ThotProvider>(context);
    final strings = AppStrings.of(context);

    final platform = provider.getPlatformById(widget.itemId);
    final ammo = provider.getAmmoById(widget.itemId);
    final accessory = platform == null && ammo == null
        ? provider.accessories.where((a) => a.id == widget.itemId).firstOrNull
        : null;
    final linkedAccessories = platform != null
        ? provider.linkedAccessoriesForPlatform(platform.id)
        : const <Accessory>[];
    final linkedPlatforms = accessory != null
        ? provider.linkedPlatformsForAccessory(accessory.id)
        : const <Platform>[];

    if (platform == null && ammo == null && accessory == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.itemNotFound)),
        body: Center(child: Text(strings.itemDoesNotExist)),
      );
    }

    final String itemName;
    final String? headerSubtitle;
    final String itemType;
    final String lastUsedText;
    final List<ItemDocument> documents;
    final String? photoPath;
    final String comment;

    if (platform != null) {
      itemName = platform.name;
      headerSubtitle = null;
      itemType = 'PLATEFORME';
      lastUsedText = platform.lastUsed != null
          ? AppDateFormats.formatDateShort(context, platform.lastUsed!)
          : strings.neverUsed;
      documents = platform.documents;
      photoPath = platform.photoPath;
      comment = platform.comment;
    } else if (ammo != null) {
      itemName = ammo.name;
      headerSubtitle = null;
      itemType = 'CONSOMMABLE';
      lastUsedText = ammo.lastUsed != null
          ? AppDateFormats.formatDateShort(context, ammo.lastUsed!)
          : strings.neverUsed;
      documents = ammo.documents;
      photoPath = ammo.photoPath;
      comment = ammo.comment;
    } else {
      final acc = accessory!;
      itemName = acc.model.trim().isEmpty ? acc.name : acc.model;
      headerSubtitle = acc.brand.trim().isEmpty ? null : acc.brand;
      itemType = 'ACCESSOIRE';
      lastUsedText = acc.lastUsed != null
          ? AppDateFormats.formatDateShort(context, acc.lastUsed!)
          : strings.neverUsed;
      documents = acc.documents;
      photoPath = acc.photoPath;
      comment = acc.comment;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors.surfaceContainerHighest,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        // Même fond que la page d'inventaire (récap accessoires)
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 220 + MediaQuery.paddingOf(context).top,
                      width: double.infinity,
                      color: colors.surfaceContainerHighest,
                      child: photoPath == null
                          ? Icon(
                              Icons.image_not_supported_rounded,
                              size: 64,
                              color: colors.onSurfaceVariant,
                            )
                          : ClipRRect(
                              child: CrossPlatformImage(
                                filePath: photoPath,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 8,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => context.pop(),
                            tooltip: strings.close,
                            color: colors.onSurface,
                            style: IconButton.styleFrom(
                              backgroundColor: colors.surface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded),
                            tooltip: strings.edit,
                            onPressed: () => context.push(
                              '/inventory/add?itemId=${widget.itemId}&itemType=$itemType',
                            ),
                            color: colors.onSurface,
                            style: IconButton.styleFrom(
                              backgroundColor: colors.surface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              itemName.toUpperCase(),
                              style: textStyles.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (headerSubtitle != null) ...[
                              const Gap(2),
                              Text(
                                headerSubtitle,
                                style: textStyles.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (ammo == null) ...[
                        // ── Titre maintenance (plateforme/accessoire) ──
                        Row(
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.maintenanceStatus.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.sm),
                      ],
                      if (platform != null)
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.cardPremium,
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _StatusBar(
                                label: strings.revision,
                                percent: platform.revisionProgress,
                                color: platform.revisionProgress > 0.8
                                    ? colors.error
                                    : colors.primary,
                              ),
                              _StatusBar(
                                label: strings.cleanliness,
                                percent: platform.cleaningProgress,
                                color: platform.cleaningProgress > 0.8
                                    ? colors.error
                                    : colors.primary,
                              ),
                              const Divider(height: 32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        strings.totalShots,
                                        style: textStyles.labelSmall?.copyWith(
                                          color: colors.secondary,
                                        ),
                                      ),
                                      Text(
                                        '${platform.totalRounds}',
                                        style: textStyles.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        strings.lastShot,
                                        style: textStyles.labelSmall?.copyWith(
                                          color: colors.secondary,
                                        ),
                                      ),
                                      Text(
                                        lastUsedText,
                                        style: textStyles.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.md),
                              Column(
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _MaintenanceChip(
                                            icon:
                                                Icons.cleaning_services_rounded,
                                            label: strings.maintenance,
                                            value:
                                                '${platform.roundsSinceCleaning} / ${platform.cleaningRoundsThreshold} ${strings.shotsLower}',
                                            color:
                                                platform.cleaningProgress > 0.8
                                                ? colors.error
                                                : colors.secondary,
                                          ),
                                        ),
                                        const Gap(8),
                                        SizedBox(
                                          height: double.infinity,
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                              ),
                                              backgroundColor: colors.primary,
                                              foregroundColor: colors.onPrimary,
                                              elevation: 2,
                                              shadowColor: colors.primary
                                                  .withValues(alpha: 0.35),
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text(
                                                    strings.confirmation,
                                                  ),
                                                  content: Text(
                                                    strings
                                                        .confirmPlatformCleaningMessage,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: Text(
                                                        strings.cancel,
                                                      ),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: Text(
                                                        strings.confirm,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                provider.recordPlatformCleaning(
                                                  platform.id,
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        strings
                                                            .cleaningRecordedSuccess,
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 3,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: Text(strings.clean),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(8),
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _MaintenanceChip(
                                            icon: Icons.handyman_rounded,
                                            label: strings.revision,
                                            value:
                                                '${platform.roundsSinceRevision} / ${platform.wearRoundsThreshold} ${strings.shotsLower}',
                                            color:
                                                platform.revisionProgress > 0.8
                                                ? colors.error
                                                : colors.secondary,
                                          ),
                                        ),
                                        const Gap(8),
                                        SizedBox(
                                          height: double.infinity,
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                              ),
                                              backgroundColor: colors.primary,
                                              foregroundColor: colors.onPrimary,
                                              elevation: 2,
                                              shadowColor: colors.primary
                                                  .withValues(alpha: 0.35),
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text(
                                                    strings.confirmation,
                                                  ),
                                                  content: Text(
                                                    strings
                                                        .platformConfirmRevisionMessage,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: Text(
                                                        strings.cancel,
                                                      ),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: Text(
                                                        strings.confirm,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                provider.recordPlatformRevision(
                                                  platform.id,
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        strings
                                                            .revisionRecordedSuccess,
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 3,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: Text(strings.revision),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      icon: const Icon(
                                        Icons.build_circle_outlined,
                                      ),
                                      onPressed: () =>
                                          _showPartReplacementDialog(
                                            provider: provider,
                                            platform: platform,
                                          ),
                                      label: Text(strings.recordPartChange),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                        ),
                                        backgroundColor: colors.primary,
                                        foregroundColor: colors.onPrimary,
                                        elevation: 2,
                                        shadowColor: colors.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else if (ammo != null) ...[
                        // ── Titre stock/utilisation hors container ───────
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/pointe.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                colors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              strings.stockAndUsage.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.sm),
                        // ── Carte stock ────────────────────────────────
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.cardPremium,
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.currentStock,
                                    style: textStyles.labelSmall?.copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                  Text(
                                    '${ammo.quantity}',
                                    style: textStyles.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: ammo.quantity < 100
                                          ? colors.error
                                          : colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    strings.lastShot,
                                    style: textStyles.labelSmall?.copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                  Text(
                                    lastUsedText,
                                    style: textStyles.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(AppSpacing.md),
                        // ── Bouton réapprovisionner ──────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _showRestockSheet(ammo, provider),
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: Text(strings.restock),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              elevation: 2,
                              shadowColor: colors.primary.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.md),
                        // ── Coût ─────────────────────────────────────────
                        if (ammo.unitPrice != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.euro_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const Gap(8),
                              Text(
                                strings.costDashboardTitle.toUpperCase(),
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.sm),
                          Container(
                            padding: AppSpacing.paddingLg,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: AppShadows.cardPremium,
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? colors.outline
                                    : LightColors.surfaceHighlight,
                                width: 1.35,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoRow(
                                  icon: Icons.euro_rounded,
                                  label: strings.ammoTotalShotCost,
                                  value:
                                      '${provider.getAmmoTotalShotCost(ammo.id)?.toStringAsFixed(2) ?? '0.00'} ${_getCurrencySymbol(ammo.currency)}',
                                ),
                                const Gap(8),
                                _InfoRow(
                                  icon: Icons.euro_rounded,
                                  label: strings.ammoRemainingStockCost,
                                  value:
                                      '${provider.getAmmoRemainingStockCost(ammo.id)?.toStringAsFixed(2) ?? '0.00'} ${_getCurrencySymbol(ammo.currency)}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.cardPremium,
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                          ),
                          child: Builder(
                            builder: (context) {
                              final acc = accessory!;
                              final maintenanceEnabled = AccessoryTypeKey.maintenanceEnabled
                                  .contains(acc.type);

                              if (maintenanceEnabled) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _StatusBar(
                                      label: strings.revision,
                                      percent: acc.revisionProgress,
                                      color: acc.revisionProgress > 0.8
                                          ? colors.error
                                          : colors.primary,
                                    ),
                                    _StatusBar(
                                      label: strings.cleanliness,
                                      percent: acc.cleaningProgress,
                                      color: acc.cleaningProgress > 0.8
                                          ? colors.error
                                          : colors.primary,
                                    ),
                                    const Divider(height: 32),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              strings.totalShots,
                                              style: textStyles.labelSmall
                                                  ?.copyWith(
                                                    color: colors.secondary,
                                                  ),
                                            ),
                                            Text(
                                              '${acc.totalRounds}',
                                              style: textStyles.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              strings.lastShot,
                                              style: textStyles.labelSmall
                                                  ?.copyWith(
                                                    color: colors.secondary,
                                                  ),
                                            ),
                                            Text(
                                              lastUsedText,
                                              style: textStyles.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Gap(AppSpacing.md),
                                    Column(
                                      children: [
                                        IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: _MaintenanceChip(
                                                  icon: Icons
                                                      .cleaning_services_rounded,
                                                  label: strings.maintenance,
                                                  value:
                                                      '${acc.roundsSinceCleaning} / ${acc.cleaningRoundsThreshold} ${strings.shotsLower}',
                                                  color:
                                                      acc.cleaningProgress > 0.8
                                                      ? colors.error
                                                      : colors.secondary,
                                                ),
                                              ),
                                              const Gap(8),
                                              SizedBox(
                                                height: double.infinity,
                                                child: FilledButton(
                                                  style: FilledButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppRadius.lg,
                                                          ),
                                                    ),
                                                    backgroundColor:
                                                        colors.primary,
                                                    foregroundColor:
                                                        colors.onPrimary,
                                                    elevation: 2,
                                                    shadowColor: colors.primary
                                                        .withValues(
                                                          alpha: 0.35,
                                                        ),
                                                  ),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: Text(
                                                          strings.confirmation,
                                                        ),
                                                        content: Text(
                                                          strings.accessoryConfirmCleaningMessage,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  false,
                                                                ),
                                                            child: Text(
                                                              strings.cancel,
                                                            ),
                                                          ),
                                                          FilledButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  true,
                                                                ),
                                                            child: Text(
                                                              strings.confirm,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      provider
                                                          .recordAccessoryCleaning(
                                                            acc.id,
                                                          );
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              strings
                                                                  .maintenanceRecordedSuccess,
                                                            ),
                                                            duration:
                                                                const Duration(
                                                                  seconds: 3,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Text(strings.clean),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(8),
                                        IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: _MaintenanceChip(
                                                  icon: Icons.handyman_rounded,
                                                  label: strings.revision,
                                                  value:
                                                      '${acc.roundsSinceRevision} / ${acc.wearRoundsThreshold} coups',
                                                  color:
                                                      acc.revisionProgress > 0.8
                                                      ? colors.error
                                                      : colors.secondary,
                                                ),
                                              ),
                                              const Gap(8),
                                              SizedBox(
                                                height: double.infinity,
                                                child: FilledButton(
                                                  style: FilledButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppRadius.lg,
                                                          ),
                                                    ),
                                                    backgroundColor:
                                                        colors.primary,
                                                    foregroundColor:
                                                        colors.onPrimary,
                                                    elevation: 2,
                                                    shadowColor: colors.primary
                                                        .withValues(
                                                          alpha: 0.35,
                                                        ),
                                                  ),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: Text(
                                                          strings.confirmation,
                                                        ),
                                                        content: Text(
                                                          strings.accessoryConfirmRevisionMessage,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  false,
                                                                ),
                                                            child: Text(
                                                              strings.cancel,
                                                            ),
                                                          ),
                                                          FilledButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  true,
                                                                ),
                                                            child: Text(
                                                              strings.confirm,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      provider
                                                          .recordAccessoryRevision(
                                                            acc.id,
                                                          );
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              strings
                                                                  .revisionRecordedSuccess,
                                                            ),
                                                            duration:
                                                                const Duration(
                                                                  seconds: 3,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Text(
                                                    strings.reviseLabel,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_rounded,
                                        size: 18,
                                        color: colors.primary,
                                      ),
                                      const Gap(8),
                                      Text(
                                        strings.accessoryStatusTitle,
                                        style: textStyles.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(AppSpacing.md),
                                  _InfoRowSvg(
                                    assetPath: 'assets/images/hit.svg',
                                    label: strings.shotsFired,
                                    value: '${acc.totalRounds}',
                                  ),
                                  if (acc.batteryChangedAt != null) ...[
                                    const Gap(12),
                                    _InfoRow(
                                      icon: Icons.battery_charging_full_rounded,
                                      label: strings.batteryChangedLabel,
                                      value: AppDateFormats.formatDateShort(
                                        context,
                                        acc.batteryChangedAt!,
                                      ),
                                    ),
                                  ],
                                  const Divider(height: 32),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        strings.lastShot,
                                        style: textStyles.labelSmall?.copyWith(
                                          color: colors.secondary,
                                        ),
                                      ),
                                      Text(
                                        lastUsedText,
                                        style: textStyles.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const Gap(AppSpacing.lg),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const Gap(8),
                          Text(
                            strings.specificationsTitle,
                            style: textStyles.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness ==
                                    Brightness.dark
                                ? colors.outline
                                : LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                          boxShadow: AppShadows.cardPremium,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final items = <Widget>[
                              if (platform != null) ...[
                                _InfoRowSvg(
                                  assetPath: 'assets/images/pointe.svg',
                                  label: strings.caliberLabel,
                                  value: platform.caliber,
                                ),
                                _InfoRow(
                                  icon: Icons.list_alt_rounded,
                                  label: strings.modelLabel,
                                  value: platform.model,
                                ),
                                _InfoRow(
                                  icon: Icons.numbers_rounded,
                                  label: strings.serialNumberLabel,
                                  value: platform.serialNumber,
                                ),
                                _InfoRow(
                                  icon: Icons.scale_rounded,
                                  label: strings.emptyWeightLabel,
                                  value: '${platform.weight} g',
                                ),
                                _InfoRow(
                                  icon: Icons.cleaning_services_rounded,
                                  label: strings.lastCleaningLabel,
                                  value: AppDateFormats.formatDateShort(
                                    context,
                                    platform.lastCleaned,
                                  ),
                                ),
                                _InfoRow(
                                  icon: Icons.handyman_rounded,
                                  label: strings.lastRevisionLabel,
                                  value: AppDateFormats.formatDateShort(
                                    context,
                                    platform.lastRevised,
                                  ),
                                ),
                              ] else if (ammo != null) ...[
                                _InfoRowSvg(
                                  assetPath: 'assets/images/pointe.svg',
                                  label: strings.caliberLabel,
                                  value: ammo.caliber,
                                ),
                                _InfoRow(
                                  icon: Icons.business_rounded,
                                  label: strings.brandLabel,
                                  value: ammo.brand,
                                ),
                                _InfoRow(
                                  icon: Icons.inventory_2_rounded,
                                  label: strings.currentStock,
                                  value:
                                      '${ammo.quantity} ${strings.cartridges}',
                                ),
                              ] else ...[
                                _InfoRow(
                                  icon: Icons.local_offer_rounded,
                                  label: strings.typeLabel,
                                  value: strings.itemAccessoryTypeLabel(
                                    accessory!.type,
                                  ),
                                ),
                                if (accessory.brand.isNotEmpty)
                                  _InfoRow(
                                    icon: Icons.business_rounded,
                                    label: strings.brandLabel,
                                    value: accessory.brand,
                                  ),
                                if (accessory.model.isNotEmpty)
                                  _InfoRow(
                                    icon: Icons.list_alt_rounded,
                                    label: strings.modelLabel,
                                    value: accessory.model,
                                  ),
                                _InfoRowSvg(
                                  assetPath: 'assets/images/hit.svg',
                                  label: strings.shotsFired,
                                  value: '${accessory.totalRounds}',
                                ),
                                if (accessory.batteryChangedAt != null)
                                  _InfoRow(
                                    icon: Icons.battery_charging_full_rounded,
                                    label: strings.batteryChangedLabel,
                                    value: AppDateFormats.formatDateShort(
                                      context,
                                      accessory.batteryChangedAt!,
                                    ),
                                  ),
                              ],
                            ];

                            final colWidth = (constraints.maxWidth - 16) / 2;
                            final rows = <Widget>[];
                            for (int i = 0; i < items.length; i += 2) {
                              rows.add(
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: colWidth, child: items[i]),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: colWidth,
                                      child: i + 1 < items.length
                                          ? items[i + 1]
                                          : const SizedBox(),
                                    ),
                                  ],
                                ),
                              );
                              if (i + 2 < items.length) {
                                rows.add(const Gap(12));
                              }
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: rows,
                            );
                          },
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      if (platform != null || accessory != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                const Gap(8),
                                Text(
                                  strings.liaisonsLabel.toUpperCase(),
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            if (platform != null)
                              FilledButton.icon(
                                onPressed: () => _editLinkedAccessories(
                                  provider,
                                  platform.id,
                                ),
                                icon: const Icon(Icons.link_rounded, size: 18),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Text(strings.linkToAccessory)],
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                  elevation: 2,
                                  shadowColor: colors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              )
                            else if (accessory != null)
                              FilledButton.icon(
                                onPressed: () => _editLinkedPlatforms(
                                  provider,
                                  accessory.id,
                                ),
                                icon: const Icon(Icons.link_rounded, size: 18),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Text(strings.linkToPlatform)],
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                  elevation: 2,
                                  shadowColor: colors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                            boxShadow: AppShadows.cardPremium,
                          ),
                          child:
                              (platform != null && linkedAccessories.isEmpty) ||
                                  (accessory != null && linkedPlatforms.isEmpty)
                              ? Text(
                                  platform != null
                                      ? strings.noAccessoryLinked
                                      : strings.noPlatformLinked,
                                  style: textStyles.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: platform != null
                                      ? linkedAccessories
                                            .map(
                                              (a) => Chip(
                                                backgroundColor: colors.primary,
                                                side: BorderSide.none,
                                                labelStyle: TextStyle(
                                                  color: colors.onPrimary,
                                                ),
                                                avatar: Icon(
                                                  Icons.inventory_2_rounded,
                                                  size: 16,
                                                  color: colors.onPrimary,
                                                ),
                                                label: Text(a.name),
                                              ),
                                            )
                                            .toList()
                                      : linkedPlatforms
                                            .map(
                                              (w) => Chip(
                                                backgroundColor: colors.primary,
                                                side: BorderSide.none,
                                                labelStyle: TextStyle(
                                                  color: colors.onPrimary,
                                                ),
                                                avatar: Icon(
                                                  Icons.link_rounded,
                                                  size: 16,
                                                  color: colors.onPrimary,
                                                ),
                                                label: Text(w.name),
                                              ),
                                            )
                                            .toList(),
                                ),
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      if (platform != null &&
                          platform.replacementParts.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.replacedPartsLabel.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                            boxShadow: AppShadows.cardPremium,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final part in platform.replacementParts) ...[
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    10,
                                    12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest
                                        .withValues(alpha: 0.34),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    border: Border.all(
                                      color: colors.outline.withValues(
                                        alpha: 0.42,
                                      ),
                                      width: 1.15,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  part.name,
                                                  style: textStyles.bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: colors.onSurface,
                                                      ),
                                                ),
                                                const Gap(3),
                                                Text(
                                                  '${strings.partChangedOnLabel} ${AppDateFormats.formatDateShort(context, part.changedAt)}',
                                                  style: textStyles.bodySmall
                                                      ?.copyWith(
                                                        color: colors.secondary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Gap(8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip:
                                                    strings.editPartReplacement,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                constraints:
                                                    const BoxConstraints.tightFor(
                                                      width: 34,
                                                      height: 34,
                                                    ),
                                                padding: EdgeInsets.zero,
                                                color: colors.primary,
                                                onPressed: () =>
                                                    _showPartReplacementDialog(
                                                      provider: provider,
                                                      platform: platform,
                                                      part: part,
                                                    ),
                                                icon: const Icon(
                                                  Icons.edit_rounded,
                                                  size: 19,
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: strings
                                                    .deletePartReplacement,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                constraints:
                                                    const BoxConstraints.tightFor(
                                                      width: 34,
                                                      height: 34,
                                                    ),
                                                padding: EdgeInsets.zero,
                                                color: colors.primary,
                                                onPressed: () =>
                                                    _deletePlatformReplacementPart(
                                                      provider: provider,
                                                      platform: platform,
                                                      part: part,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete_rounded,
                                                  size: 19,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Gap(10),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/pointe.svg',
                                            width: 12,
                                            height: 12,
                                            colorFilter: ColorFilter.mode(
                                              colors.onSurface.withValues(
                                                alpha: 0.82,
                                              ),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const Gap(6),
                                          Text(
                                            '${strings.partRoundsSinceChangeLabel} ${strings.shotsWithUnit(_roundsSincePartReplacement(provider: provider, platform: platform, part: part))}',
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.onSurface
                                                      .withValues(alpha: 0.86),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      if (part.comment.trim().isNotEmpty) ...[
                                        const Gap(10),
                                        Text(
                                          part.comment.trim(),
                                          style: textStyles.bodySmall?.copyWith(
                                            color: colors.secondary,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (part != platform.replacementParts.last)
                                  const Gap(10),
                              ],
                            ],
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      if (comment.trim().isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.commentLabel.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.35,
                            ),
                            boxShadow: AppShadows.cardPremium,
                          ),
                          child: Text(
                            comment.trim(),
                            style: textStyles.bodyMedium?.copyWith(
                              height: 1.5,
                              color: colors.onSurface,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const Gap(8),
                              Text(
                                strings.documentsLabel.toUpperCase(),
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          FilledButton.icon(
                            onPressed:
                                provider.canAddDocumentToItem(
                                  currentDocumentsCount: documents.length,
                                )
                                ? () => _addDocumentToCurrentItem(
                                    documents: documents,
                                    platform: platform,
                                    ammo: ammo,
                                    accessory: accessory,
                                  )
                                : () => context.push('/pro'),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(strings.settingsAddDocument),
                                if (!provider.isPremium &&
                                    !provider.canAddDocumentToItem(
                                      currentDocumentsCount: documents.length,
                                    )) ...[
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: LightColors.surfaceHighlight,
                                        width: 1.35,
                                      ),
                                    ),
                                    child: Text(
                                      strings.proBadge,
                                      style: textStyles.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              elevation: 2,
                              shadowColor: colors.primary.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      if (documents.isNotEmpty) ...[
                        ...documents.asMap().entries.map((entry) {
                          final index = entry.key;
                          final doc = entry.value;
                          final isLocked = provider.isItemDocumentLockedForFree(
                            documentIndex: index,
                          );

                          return _DocItem(
                            name: doc.name,
                            type: doc.type,
                            path: doc.path,
                            expiryDate: doc.expiryDate,
                            isLocked: isLocked,
                            onTap: () => isLocked
                                ? context.push('/pro')
                                : _openPdf(doc.path),
                            onEdit: () => _updateDocumentToCurrentItem(
                              documents: documents,
                              document: doc,
                              platform: platform,
                              ammo: ammo,
                              accessory: accessory,
                            ),
                            onDelete: () => _removeDocumentFromCurrentItem(
                              documents: documents,
                              document: doc,
                              platform: platform,
                              ammo: ammo,
                              accessory: accessory,
                            ),
                          );
                        }),
                        const Gap(AppSpacing.lg),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                            boxShadow: AppShadows.cardPremium,
                          ),
                          child: Text(
                            strings.settingsDocumentsEmptyTitle,
                            style: textStyles.bodyMedium?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      if (ammo != null) ...[
                        // ── Historique de réapprovisionnement ────────────
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.fullHistoryTitle.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                            boxShadow: AppShadows.cardPremium,
                          ),
                          child: () {
                            final sortedHistory = [...ammo.safeHistory]
                              ..sort((a, b) => b.date.compareTo(a.date));
                            if (sortedHistory.isEmpty) {
                              return Text(
                                strings.noRestockHistoryYet,
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.secondary,
                                ),
                              );
                            }
                            return Column(
                              children: sortedHistory.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/images/pointe.svg',
                                            width: 16,
                                            height: 16,
                                            colorFilter: ColorFilter.mode(
                                              colors.primary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${entry.label} ${strings.cartridges}',
                                              style: textStyles.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                            if (entry.comment != null &&
                                                entry.comment!.isNotEmpty)
                                              Text(
                                                entry.comment!,
                                                style: textStyles.bodySmall
                                                    ?.copyWith(
                                                      color: colors.secondary,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        AppDateFormats.formatDateShort(
                                          context,
                                          entry.date,
                                        ),
                                        style: textStyles.labelSmall?.copyWith(
                                          color: colors.secondary,
                                        ),
                                      ),
                                      const Gap(8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          size: 18,
                                        ),
                                        tooltip: strings.deleteButton,
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                strings.deleteHistoryEntryTitle,
                                              ),
                                              content: Text(
                                                strings
                                                    .deleteHistoryEntryConfirm,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                                  child: Text(
                                                    strings.cancelButton,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        colors.error,
                                                  ),
                                                  child: Text(
                                                    strings.deleteButton,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            provider.deleteAmmoHistoryEntry(
                                              ammo.id,
                                              entry.id,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }(),
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      if (platform != null || ammo != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bar_chart_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                const Gap(8),
                                Text(
                                  strings.usageHistoryShotsTitle.toUpperCase(),
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              initialValue: _selectedPeriod,
                              tooltip: strings.usageHistoryShotsTitle,
                              onSelected: (v) =>
                                  setState(() => _selectedPeriod = v),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'week',
                                  child: Text(strings.weekLabel),
                                ),
                                PopupMenuItem(
                                  value: 'month',
                                  child: Text(strings.monthLabel),
                                ),
                                PopupMenuItem(
                                  value: 'year',
                                  child: Text(strings.yearLabel),
                                ),
                              ],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedPeriod == 'week'
                                        ? strings.weekLabel
                                        : _selectedPeriod == 'year'
                                        ? strings.yearLabel
                                        : strings.monthLabel,
                                    style: textStyles.labelLarge?.copyWith(
                                      color: colors.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colors.secondary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Builder(
                          builder: (context) {
                            final history = _calculateUsageHistory(
                              provider,
                              widget.itemId,
                              platform != null ? 'PLATEFORME' : 'CONSOMMABLE',
                            );
                            final labels = history.keys.toList();
                            final values = history.values.toList();
                            final maxValue = values.isEmpty
                                ? 100.0
                                : values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble();

                            return Container(
                              height: 200,
                              padding: AppSpacing.paddingLg,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? colors.outline
                                      : LightColors.surfaceHighlight,
                                  width: 1.35,
                                ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: values.isEmpty || maxValue == 0
                                  ? Center(
                                      child: Text(
                                        strings.noDataForThisPeriod,
                                        style: textStyles.bodyMedium?.copyWith(
                                          color: colors.secondary,
                                        ),
                                      ),
                                    )
                                  : BarChart(
                                      BarChartData(
                                        barTouchData: BarTouchData(
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipColor: (_) =>
                                                colors.primary,
                                            getTooltipItem:
                                                (
                                                  group,
                                                  groupIndex,
                                                  rod,
                                                  rodIndex,
                                                ) {
                                                  return BarTooltipItem(
                                                    rod.toY.toInt().toString(),
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                        gridData: const FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(),
                                          rightTitles: const AxisTitles(),
                                          topTitles: const AxisTitles(),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() >= 0 &&
                                                    value.toInt() <
                                                        labels.length) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Text(
                                                      labels[value.toInt()],
                                                      style:
                                                          textStyles.labelSmall,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: List.generate(
                                          values.length,
                                          (index) => BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY: values[index].toDouble(),
                                                color: colors.primary,
                                                width: 20,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        maxY: maxValue * 1.2,
                                      ),
                                    ),
                            );
                          },
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      if (accessory != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bar_chart_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                const Gap(8),
                                Text(
                                  strings.usageHistoryShotsTitle,
                                  style: textStyles.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              initialValue: _selectedPeriod,
                              tooltip: strings.usageHistoryShotsTitle,
                              onSelected: (v) =>
                                  setState(() => _selectedPeriod = v),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'week',
                                  child: Text(strings.weekLabel),
                                ),
                                PopupMenuItem(
                                  value: 'month',
                                  child: Text(strings.monthLabel),
                                ),
                                PopupMenuItem(
                                  value: 'year',
                                  child: Text(strings.yearLabel),
                                ),
                              ],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedPeriod == 'week'
                                        ? strings.weekLabel
                                        : _selectedPeriod == 'year'
                                        ? strings.yearLabel
                                        : strings.monthLabel,
                                    style: textStyles.labelLarge?.copyWith(
                                      color: colors.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colors.secondary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Builder(
                          builder: (context) {
                            final history = _calculateUsageHistory(
                              provider,
                              widget.itemId,
                              'ACCESSOIRE',
                            );
                            final labels = history.keys.toList();
                            final values = history.values.toList();
                            final maxValue = values.isEmpty
                                ? 100.0
                                : values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble();
                            return Container(
                              height: 200,
                              padding: AppSpacing.paddingLg,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? colors.outline
                                      : LightColors.surfaceHighlight,
                                  width: 1.2,
                                ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: values.isEmpty || maxValue == 0
                                  ? Center(
                                      child: Text(
                                        strings.noDataForThisPeriod,
                                        style: textStyles.bodyMedium?.copyWith(
                                          color: colors.secondary,
                                        ),
                                      ),
                                    )
                                  : BarChart(
                                      BarChartData(
                                        barTouchData: BarTouchData(
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipColor: (_) =>
                                                colors.primary,
                                            getTooltipItem:
                                                (
                                                  group,
                                                  groupIndex,
                                                  rod,
                                                  rodIndex,
                                                ) {
                                                  return BarTooltipItem(
                                                    rod.toY.toInt().toString(),
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(),
                                          rightTitles: const AxisTitles(),
                                          topTitles: const AxisTitles(),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() >= 0 &&
                                                    value.toInt() <
                                                        labels.length) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Text(
                                                      labels[value.toInt()],
                                                      style:
                                                          textStyles.labelSmall,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        barGroups: List.generate(
                                          values.length,
                                          (index) => BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY: values[index].toDouble(),
                                                color: colors.primary,
                                                width: 20,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        maxY: maxValue * 1.2,
                                      ),
                                    ),
                            );
                          },
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      if (platform != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.fullHistoryTitle.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.md),
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colors.outline
                                  : LightColors.surfaceHighlight,
                              width: 1.2,
                            ),
                            boxShadow: AppShadows.cardPremium,
                          ),
                          child: () {
                            final filteredHistory =
                                platform.history
                                    .where(
                                      (h) =>
                                          h.type == 'entretien' ||
                                          h.type == 'revision' ||
                                          h.type == 'piece',
                                    )
                                    .toList()
                                  ..sort((a, b) => b.date.compareTo(a.date));

                            if (filteredHistory.isEmpty) {
                              return Text(
                                strings.noMaintenanceHistoryRecorded,
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.secondary,
                                ),
                              );
                            }

                            return Column(
                              children: filteredHistory
                                  .map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _PlatformHistoryRow(entry: entry),
                                    ),
                                  )
                                  .toList(),
                            );
                          }(),
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPdf(String pdfPath) async {
    final strings = AppStrings.of(context);
    try {
      if (pdfPath.startsWith('http://') || pdfPath.startsWith('https://')) {
        final uri = Uri.parse(pdfPath);
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) throw Exception('launchUrl failed for http(s)');
        return;
      }

      if (pdfPath.startsWith('content://')) {
        final uri = Uri.parse(pdfPath);
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) throw Exception('launchUrl failed for content://');
        return;
      }

      // Local file path: use OpenFilex for proper file opening on Android/iOS
      final result = await OpenFilex.open(pdfPath);
      if (result.type != ResultType.done) {
        throw Exception('OpenFilex failed: ${result.message}');
      }
    } catch (e) {
      debugPrint('Failed to open PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.cannotOpenDocument),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _StatusBar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: textStyles.labelSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(4),
          LinearProgressIndicator(
            value: percent,
            color: color,
            backgroundColor: colors.surface,
            minHeight: 6,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MaintenanceChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const Gap(2),
              Text(
                value,
                style: textStyles.bodySmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary, size: 18),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                value,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRowSvg extends StatelessWidget {
  final String assetPath;
  final String label;
  final String value;

  const _InfoRowSvg({
    required this.assetPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                value,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlatformHistoryRow extends StatelessWidget {
  final PlatformHistoryEntry entry;

  const _PlatformHistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    IconData icon;
    Color iconColor;

    switch (entry.type) {
      case 'revision':
        icon = Icons.handyman_rounded;
        iconColor = colors.primary;
        break;
      case 'entretien':
        icon = Icons.cleaning_services_rounded;
        iconColor = colors.primary;
        break;
      case 'piece':
        icon = Icons.build_circle_outlined;
        iconColor = colors.primary;
        break;
      default:
        icon = Icons.link_rounded;
        iconColor = colors.primary;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colors.outline
                  : LightColors.surfaceHighlight,
              width: 1.35,
            ),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const Gap(16),
        Expanded(
          child: Builder(
            builder: (context) {
              final display =
                  PlatformHistoryDisplay.from(entry, strings);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    display.label,
                    style: textStyles.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (display.details != null &&
                      display.details!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        display.details!,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const Gap(12),
        Text(
          AppDateFormats.formatDateShort(context, entry.date),
          style: textStyles.labelSmall?.copyWith(
            color: colors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DocItem extends StatelessWidget {
  final String name;
  final String type;
  final String path;
  final DateTime? expiryDate;
  final bool isLocked;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DocItem({
    required this.name,
    required this.type,
    required this.path,
    required this.expiryDate,
    required this.isLocked,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.contains('image/jpeg') ||
        lower.contains('image/png');
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    final baseTypeLabel = type.isEmpty ? strings.documentsLabel : type;
    final expiryLabel = expiryDate == null
        ? null
        : '${strings.docExpiryExpiresOn} ${AppDateFormats.formatDateShort(context, expiryDate!)}';
    final secondLine = expiryLabel == null
        ? baseTypeLabel
        : '$baseTypeLabel • $expiryLabel';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? colors.outline
                : LightColors.surfaceHighlight,
            width: 1.35,
          ),

          boxShadow: AppShadows.cardPremium,
        ),
        child: Stack(
          children: [
            Opacity(
              opacity: isLocked ? 0.45 : 1,
              child: Row(
                children: [
                  Icon(
                    _DocItem._isImagePath(path)
                        ? Icons.image_rounded
                        : Icons.picture_as_pdf_rounded,
                    color: _DocItem._isImagePath(path)
                        ? colors.primary
                        : colors.error,
                    size: 24,
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: textStyles.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Text(
                          secondLine,
                          style: textStyles.labelSmall?.copyWith(
                            color: colors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: strings.settingsDocumentActions,
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colors.secondary,
                    ),
                    onSelected: (value) {
                      if (value == 'open') {
                        onTap();
                      } else if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) {
                      if (isLocked) {
                        return [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(strings.delete),
                          ),
                        ];
                      }
                      return [
                        PopupMenuItem<String>(
                          value: 'open',
                          child: Text(strings.settingsOpenDocument),
                        ),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(strings.settingsEditDocument),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(strings.delete),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            if (isLocked)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: LightColors.surfaceHighlight,
                      width: 1.35,
                    ),
                  ),
                  child: Text(
                    strings.proBadge,
                    style: textStyles.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

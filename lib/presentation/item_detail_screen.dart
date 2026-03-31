import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thot/utils/web_document_opener.dart';
import '../theme.dart';
import '../data/thot_provider.dart';
import '../data/models.dart';
import 'package:thot/widgets/cross_platform_image.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/l10n/app_strings.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  String _selectedPeriod = 'month'; // 'week', 'month', 'year'

  static const List<String> _documentTypes = [
    'Facture',
    'Révision',
    'Entretien',
    'Manuel',
    'Garantie',
    'Autre',
  ];

  Future<void> _showRestockSheet(Ammo ammo, ThotProvider provider) async {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final controller = TextEditingController();

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
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
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
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
                  style:
                      textStyles.bodyMedium?.copyWith(color: colors.secondary),
                ),
                const Gap(AppSpacing.md),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.quantityToAdd,
                    hintText: strings.example250,
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                ),
                const Gap(AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () {
                    final raw = controller.text.trim();
                    final addQty = int.tryParse(raw);
                    if (addQty == null || addQty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.enterValidQuantity)),
                      );
                      return;
                    }

                    final updated = Ammo(
                      id: ammo.id,
                      name: ammo.name,
                      brand: ammo.brand,
                      caliber: ammo.caliber,
                      comment: ammo.comment,
                      projectileType: ammo.projectileType,
                      quantity: ammo.quantity + addQty,
                      initialQuantity: ammo.quantity + addQty,
                      imageUrl: ammo.imageUrl,
                      lastUsed: ammo.lastUsed,
                      trackStock: ammo.trackStock,
                      lowStockThreshold: ammo.lowStockThreshold,
                      documents: ammo.documents,
                      photoPath: ammo.photoPath,
                    );

                    provider.updateAmmo(updated);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${strings.stockUpdated}: ${updated.quantity} ${strings.cartridges}',
                        ),
                      ),
                    );
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
                  onPressed: () => Navigator.of(ctx).pop(),
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
    } finally {
      controller.dispose();
    }
  }

  PlatformFile? _normalizePickedPdf(PlatformFile file) {
    if (kIsWeb) {
      if (file.bytes == null) return null;
      final ext = (file.extension ?? '').toLowerCase();
      final isPdf = ext == 'pdf';
      final mime = isPdf
          ? 'application/pdf'
          : (ext == 'png'
              ? 'image/png'
              : (ext == 'jpg' || ext == 'jpeg')
                  ? 'image/jpeg'
                  : 'application/octet-stream');
      final base64Data = base64Encode(file.bytes!);
      final dataUrl = 'data:$mime;base64,$base64Data';
      return PlatformFile(
        name: file.name,
        size: file.size,
        path: dataUrl,
        bytes: file.bytes,
      );
    }

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
    final nameController = TextEditingController(
      text: initialName.isEmpty ? strings.itemDefaultDocumentName : initialName,
    );
    int selectedNotifyDays = initialNotifyDays;
    String selectedType = _documentTypes.contains(initialType)
        ? initialType!
        : _documentTypes.first;
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
                style:
                    textStyles.labelMedium?.copyWith(color: colors.secondary),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              const Gap(16),
              Text(
                strings.settingsDocumentTypeLabel,
                style:
                    textStyles.labelMedium?.copyWith(color: colors.secondary),
              ),
              DropdownButtonFormField<String>(
                value: selectedType,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(),
                items: _documentTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(strings.itemDocumentTypeLabelForValue(t)),
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
                style:
                    textStyles.labelMedium?.copyWith(color: colors.secondary),
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
                                initialDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 20),
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
                            icon: const Icon(Icons.calendar_today_rounded,
                                size: 16),
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
                                        context, expiryDate!),
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
                  style:
                      textStyles.labelMedium?.copyWith(color: colors.secondary),
                ),
                DropdownButtonFormField<int>(
                  value: selectedNotifyDays > 0 ? selectedNotifyDays : 0,
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem<int>(
                        value: 0, child: Text('Aucune notification')),
                    DropdownMenuItem<int>(
                        value: 7, child: Text('1 semaine avant')),
                    DropdownMenuItem<int>(
                        value: 30, child: Text('1 mois avant')),
                    DropdownMenuItem<int>(
                        value: 90, child: Text('3 mois avant')),
                  ],
                  onChanged: (v) {
                    setState(() => selectedNotifyDays = v ?? 0);
                  },
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
              onPressed: () {
                final name = nameController.text.trim();
                Navigator.pop(
                  context,
                  (
                    name.isEmpty ? strings.itemDefaultDocumentName : name,
                    selectedType,
                    expiryDate,
                    selectedNotifyDays,
                  ),
                );
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
        SnackBar(content: Text(strings.itemFreePdfLimitSingle)),
      );
      context.push('/pro');
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final picked = _normalizePickedPdf(result.files.first);
    if (picked == null) return null;

    final details = await _askDocumentDetails(
      initialName: _stripPdfExtension(result.files.first.name),
    );
    if (!mounted || details == null) return null;

    return ItemDocument(
      path: picked.path ?? '',
      name: details.$1,
      type: details.$2,
      expiryDate: details.$3,
      notifyBeforeDays: details.$4,
    );
  }

  Future<void> _addDocumentToCurrentItem({
    required List<ItemDocument> documents,
    Weapon? weapon,
    Ammo? ammo,
    Accessory? accessory,
  }) async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final strings = AppStrings.of(context);

    final document = await _pickItemDocument(
      currentDocumentsCount: documents.length,
    );
    if (!mounted || document == null) return;

    if (weapon != null) {
      provider.updateWeapon(
        weapon.copyWith(documents: [...weapon.documents, document]),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.settingsDocumentAddedSuccess)),
    );
  }

  Future<void> _updateDocumentToCurrentItem({
    required List<ItemDocument> documents,
    required ItemDocument document,
    Weapon? weapon,
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

    if (weapon != null) {
      provider.updateWeapon(weapon.copyWith(documents: updatedDocuments));
    } else if (ammo != null) {
      provider.updateAmmo(ammo.copyWith(documents: updatedDocuments));
    } else if (accessory != null) {
      provider.updateAccessory(
        accessory.copyWith(documents: updatedDocuments),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.settingsDocumentUpdatedSuccess)),
    );
  }

  Future<void> _removeDocumentFromCurrentItem({
    required List<ItemDocument> documents,
    required ItemDocument document,
    Weapon? weapon,
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

    if (weapon != null) {
      provider.updateWeapon(weapon.copyWith(documents: updatedDocuments));
    } else if (ammo != null) {
      provider.updateAmmo(ammo.copyWith(documents: updatedDocuments));
    } else if (accessory != null) {
      provider.updateAccessory(
        accessory.copyWith(documents: updatedDocuments),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.settingsDocumentDeleted(document.name))),
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
            if ((itemType == 'ARME' && exercise.weaponId == itemId) ||
                (itemType == 'MUNITION' && exercise.ammoId == itemId)) {
              history[key] = (history[key] ?? 0) + exercise.shotsFired;
            }
          }
        }
      }
    } else if (_selectedPeriod == 'month') {
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final key = DateFormat.MMM(localeTag).format(date);
        history[key] = 0;
      }

      for (var session in sessions) {
        final monthsDiff = (now.year - session.date.year) * 12 +
            (now.month - session.date.month);
        if (monthsDiff >= 0 && monthsDiff < 6) {
          final key = DateFormat.MMM(localeTag).format(session.date);
          for (var exercise in session.exercises) {
            if ((itemType == 'ARME' && exercise.weaponId == itemId) ||
                (itemType == 'MUNITION' && exercise.ammoId == itemId)) {
              history[key] = (history[key] ?? 0) + exercise.shotsFired;
            }
          }
        }
      }
    } else {
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
            if ((itemType == 'ARME' && exercise.weaponId == itemId) ||
                (itemType == 'MUNITION' && exercise.ammoId == itemId)) {
              history[key] = (history[key] ?? 0) + exercise.shotsFired;
            }
          }
        }
      }
    }

    if (itemType == 'ACCESSOIRE') {
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
            if (exercise.equipmentIds.contains(itemId)) {
              history[key] = (history[key] ?? 0) + exercise.shotsFired;
            }
          }
        }
      }
      return history;
    }

    return history;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final provider = Provider.of<ThotProvider>(context);
    final strings = AppStrings.of(context);

    final weapon = provider.getWeaponById(widget.itemId);
    final ammo = provider.getAmmoById(widget.itemId);
    final accessory = weapon == null && ammo == null
        ? provider.accessories.where((a) => a.id == widget.itemId).firstOrNull
        : null;
    final linkedAccessories =
        weapon != null ? provider.linkedAccessoriesForWeapon(weapon.id) : const <Accessory>[];
    final linkedWeapons =
        accessory != null ? provider.linkedWeaponsForAccessory(accessory.id) : const <Weapon>[];

    if (weapon == null && ammo == null && accessory == null) {
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

    if (weapon != null) {
      itemName = weapon.name;
      headerSubtitle = null;
      itemType = 'ARME';
      lastUsedText = AppDateFormats.formatDateShort(context, weapon.lastUsed);
      documents = weapon.documents;
      photoPath = weapon.photoPath;
      comment = weapon.comment;
    } else if (ammo != null) {
      itemName = ammo.name;
      headerSubtitle = null;
      itemType = 'MUNITION';
      lastUsedText = AppDateFormats.formatDateShort(context, ammo.lastUsed);
      documents = ammo.documents;
      photoPath = ammo.photoPath;
      comment = ammo.comment;
    } else {
      final acc = accessory!;
      itemName = acc.model.trim().isEmpty ? acc.name : acc.model;
      headerSubtitle = acc.brand.trim().isEmpty ? null : acc.brand;
      itemType = 'ACCESSOIRE';
      lastUsedText = AppDateFormats.formatDateShort(context, acc.lastUsed);
      documents = acc.documents;
      photoPath = acc.photoPath;
      comment = acc.comment;
    }

    return Scaffold(
      // Même fond que la page d'inventaire (récap accessoires)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: 220,
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
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => context.pop(),
                          color: colors.onSurface,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                colors.surface.withValues(alpha: 0.5),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () => context.push(
                            '/inventory/add?itemId=${widget.itemId}&itemType=$itemType',
                          ),
                          color: colors.primary,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                colors.surface.withValues(alpha: 0.5),
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
                              headerSubtitle!,
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
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.maintenanceStatus,
                          style: textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    if (weapon != null)
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.cardPremium,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? colors.outline
                                : LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _StatusBar(
                              label: strings.revision,
                              percent: weapon.revisionProgress,
                              color: weapon.revisionProgress > 0.8
                                  ? colors.error
                                  : colors.primary,
                            ),
                            _StatusBar(
                              label: strings.cleanliness,
                              percent: weapon.cleaningProgress,
                              color: weapon.cleaningProgress > 0.8
                                  ? colors.error
                                  : colors.primary,
                            ),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      strings.totalShots,
                                      style: textStyles.labelSmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                    ),
Text(
                                      "${weapon.totalRounds}",
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
                                          icon: Icons.cleaning_services_rounded,
                                          label: strings.maintenance,
                                          value:
                                              '${weapon.roundsSinceCleaning} / ${weapon.cleaningRoundsThreshold} ${strings.shotsLower}',
                                          color: weapon.cleaningProgress > 0.8
                                              ? colors.error
                                              : colors.secondary,
                                        ),
                                      ),
                                      const Gap(8),
                                      SizedBox(
                                        height: double.infinity,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 0,
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
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title:
                                                    Text(strings.confirmation),
                                                content: Text(
                                                  strings
                                                      .confirmCleaningMessage,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, false),
                                                    child: Text(strings.cancel),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, true),
                                                    child:
                                                        Text(strings.confirm),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              provider.recordWeaponCleaning(
                                                weapon.id,
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      strings
                                                          .cleaningRecordedSuccess,
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
                                              '${weapon.roundsSinceRevision} / ${weapon.wearRoundsThreshold} ${strings.shotsLower}',
                                          color: weapon.revisionProgress > 0.8
                                              ? colors.error
                                              : colors.secondary,
                                        ),
                                      ),
                                      const Gap(8),
                                      SizedBox(
                                        height: double.infinity,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 0,
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
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text(
                                                  strings.confirmation,
                                                ),
                                                content: Text(
                                                  strings
                                                      .weaponConfirmRevisionMessage,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, false),
                                                    child: Text(strings.cancel),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, true),
                                                    child:
                                                        Text(strings.confirm),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              provider.recordWeaponRevision(
                                                weapon.id,
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      strings
                                                          .revisionRecordedSuccess,
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
                                    icon: const Icon(Icons.build_circle_outlined),
                                    onPressed: () async {
                                      final partController =
                                          TextEditingController();
                                      final commentController =
                                          TextEditingController();
                                      DateTime selectedDate = DateTime.now();
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => StatefulBuilder(
                                          builder: (ctx, setStateDlg) =>
                                              AlertDialog(
                                            title: Text(
                                              strings.partChangeTitle,
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
Text(
                                                    strings.partNameLabel,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          color: colors.secondary,
                                                        ),
                                                  ),
                                                 
TextField(
                                                    controller: partController,
                                                    decoration: InputDecoration(
                                                      hintText: strings.partNameHint,
                                                      filled: true,
fillColor: Color.alphaBlend(
                                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                                                        Theme.of(context).colorScheme.surface,
                                                      ),                                                    ),
                                                  ),
                                                  const Gap(16),
                                                  Text(
                                                    strings.dateLabel,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          color:
                                                              colors.secondary,
                                                        ),
                                                  ),
                                                  const Gap(8),
                                                  OutlinedButton.icon(
                                                    onPressed: () async {
                                                      final picked =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate: selectedDate,
                                                        firstDate:
                                                            DateTime(2000),
                                                        lastDate: DateTime.now()
                                                            .add(
                                                          const Duration(
                                                            days: 3650,
                                                          ),
                                                        ),
                                                      );
                                                      if (picked != null) {
                                                        setStateDlg(
                                                          () => selectedDate =
                                                              DateTime(
                                                            picked.year,
                                                            picked.month,
                                                            picked.day,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons
                                                          .calendar_today_rounded,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      AppDateFormats
                                                          .formatDateShort(
                                                        context,
                                                        selectedDate,
                                                      ),
                                                    ),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 12,
                                                        vertical: 12,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          AppRadius.sm,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Gap(16),
                                                  Text(
                                                    strings.partChangeCommentLabel,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          color: colors.secondary,
                                                        ),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        commentController,
                                                    maxLines: 3,
                                                    decoration: InputDecoration(
                                                      hintText: strings.partChangeCommentHint,
                                                      filled: true,
fillColor: Color.alphaBlend(
                                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                                                        Theme.of(context).colorScheme.surface,
                                                      ),                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: Text(strings.cancel),
                                              ),
                                              FilledButton(
                                                onPressed: () {
                                                  if (partController.text
                                                      .trim()
                                                      .isEmpty) {
                                                    return;
                                                  }
                                                  Navigator.pop(ctx, true);
                                                },
                                                child: Text(
                                                  strings.settingsDialogSave,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        provider.recordWeaponPartChange(
                                          weaponId: weapon.id,
                                          partName: partController.text.trim(),
                                          date: selectedDate,
                                          comment:
                                              commentController.text.trim(),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                strings
                                                    .partChangeRecordedSuccess,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    label: Text(
                                      strings.recordPartChange,
                                    ),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.lg),
                                      ),
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.onPrimary,
                                      elevation: 2,
                                      shadowColor: colors.primary
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else if (ammo != null)
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.cardPremium,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? colors.outline
                                : LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/bullet.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    colors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  strings.stockAndUsage,
                                  style: textStyles.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.md),
                            Row(
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
                                      "${ammo.quantity}",
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
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.cardPremium,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? colors.outline
                                : LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                        ),
child: Builder(
                          builder: (context) {
                            final acc = accessory!;
                            final maintenanceEnabledTypes = {
                              'Modérateurs',
                              'Réducteur de son',
                              'Compensateurs',
                              'Détentes',
                              'Pièces internes',
                            };
                            final maintenanceEnabled =
                                maintenanceEnabledTypes.contains(acc.type);

                            if (maintenanceEnabled) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                            style:
                                                textStyles.labelSmall?.copyWith(
                                              color: colors.secondary,
                                            ),
                                          ),
                                          Text(
                                            "${acc.totalRounds}",
                                            style:
                                                textStyles.titleLarge?.copyWith(
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
                                            style:
                                                textStyles.labelSmall?.copyWith(
                                              color: colors.secondary,
                                            ),
                                          ),
                                          Text(
                                            lastUsedText,
                                            style:
                                                textStyles.bodyMedium?.copyWith(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 0,
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
                                                      .withValues(alpha: 0.35),
                                                ),
                                                onPressed: () async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                        'Confirmation',
                                                      ),
                                                      content: const Text(
                                                        'Voulez-vous vraiment enregistrer un nettoyage complet pour cet accessoire ? Le compteur d\'entretien sera remis à zéro.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                          child: const Text(
                                                            'ANNULER',
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                          child: const Text(
                                                            'CONFIRMER',
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
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Entretien enregistré avec succès.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: const Text('Nettoyer'),
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
                                                label: 'Révision',
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 0,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                  ),
                                                  backgroundColor: colors.primary,
                                                  foregroundColor:
                                                      colors.onPrimary,
                                                  elevation: 2,
                                                  shadowColor: colors.primary
                                                      .withValues(alpha: 0.35),
                                                ),
                                                onPressed: () async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                        'Confirmation',
                                                      ),
                                                      content: const Text(
                                                        'Voulez-vous vraiment enregistrer une révision complète pour cet accessoire ? Le compteur de révision sera remis à zéro.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                          child: const Text(
                                                            'ANNULER',
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                          child: const Text(
                                                            'CONFIRMER',
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
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Révision enregistrée avec succès.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: const Text('Réviser'),
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
                                  value: "${acc.totalRounds}",
                                ),
                                if (acc.batteryChangedAt != null)
                                  _InfoRow(
                                    icon: Icons.battery_charging_full_rounded,
                                    label: strings.batteryChangedLabel,
                                    value: AppDateFormats.formatDateShort(
                                      context,
                                      acc.batteryChangedAt!,
                                    ),
                                  ),
                                const Divider(height: 32),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: AppSpacing.paddingLg,
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
                     child: LayoutBuilder(
                        builder: (context, constraints) {
                          final items = <Widget>[
                            if (weapon != null) ...[
                              _InfoRowSvg(
                                assetPath: 'assets/images/bullet.svg',
                                label: strings.caliberLabel,
                                value: weapon.caliber,
                              ),
                              _InfoRow(
                                icon: Icons.list_alt_rounded,
                                label: strings.modelLabel,
                                value: weapon.model,
                              ),
                              _InfoRow(
                                icon: Icons.numbers_rounded,
                                label: strings.serialNumberLabel,
                                value: weapon.serialNumber,
                              ),
                              _InfoRow(
                                icon: Icons.scale_rounded,
                                label: strings.emptyWeightLabel,
                                value: "${weapon.weight} g",
                              ),
                              _InfoRow(
                                icon: Icons.cleaning_services_rounded,
                                label: strings.lastCleaningLabel,
                                value: AppDateFormats.formatDateShort(
                                  context,
                                  weapon.lastCleaned,
                                ),
                              ),
                              _InfoRow(
                                icon: Icons.handyman_rounded,
                                label: strings.lastRevisionLabel,
                                value: AppDateFormats.formatDateShort(
                                  context,
                                  weapon.lastRevised,
                                ),
                              ),
                            ] else if (ammo != null) ...[
                              _InfoRowSvg(
                                assetPath: 'assets/images/bullet.svg',
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
                                value: "${ammo.quantity} ${strings.cartridges}",
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
                                value: "${accessory.totalRounds}",
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
                          }
                          return Column(children: rows);
                        },
                      ),
                    ),
                    const Gap(AppSpacing.lg),
                    if (weapon != null || accessory != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const Gap(8),
                          Text(
                            'Liaisons',
                            style: textStyles.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? colors.outline
                                : LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                          boxShadow: AppShadows.cardPremium,
                        ),
                        child: (weapon != null && linkedAccessories.isEmpty) ||
                                (accessory != null && linkedWeapons.isEmpty)
                            ? Text(
                                weapon != null
                                    ? 'Aucun accessoire lié.'
                                    : 'Aucune arme liée.',
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.secondary,
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: weapon != null
                                    ? linkedAccessories
                                        .map(
                                          (a) => Chip(
                                            avatar: const Icon(
                                              Icons.inventory_2_rounded,
                                              size: 16,
                                            ),
                                            label: Text(a.name),
                                          ),
                                        )
                                        .toList()
                                    : linkedWeapons
                                        .map(
                                          (w) => Chip(
                                            avatar: const Icon(
                                              Icons.sports_martial_arts_rounded,
                                              size: 16,
                                            ),
                                            label: Text(w.name),
                                          ),
                                        )
                                        .toList(),
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
                            strings.commentLabel,
                            style: textStyles.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
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
  color: Theme.of(context).brightness == Brightness.dark
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
                              strings.documentsLabel,
                              style: textStyles.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: provider.canAddDocumentToItem(
                            currentDocumentsCount: documents.length,
                          )
                              ? () => _addDocumentToCurrentItem(
                                    documents: documents,
                                    weapon: weapon,
                                    ammo: ammo,
                                    accessory: accessory,
                                  )
                              : () => context.push('/pro'),
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 18,
                          ),
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
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            elevation: 2,
                            shadowColor: colors.primary.withValues(alpha: 0.35),
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
                            weapon: weapon,
                            ammo: ammo,
                            accessory: accessory,
                          ),
                          onDelete: () => _removeDocumentFromCurrentItem(
                            documents: documents,
                            document: doc,
                            weapon: weapon,
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? colors.outline
                                : LightColors.surfaceHighlight,
                            width: 1.35,
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
                    if (weapon != null || ammo != null) ...[
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
                            onSelected: (v) => setState(() => _selectedPeriod = v),
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
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: colors.secondary,
                                  size: 16,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      Builder(
                        builder: (context) {
                          final history = _calculateUsageHistory(
                            provider,
                            widget.itemId,
                            weapon != null ? 'ARME' : 'MUNITION',
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
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
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
                                          getTooltipColor: (_) => colors.primary,
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            return BarTooltipItem(
                                              rod.toY.toInt().toString(),
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      gridData: FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
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
                              Icon(Icons.bar_chart_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(
                                strings.usageHistoryShotsTitle,
                                style: textStyles.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: colors.outline),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPeriod,
                                isDense: true,
                                style: textStyles.labelSmall
                                    ?.copyWith(color: colors.onSurface),
                                items: [
                                  DropdownMenuItem(
                                      value: 'week',
                                      child: Text(strings.weekLabel)),
                                  DropdownMenuItem(
                                      value: 'month',
                                      child: Text(strings.monthLabel)),
                                  DropdownMenuItem(
                                      value: 'year',
                                      child: Text(strings.yearLabel)),
                                ],
                                onChanged: (value) {
                                  if (value != null)
                                    setState(() => _selectedPeriod = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      Builder(builder: (context) {
                        final history = _calculateUsageHistory(
                            provider, widget.itemId, 'ACCESSOIRE');
                        final labels = history.keys.toList();
                        final values = history.values.toList();
                        final maxValue = values.isEmpty
                            ? 100.0
                            : values.reduce((a, b) => a > b ? a : b).toDouble();
                        return Container(
                          height: 200,
                          padding: AppSpacing.paddingLg,
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
                          child: values.isEmpty || maxValue == 0
                              ? Center(
                                  child: Text(strings.noDataForThisPeriod,
                                      style: textStyles.bodyMedium
                                          ?.copyWith(color: colors.secondary)))
                              : BarChart(BarChartData(
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (_) => colors.primary,
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          rod.toY.toInt().toString(),
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < labels.length) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(labels[value.toInt()],
                                                style: textStyles.labelSmall),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    )),
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
                                                      BorderRadius.circular(2))
                                            ],
                                          )),
                                  maxY: maxValue * 1.2,
                                )),
                        );
                      }),
                      const Gap(AppSpacing.lg),
                    ],
                    if (weapon != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const Gap(8),
                          Text(
                            strings.fullHistoryTitle,
                            style: textStyles.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? colors.outline
                                : LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                          boxShadow: AppShadows.cardPremium,
                        ),
                        child: () {
                          final filteredHistory = weapon.history
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
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _WeaponHistoryRow(entry: entry),
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
    );
  }

  Future<void> _openPdf(String pdfPath) async {
    try {
      if (kIsWeb && pdfPath.startsWith('data:')) {
        await WebDocumentOpener.openDataUrlInNewTab(
          pdfPath,
          windowName: '_blank',
        );
        return;
      }

      if (pdfPath.startsWith('http://') || pdfPath.startsWith('https://')) {
        final uri = Uri.parse(pdfPath);
        final ok = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw Exception('launchUrl failed for http(s)');
        return;
      }

      if (pdfPath.startsWith('content://')) {
        final uri = Uri.parse(pdfPath);
        final ok = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw Exception('launchUrl failed for content://');
        return;
      }

      final uri = Uri.file(pdfPath);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('launchUrl failed for file');
    } catch (e) {
      debugPrint('Failed to open PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le document')),
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
                label,
                style: textStyles.labelSmall?.copyWith(color: colors.secondary),
              ),
              Text(
                "${(percent * 100).toInt()}%",
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
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.35,
        ),
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
                label,
                style: textStyles.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w700,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 18),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textStyles.labelSmall?.copyWith(
                    color: colors.secondary,
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
      ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
                  label,
                  style: textStyles.labelSmall?.copyWith(
                    color: colors.secondary,
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
      ),
    );
  }
}

class _WeaponHistoryRow extends StatelessWidget {
  final WeaponHistoryEntry entry;

  const _WeaponHistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

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
        icon = Icons.sports_martial_arts_rounded;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.label,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (entry.details != null && entry.details!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    entry.details!,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ),
            ],
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
        : 'Expire le ${AppDateFormats.formatDateShort(context, expiryDate!)}';
    final secondLine =
        expiryLabel == null ? baseTypeLabel : '$baseTypeLabel • $expiryLabel';

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
Icon(
                    _DocItem._isImagePath(path) ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                    color: _DocItem._isImagePath(path) ? colors.primary : colors.error,
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
                    icon:
                        Icon(Icons.more_vert_rounded, color: colors.secondary),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

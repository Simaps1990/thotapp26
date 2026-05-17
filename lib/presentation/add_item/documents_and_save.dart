part of '../add_item_screen.dart';

extension _AddItemDocumentsAndSave on _AddItemScreenState {

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;
    final persisted = await ImageStorage.persistFromPath(picked.path);
    if (!mounted) return;
    setState(() => _photoPath = persisted);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.single;
    setState(() {
      _documents.add(
        _ItemDocumentDraft(
          name: file.name,
          type: DocumentTypeKey.other,
          file: file,
        ),
      );
    });
  }

  Future<void> _openDocumentPath(String path) async {
    if (path.trim().isEmpty) return;
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(Uri.file(path), mode: LaunchMode.externalApplication);
  }

  IconData _documentIconForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) {
      return Icons.image_rounded;
    }
    return Icons.description_rounded;
  }

  Color _documentIconColorForPath(ColorScheme colors, String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return colors.error;
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) {
      return colors.primary;
    }
    return colors.secondary;
  }

  Future<void> _shareDocument(_ItemDocumentDraft doc) async {
    final path = doc.file.path;
    if (path == null || path.trim().isEmpty) return;
    try {
      await Share.shareXFiles([XFile(path)], text: doc.name);
    } catch (e) {
      debugPrint('Failed to share document: $e');
    }
  }

  Future<void> _editDocument(_ItemDocumentDraft doc) async {
    final nameController = TextEditingController(text: doc.name);
    var selectedType = DocumentTypeKey.all.contains(doc.type)
        ? doc.type
        : DocumentTypeKey.other;
    final updated = await showDialog<_ItemDocumentDraft>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.of(context).settingsEditDocument),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController),
            const Gap(12),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: DocumentTypeKey.all
                  .map((key) => DropdownMenuItem(
                        value: key,
                        child: Text(AppStrings.of(context).documentTypeLabel(key)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedType = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              doc.name = nameController.text.trim().isEmpty
                  ? doc.file.name
                  : nameController.text.trim();
              doc.type = selectedType;
              Navigator.of(context).pop(doc);
            },
            child: Text(AppStrings.of(context).itemSavedSuccess),
          ),
        ],
      ),
    );
    nameController.dispose();
    if (!mounted || updated == null) return;
    setState(() {});
  }

  void _removeDocument(_ItemDocumentDraft doc) {
    setState(() => _documents.remove(doc));
  }

  Future<void> _pickBatteryChangedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _batteryChangedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    setState(() => _batteryChangedAt = picked);
  }

  Future<void> _saveItem() async {
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final now = DateTime.now();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      setState(() => _primaryNameError = true);
      Scrollable.ensureVisible(_primaryNameFieldKey.currentContext ?? context);
      return;
    }

    final docs = _documents.map((doc) => doc.toItemDocument()).where((doc) => doc.path.isNotEmpty).toList(growable: false);
    final id = widget.itemId ?? now.microsecondsSinceEpoch.toString();

    if (_selectedCategory == 'PLATEFORME') {
      if (_caliberController.text.trim().isEmpty) {
        setState(() => _caliberError = true);
        return;
      }
      final platform = Platform(
        id: id,
        name: _nameController.text.trim(),
        model: _brandController.text.trim(),
        caliber: _caliberController.text.trim(),
        serialNumber: _serialController.text.trim(),
        weight: double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0,
        totalRounds: int.tryParse(_initialRoundsController.text.trim()) ?? 0,
        lastCleaned: now,
        comment: _commentController.text.trim(),
        type: _selectedPlatformType,
        documents: docs,
        photoPath: _photoPath,
        trackWear: _trackWear,
        trackCleanliness: _trackCleanliness,
        trackRounds: _trackRounds,
        cleaningRoundsThreshold: int.tryParse(_cleaningRoundsThresholdController.text.trim()) ?? 500,
        wearRoundsThreshold: int.tryParse(_wearRoundsThresholdController.text.trim()) ?? 10000,
        linkedAccessoryIds: _linkedAccessoryIds.toList(growable: false),
      );
      _isEditMode ? provider.updatePlatform(platform) : provider.addPlatform(platform);
    } else if (_selectedCategory == 'CONSOMMABLE') {
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final ammo = Ammo(
        id: id,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        caliber: _caliberController.text.trim(),
        quantity: quantity,
        initialQuantity: int.tryParse(_initialRoundsController.text.trim()) ?? quantity,
        comment: _commentController.text.trim(),
        projectileType: _isAmmoProjectileTypeCustom ? _ammoTypeController.text.trim() : _selectedAmmoProjectileType,
        lowStockThreshold: int.tryParse(_lowStockThresholdController.text.trim()) ?? 50,
        documents: docs,
        photoPath: _photoPath,
        trackStock: _trackStock,
        unitPrice: double.tryParse(_unitPriceController.text.replaceAll(',', '.')),
        currency: _selectedCurrency,
      );
      _isEditMode ? provider.updateAmmo(ammo) : provider.addAmmo(ammo);
    } else {
      final model = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final accessory = Accessory(
        id: id,
        name: [brand, model].where((part) => part.trim().isNotEmpty).join(' ').trim().isEmpty
            ? model
            : [brand, model].where((part) => part.trim().isNotEmpty).join(' '),
        brand: brand,
        model: model,
        type: _isAccessoryTypeCustom ? _typeController.text.trim() : _selectedAccessoryType,
        comment: _commentController.text.trim(),
        lastCleaned: now,
        documents: docs,
        photoPath: _photoPath,
        trackBattery: _trackBattery,
        batteryChangedAt: _batteryChangedAt,
        trackWear: _trackWear,
        trackCleanliness: _trackCleanliness,
        cleaningRoundsThreshold: int.tryParse(_cleaningRoundsThresholdController.text.trim()) ?? 500,
        wearRoundsThreshold: int.tryParse(_wearRoundsThresholdController.text.trim()) ?? 10000,
        linkedPlatformIds: _linkedPlatformIds.toList(growable: false),
      );
      _isEditMode ? provider.updateAccessory(accessory) : provider.addAccessory(accessory);
    }

    _initialFormHash = _computeFormHash();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.itemSavedSuccess)),
    );
    context.pop();
  }
}

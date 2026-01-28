import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';
import '../providers/property_provider.dart';

class AddEditPropertyScreen extends ConsumerStatefulWidget {
  final Property? property;

  const AddEditPropertyScreen({super.key, this.property});

  @override
  ConsumerState<AddEditPropertyScreen> createState() =>
      _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends ConsumerState<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _bedsCtrl;
  late TextEditingController _bathsCtrl;
  late TextEditingController _sqftCtrl;
  late TextEditingController _imageCtrl;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _locationCtrl = TextEditingController(text: p?.location ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '');
    _bedsCtrl = TextEditingController(text: p?.beds.toString() ?? '0');
    _bathsCtrl = TextEditingController(text: p?.baths.toString() ?? '0');
    _sqftCtrl = TextEditingController(text: p?.sqft.toString() ?? '0');
    _imageCtrl = TextEditingController(
      text: p?.imageUrls.isNotEmpty == true ? p!.imageUrls.first : '',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _bedsCtrl.dispose();
    _bathsCtrl.dispose();
    _sqftCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _pickedImage = picked;
      _imageCtrl.text = picked.path;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final beds = int.tryParse(_bedsCtrl.text.trim()) ?? 0;
    final baths = double.tryParse(_bathsCtrl.text.trim()) ?? 0.0;
    final sqft = int.tryParse(_sqftCtrl.text.trim()) ?? 0;
    final img = _imageCtrl.text.trim();
    final imageUrls = img.isEmpty ? <String>[] : [img];

    final repo = ref.read(propertyRepositoryProvider);
    final now = DateTime.now();

    if (widget.property != null) {
      final updated = widget.property!.copyWith(
        title: title,
        description: desc,
        location: location,
        price: price,
        beds: beds,
        baths: baths,
        sqft: sqft,
        imageUrls: imageUrls.isEmpty ? widget.property!.imageUrls : imageUrls,
        lastUpdated: now,
      );
      await repo.updateProperty(updated);
    } else {
      final property = Property(
        title: title,
        description: desc,
        location: location,
        price: price,
        imageUrls: imageUrls.isEmpty
            ? ['assets/images/placeholder.png']
            : imageUrls,
        status: 'published',
        syncStatus: 'cached',
        lastUpdated: now,
        beds: beds,
        baths: baths,
        sqft: sqft,
      );
      await repo.saveProperty(property);
    }

    ref.invalidate(propertyListProvider);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.property != null ? 'Property updated' : 'Property added',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.property != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Property' : 'Add Property'),
        actions: [TextButton(onPressed: _submit, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Beds',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bathsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Baths',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sqftCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sq ft',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Image', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _pickedImage != null || _imageCtrl.text.isNotEmpty
                      ? SizedBox(
                          height: 120,
                          child: Image.file(
                            File(_imageCtrl.text),
                            fit: BoxFit.cover,
                          ),
                        )
                      : SizedBox(
                          height: 120,
                          child: Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _imageCtrl.clear();
                        setState(() => _pickedImage = null);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

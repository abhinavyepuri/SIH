import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/state/app_state.dart';
import '../../models/product.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class ListProductScreen extends StatefulWidget {
  final Product? editProduct;
  final bool isTab;
  final VoidCallback? onSaved;

  const ListProductScreen({
    super.key,
    this.editProduct,
    this.isTab = false,
    this.onSaved,
  });

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _materialsController;
  late TextEditingController _craftingProcessController;
  late TextEditingController _imageUrlController;
  late TextEditingController _tagsController;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _showManualUrlInput = false;

  String _selectedCategory = 'Ceramics';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  void _initForm() {
    final p = widget.editProduct;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? '${p.price.toInt()}' : '');
    _quantityController = TextEditingController(text: p != null ? '${p.quantity}' : '1');
    _materialsController = TextEditingController(text: p?.materials ?? '');
    _craftingProcessController = TextEditingController(text: p?.craftingProcess ?? '');
    _imageUrlController = TextEditingController(text: p?.images ?? '');
    _uploadedImageUrl = p?.images;
    _tagsController = TextEditingController(text: p?.tags ?? '');
    if (p != null && AppConstants.categories.contains(p.category)) {
      _selectedCategory = p.category;
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _priceController.clear();
    _quantityController.text = '1';
    _materialsController.clear();
    _craftingProcessController.clear();
    _imageUrlController.clear();
    _tagsController.clear();
    setState(() {
      _selectedImageBytes = null;
      _uploadedImageUrl = null;
      _isUploadingImage = false;
      _selectedCategory = 'Ceramics';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _materialsController.dispose();
    _craftingProcessController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      final fileName = file.name.isNotEmpty ? file.name : 'artisan_craft_${DateTime.now().millisecondsSinceEpoch}.jpg';

      setState(() {
        _selectedImageBytes = bytes;
        _isUploadingImage = true;
      });

      final res = await ApiClient.uploadFile('/products/upload', bytes, fileName);

      if (res.containsKey('url')) {
        final secureUrl = res['url'].toString();
        setState(() {
          _uploadedImageUrl = secureUrl;
          _imageUrlController.text = secureUrl;
          _isUploadingImage = false;
        });

        if (mounted) {
          final isCloudinary = res['provider'] == 'cloudinary';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isCloudinary
                    ? 'Photo saved to Cloudinary!'
                    : 'Photo saved successfully!',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Server did not return image URL');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'ATTACH CREATION PHOTO',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Capture piece with Camera or select high-res photo from Gallery',
                style: TextStyle(fontSize: 12, color: AppColors.warmGrayLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.navy),
                ),
                title: const Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
                subtitle: const Text('Snap your physical handcrafted work directly', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.gold),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
                subtitle: const Text('Select a high-resolution image from your device', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(String status) async {
    if (!_formKey.currentState!.validate()) return;

    final user = AppState.of(context).auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in as an artisan')),
      );
      return;
    }

    final finalImageUrl = _uploadedImageUrl?.trim().isNotEmpty == true
        ? _uploadedImageUrl!.trim()
        : _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null;

    setState(() => _isSaving = true);

    try {
      final payload = {
        'artisan_id': user.id,
        'title': _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : '$_selectedCategory Craft Work',
        'description': _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        'category': _selectedCategory,
        'materials': _materialsController.text.trim().isNotEmpty ? _materialsController.text.trim() : null,
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'currency': 'INR',
        'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
        'tags': _tagsController.text.trim().isNotEmpty ? _tagsController.text.trim() : null,
        'images': finalImageUrl,
        'status': status,
        'crafting_process': _craftingProcessController.text.trim().isNotEmpty ? _craftingProcessController.text.trim() : null,
      };

      if (widget.editProduct != null) {
        await ApiClient.put('/products/${widget.editProduct!.id}', payload);
      } else {
        await ApiClient.post('/products/', payload);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'published'
                ? 'Handcrafted piece published to gallery!'
                : 'Work saved as draft.',
          ),
          backgroundColor: AppColors.navy,
        ),
      );

      if (widget.isTab) {
        _resetForm();
        widget.onSaved?.call();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editProduct != null;
    final hasImage = _selectedImageBytes != null ||
        (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) ||
        _imageUrlController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.navy),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          isEdit ? 'EDIT CREATION' : 'LIST NEW WORK',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.navy,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section Card with Camera Capture
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PIECE PHOTOGRAPHY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.warmGray,
                          ),
                        ),
                        if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, size: 12, color: AppColors.success),
                                SizedBox(width: 4),
                                Text(
                                  'Cloudinary Ready',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Capture a clear photo of your craft using the camera or gallery.',
                      style: TextStyle(fontSize: 12, color: AppColors.warmGrayLight),
                    ),
                    const SizedBox(height: 16),

                    // Image Display / Upload Box
                    if (_isUploadingImage)
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.gold)),
                            SizedBox(height: 12),
                            Text(
                              'Uploading image to Cloudinary...',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
                            ),
                          ],
                        ),
                      )
                    else if (hasImage)
                      Column(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _selectedImageBytes != null
                                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                                  : Image.network(
                                      _uploadedImageUrl ?? _imageUrlController.text,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Text('Invalid image preview', style: TextStyle(fontSize: 11, color: AppColors.error)),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.navy,
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.camera_alt, size: 16),
                                  label: const Text('Change Photo', style: TextStyle(fontSize: 12)),
                                  onPressed: _showImageSourcePicker,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () {
                                  setState(() {
                                    _selectedImageBytes = null;
                                    _uploadedImageUrl = null;
                                    _imageUrlController.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: _showImageSourcePicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.navy),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Tap to Take Photo or Pick Image',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Camera & Gallery supported • Auto-saved to Cloudinary',
                                style: TextStyle(fontSize: 11, color: AppColors.warmGrayLight),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Toggle for manual URL input
                    GestureDetector(
                      onTap: () => setState(() => _showManualUrlInput = !_showManualUrlInput),
                      child: Row(
                        children: [
                          Icon(
                            _showManualUrlInput ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.warmGrayLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showManualUrlInput ? 'Hide manual image URL' : 'Or enter custom image URL',
                            style: const TextStyle(fontSize: 11, color: AppColors.warmGrayLight, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),

                    if (_showManualUrlInput) ...[
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: 'Direct Image URL',
                        hint: 'https://res.cloudinary.com/.../image.jpg',
                        controller: _imageUrlController,
                        onChanged: (v) => setState(() {
                          _uploadedImageUrl = v.trim();
                        }),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Work Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WORK DETAILS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.warmGray),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Title of Creation',
                      hint: 'e.g., Hand-Turned Blue Pottery Decorative Vase',
                      controller: _titleController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'CRAFT CATEGORY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: AppColors.warmGray),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.navy),
                          items: ['Ceramics', 'Textiles', 'Woodworking', 'Metalwork', 'Handicrafts']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedCategory = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Description & Cultural Story',
                      hint: 'Describe the heritage technique, inspiration, and regional provenance...',
                      controller: _descController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Primary Materials',
                      hint: 'e.g., Quartz stone, Fuller\'s earth, Cobalt glaze',
                      controller: _materialsController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Crafting Process / Techniques',
                      hint: 'e.g., Hand-molded on manual potters wheel, sun-dried, fired at 850°C',
                      controller: _craftingProcessController,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pricing & Inventory Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRICING & INVENTORY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.warmGray),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Price (INR)',
                            hint: '3450',
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter price' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Available Qty',
                            hint: '1',
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Tags (Comma-separated)',
                      hint: 'pottery, jaipur, blue-glaze',
                      controller: _tagsController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Save Draft',
                      variant: ButtonVariant.secondary,
                      isLoading: _isSaving,
                      onPressed: () => _handleSave('draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: isEdit ? 'Update Work' : 'Publish to Gallery',
                      isLoading: _isSaving,
                      onPressed: () => _handleSave('published'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

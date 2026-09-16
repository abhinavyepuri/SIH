import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/state/app_state.dart';
import '../../models/product.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class ListProductScreen extends StatefulWidget {
  final Product? editProduct;

  const ListProductScreen({super.key, this.editProduct});

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

  String _selectedCategory = 'Ceramics';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? '${p.price.toInt()}' : '');
    _quantityController = TextEditingController(text: p != null ? '${p.quantity}' : '1');
    _materialsController = TextEditingController(text: p?.materials ?? '');
    _craftingProcessController = TextEditingController(text: p?.craftingProcess ?? '');
    _imageUrlController = TextEditingController(text: p?.images ?? '');
    _tagsController = TextEditingController(text: p?.tags ?? '');
    if (p != null && AppConstants.categories.contains(p.category)) {
      _selectedCategory = p.category;
    }
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

  Future<void> _handleSave(String status) async {
    if (!_formKey.currentState!.validate()) return;

    final user = AppState.of(context).auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in as an artisan')),
      );
      return;
    }

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
        'images': _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
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

      Navigator.pop(context, true);
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

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
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
              // Image Section Card
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
                      'GALLERY IMAGERY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.warmGray),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add a high-resolution Cloudinary or photo URL showcasing your piece.',
                      style: TextStyle(fontSize: 12, color: AppColors.warmGrayLight),
                    ),
                    const SizedBox(height: 14),

                    // Image Preview if available
                    if (_imageUrlController.text.isNotEmpty) ...[
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrlController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('Invalid image URL', style: TextStyle(fontSize: 11, color: AppColors.error)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    CustomTextField(
                      label: 'Image URL (Cloudinary / HTTPS)',
                      hint: 'https://res.cloudinary.com/.../image.jpg',
                      controller: _imageUrlController,
                      onChanged: (v) => setState(() {}),
                    ),
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

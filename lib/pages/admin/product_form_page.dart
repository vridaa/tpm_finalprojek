import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gift_bouqet/model/productModel.dart';
import 'package:gift_bouqet/service/productService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/custom_form_button.dart';
import '../../common/custom_input_field.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product; // Nullable for adding new products

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;
  String? _imageUrl; // Existing image URL if editing
  bool _isLoading = false;

  final List<String> _categories = [
    'bunga segar',
    'artificial',
    'custom',
    'uang',
    'snack',
  ]; // New: hardcoded categories
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.nama;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      if (_categories.contains(widget.product!.category)) {
        _selectedCategory = widget.product!.category;
      } else {
        _selectedCategory =
            _categories
                .first; // Default to first if category not in allowed list
      }
      _imageUrl = widget.product!.imageUrl;
    } else {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show dialog to choose camera or gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Select Image Source'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Camera'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
      );

      if (source != null) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final CreateProductRequest request = CreateProductRequest(
          nama: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          category: _selectedCategory!,
        );

        if (widget.product == null) {
          // Create new product
          await ProductService.createProduct(request, imageFile: _imageFile);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product created successfully!')),
          );
        } else {
          // Update existing product
          await ProductService.updateProduct(
            widget.product!.produkID!,
            request,
            imageFile: _imageFile,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product updated successfully!')),
          );
        }

        Navigator.pop(context, true); // Indicate success
      } catch (e) {
        if (!mounted) return;
        debugPrint('Product save error: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: GoogleFonts.playfairDisplay(),
        ),
        backgroundColor: const Color(0xff233743),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInputField(
                controller: _nameController,
                labelText: 'Product Name',
                hintText: 'Enter product name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Product name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter product description',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _priceController,
                labelText: 'Price',
                hintText: 'Enter product price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null) {
                    return 'Invalid price format';
                  }
                  if (price <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Select product category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                  ),
                ),
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
                isExpanded: true,
              ),
              const SizedBox(height: 20),

              // Image Picker Section
              Text(
                'Product Image',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child:
                    _imageFile != null ||
                            (_imageUrl != null && _imageUrl!.isNotEmpty)
                        ? Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    _imageFile != null
                                        ? Image.file(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.network(
                                          _imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _pickImage,
                                      tooltip: 'Change Image',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _removeImage,
                                      tooltip: 'Remove Image',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                        : InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to select image',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Camera or Gallery',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
              ),

              const SizedBox(height: 30),

              CustomFormButton(
                innerText:
                    _isLoading
                        ? (widget.product == null ? 'Adding...' : 'Updating...')
                        : (widget.product == null
                            ? 'Add Product'
                            : 'Update Product'),
                onPressed: _isLoading ? null : _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

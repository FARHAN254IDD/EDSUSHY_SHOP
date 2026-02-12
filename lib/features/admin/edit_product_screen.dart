import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _originalPriceController =
        TextEditingController(text: widget.product?.originalPrice?.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _imageUrlController = TextEditingController(text: '');
    _categoryController =
        TextEditingController(text: widget.product?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _originalPriceController,
                decoration: InputDecoration(
                  labelText: 'Original Price (for discount)',
                  hintText: 'Leave empty if no discount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    final originalPrice = double.parse(value);
                    final currentPrice = double.tryParse(_priceController.text);
                    if (currentPrice != null && originalPrice <= currentPrice) {
                      return 'Original price must be higher than current price for discount';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter stock';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Please enter a valid stock number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'e.g. https://example.com/image.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final trimmed = value.trim();
                    if (!trimmed.startsWith('http')) {
                      return 'URL must start with http:// or https://';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: Center(
                  child: _imageUrlController.text.isNotEmpty
                    ? Image.network(_imageUrlController.text,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image))
                    : (widget.product?.imageUrl.isNotEmpty == true
                      ? (widget.product!.imageUrl.startsWith('http')
                        ? Image.network(widget.product!.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image))
                        : const Icon(Icons.image, size: 64))
                      : const Icon(Icons.image, size: 64)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          
                          // Validate image URL
                          if (_imageUrlController.text.trim().isEmpty &&
                              (widget.product?.imageUrl.isEmpty ?? true)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please provide an image URL'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isSaving = true;
                          });
                          try {
                            debugPrint('Saving product...');
                            
                            // Use URL from text field, or keep existing if empty
                            String imageUrl = _imageUrlController.text.trim();
                            if (imageUrl.isEmpty && widget.product?.imageUrl.isNotEmpty == true) {
                              imageUrl = widget.product!.imageUrl;
                            }

                            final product = Product(
                              id: widget.product?.id ??
                                  DateTime.now().millisecondsSinceEpoch.toString(),
                              name: _nameController.text,
                              description: _descriptionController.text,
                              price: double.parse(_priceController.text),
                              originalPrice: _originalPriceController.text.trim().isNotEmpty
                                  ? double.parse(_originalPriceController.text.trim())
                                  : null,
                              category: _categoryController.text,
                              imageUrl: imageUrl,
                              imageUrls: imageUrl.isNotEmpty ? [imageUrl] : [],
                              stock: int.parse(_stockController.text),
                              createdAt: widget.product?.createdAt ?? DateTime.now(),
                            );
                            
                            debugPrint('========== PRODUCT BEING SAVED ==========');
                            debugPrint('Product ID: ${product.id}');
                            debugPrint('Product Name: ${product.name}');
                            debugPrint('Product ImageURL: ${product.imageUrl}');
                            debugPrint('Product toMap: ${product.toMap()}');
                            debugPrint('========================================');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saving product...')),
                            );
                            if (widget.product == null) {
                              await context
                                  .read<ProductProvider>()
                                  .addProduct(product)
                                  .timeout(const Duration(seconds: 30));
                            } else {
                              await context
                                  .read<ProductProvider>()
                                  .updateProduct(product.id, product)
                                  .timeout(const Duration(seconds: 30));
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product saved')),
                            );

                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(widget.product == null
                                    ? 'Product added successfully'
                                    : 'Product updated successfully'),
                              ),
                            );
                          } catch (e, st) {
                            debugPrint('Save failed: $e\n$st');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Save failed: $e')),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.product == null ? 'Add Product' : 'Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

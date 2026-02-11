import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/file_picker_web_stub.dart'
  if (dart.library.html) '../../utils/file_picker_web.dart';
import '../../utils/file_reader_stub.dart'
    if (dart.library.io) '../../utils/file_reader_io.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _selectedAssetPath;
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

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final result = await pickImageWeb();
        if (result != null) {
          setState(() {
            _pickedImageBytes = result['bytes'] as Uint8List?;
            _pickedImageName = result['name'] as String?;
            _selectedAssetPath = null;
          });
        }
      } else {
        final result = await FilePicker.platform
            .pickFiles(type: FileType.image, withData: true);
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          Uint8List? bytes = file.bytes;
          if (bytes == null && file.path != null) {
            try {
              bytes = await readFileBytesIo(file.path!);
            } catch (e) {
              debugPrint('readFileBytesIo error: $e');
            }
          }

          if (bytes == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to read picked file bytes.')),
            );
          } else {
            debugPrint('Picked file: path=${file.path}, name=${file.name}, bytes=${bytes.length}');
            setState(() {
              _pickedImageBytes = bytes;
              _pickedImageName = file.name;
              _selectedAssetPath = null;
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image pick failed: $e')),
      );
    }
  }

  Future<void> _chooseFromAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final assetKeys = manifestMap.keys
          .where((k) => k.startsWith('assets/images/'))
          .toList();

      String? picked;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Choose an asset image'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: assetKeys.length,
                itemBuilder: (context, index) {
                  final path = assetKeys[index];
                  return GestureDetector(
                    onTap: () {
                      picked = path;
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(path, fit: BoxFit.cover),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              )
            ],
          );
        },
      );

      if (picked != null) {
        setState(() {
          _selectedAssetPath = picked;
          _pickedImageBytes = null;
          _pickedImageName = null;
        });
      }
    } catch (e) {
      // If AssetManifest.json couldn't be loaded (common when assets
      // aren't bundled in a debug/hot-reload session), offer the user
      // a fallback: pick a local file or show instructions to rebuild.
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Asset pick failed'),
          content: Text(
              'Could not load bundled asset list: $e\n\nIf you recently added assets, run a full rebuild (flutter clean && flutter pub get && flutter run).\n\nOr pick an image file from your device instead.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage();
              },
              child: const Text('Pick local file'),
            ),
          ],
        ),
      );
    }
  }

  String _mimeFromFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'application/octet-stream';
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
                  labelText: 'Image URL (alternative)',
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
              // Image preview + select button (selection-only)
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Select Image'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _chooseFromAssets,
                    icon: const Icon(Icons.folder),
                    label: const Text('Choose From Assets'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _pickedImageName ??
                          _selectedAssetPath ??
                          (widget.product?.imageUrl.isNotEmpty == true
                              ? 'Using existing image'
                              : 'No image selected'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: Center(
                  child: _pickedImageBytes != null
                    ? Image.memory(_pickedImageBytes!, fit: BoxFit.contain)
                    : (_selectedAssetPath != null
                      ? Image.asset(_selectedAssetPath!, fit: BoxFit.contain)
                      : (_imageUrlController.text.isNotEmpty
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
                            : (widget.product!.imageUrl.startsWith('asset:')
                              ? Image.asset(widget.product!.imageUrl.substring(6), fit: BoxFit.contain)
                              : Image.asset('assets/images/${widget.product!.id}.png', fit: BoxFit.contain)))
                          : const Icon(Icons.image, size: 64)))),
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
                          setState(() {
                            _isSaving = true;
                          });
                          try {
                            debugPrint('Saving product...');
                            // Image URL priority: 1) selected asset, 2) manual URL, 3) picked file (native only), 4) existing
                            String imageUrl = '';
                            final productId = widget.product?.id ??
                                DateTime.now().millisecondsSinceEpoch.toString();

                            // Priority 1: Selected asset path
                            if (_selectedAssetPath != null) {
                              imageUrl = 'asset:$_selectedAssetPath';
                              debugPrint('Using selected asset: $imageUrl');
                            }
                            // Priority 2: Manual URL entry
                            else if (_imageUrlController.text.trim().isNotEmpty) {
                              imageUrl = _imageUrlController.text.trim();
                              debugPrint('Using manual URL: $imageUrl');
                            }
                            // Priority 3: Picked image bytes (upload only on native, skip on web)
                            else if (_pickedImageBytes != null && !kIsWeb) {
                              try {
                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child('products/$productId/${_pickedImageName ?? 'image.png'}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Uploading image...')),
                                );
                                // Provide contentType metadata which helps web uploads
                                final metadata = SettableMetadata(
                                  contentType: _pickedImageName != null && _pickedImageName!.contains('.')
                                      ? _mimeFromFilename(_pickedImageName!)
                                      : 'image/png',
                                );
                                await ref
                                    .putData(_pickedImageBytes!, metadata)
                                    .timeout(const Duration(seconds: 120));
                                imageUrl = await ref
                                    .getDownloadURL()
                                    .timeout(const Duration(seconds: 30));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image uploaded')),
                                );
                              } on TimeoutException catch (e) {
                                debugPrint('Image upload timed out: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image upload timed out — check network/CORS/Firebase rules')),
                                );
                              } catch (e, st) {
                                debugPrint('Image upload failed: $e\n$st');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Image upload failed: $e')),
                                );
                              }
                            }
                            // Priority 4: Existing image URL (fallback)
                            else if (widget.product?.imageUrl.isNotEmpty == true) {
                              imageUrl = widget.product!.imageUrl;
                              debugPrint('Keeping existing image: $imageUrl');
                            }

                            // On web, reject picked files with helpful message
                            if (kIsWeb && _pickedImageBytes != null && imageUrl.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Web: Use "Choose From Assets" or paste an Image URL'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              setState(() {
                                _isSaving = false;
                              });
                              return;
                            }

                            // Validation: at least one image source must be selected
                            if (imageUrl.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select an image or provide an image URL'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              setState(() {
                                _isSaving = false;
                              });
                              return;
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

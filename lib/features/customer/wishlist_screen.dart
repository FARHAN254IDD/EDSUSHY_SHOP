import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive_center.dart';
import 'product_detail_screen.dart' as prod_detail;

class WishlistScreen extends StatefulWidget {
  final VoidCallback? onBrowseProducts;

  const WishlistScreen({super.key, this.onBrowseProducts});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _gridColumns(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    return 2;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        context.read<WishlistProvider>().fetchUserWishlist(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        return Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final wishlistProducts = productProvider.allProducts
                .where((p) => wishlistProvider.wishlistItems.contains(p.id))
                .toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = _gridColumns(constraints.maxWidth);
                return SingleChildScrollView(
                  child: ResponsiveCenter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Wishlist',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (wishlistProducts.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.favorite_outline,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Your wishlist is empty',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: widget.onBrowseProducts ?? () {},
                                    child: const Text('Browse Products'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  childAspectRatio: 0.74,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: wishlistProducts.length,
                            itemBuilder: (context, index) {
                              final product = wishlistProducts[index];
                              return WishlistProductCard(product: product);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class WishlistProductCard extends StatelessWidget {
  final Product product;

  const WishlistProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => prod_detail.ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[200],
                    child: productImageWidget(product, BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        final userId = context.read<AuthProvider>().user?.uid;
                        if (userId != null) {
                          context.read<WishlistProvider>().removeFromWishlist(
                            userId,
                            product.id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from wishlist'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  if (product.getDiscount() != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.getDiscount()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KSh ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (product.originalPrice != null)
                    Text(
                      'KSh ${product.originalPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

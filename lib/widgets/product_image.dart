import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

/// Convert external URL to CORS-friendly proxy URL for web
String _getCorsProxyUrl(String url) {
  if (kIsWeb && url.startsWith('http')) {
    // Use CORS proxy for external URLs
    // This allows cross-origin image loading on web
    return 'https://cors-anywhere.herokuapp.com/$url';
  }
  return url;
}

Widget productImageWidget(Product product, BoxFit fit, {bool centerFallback = false}) {
  final url = product.imageUrl;
  print('[productImageWidget] Product ${product.id}: imageUrl="$url" (length=${url.length})');
  
  Widget buildNetwork(String u) {
    final proxyUrl = _getCorsProxyUrl(u);
    if (proxyUrl != u) {
      print('[productImageWidget] Using CORS proxy: $proxyUrl');
    }
    return Image.network(
      proxyUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Failed to load network image: $u - Error: $error');
        print('[productImageWidget] Network error for: $u');
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey[600], size: 32),
                const SizedBox(height: 4),
                Text('Image not found', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget buildAsset(String p) => Image.asset(
        p,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Failed to load asset image: $p - Error: $error');
          print('[productImageWidget] Asset error for: $p');
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, color: Colors.grey[600], size: 32),
                  const SizedBox(height: 4),
                  Text('No image', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ),
            ),
          );
        },
      );

  Widget widget;
  if (url.isNotEmpty) {
    print('[productImageWidget] URL is not empty, checking format...');
    if (url.startsWith('http')) {
      print('[productImageWidget] Loading as network image: $url');
      widget = buildNetwork(url);
    } else if (url.startsWith('asset:')) {
      final assetPath = url.substring(6);
      print('[productImageWidget] Loading as asset image: $assetPath');
      widget = buildAsset(assetPath);
    } else {
      // Unknown URL format - try as network
      print('[productImageWidget] Unknown URL format, treating as network: $url');
      widget = buildNetwork(url);
    }
  } else {
    print('[productImageWidget] Empty image URL for product ${product.id}');
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, color: Colors.grey[600], size: 48),
      ),
    );
  }

  if (centerFallback && widget is Image) {
    return Center(child: widget);
  }
  return widget;
}

Widget cartItemImageWidget(CartItem item, {BoxFit fit = BoxFit.cover}) {
  final url = item.imageUrl;
  if (url.isNotEmpty) {
    if (url.startsWith('http')) {
      final proxyUrl = _getCorsProxyUrl(url);
      return Image.network(proxyUrl, fit: fit, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image));
    }
    if (url.startsWith('asset:')) {
      return Image.asset(url.substring(6), fit: fit, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image));
    }
  }
  return Image.asset('assets/images/${item.productId}.png', fit: fit, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image));
}

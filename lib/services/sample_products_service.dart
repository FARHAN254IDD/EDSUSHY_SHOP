import '../models/product_model.dart';

class SampleProductsService {
  static final List<Product> sampleProducts = [
    // Electronics - Phones
    Product(
      id: 'phone_001',
      name: 'Samsung Galaxy A53',
      description:
          'Latest Samsung Galaxy A53 with 6.4" AMOLED display, 128GB storage, excellent camera',
      price: 24999,
      originalPrice: 29999,
      category: 'Electronics',
      subcategory: 'Phones',
      imageUrl:
          'https://via.placeholder.com/400x400?text=Samsung+Galaxy+A53',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Samsung+Galaxy+A53',
        'https://via.placeholder.com/400x400?text=Galaxy+A53+Side',
        'https://via.placeholder.com/400x400?text=Galaxy+A53+Back'
      ],
      stock: 45,
      rating: 4.5,
      reviewCount: 328,
      createdAt: DateTime.now(),
      specifications: [
        'Screen: 6.4" AMOLED',
        'RAM: 8GB',
        'Storage: 128GB',
        'Camera: 64MP',
        'Battery: 5000mAh',
        'Processor: MediaTek Dimensity 1080'
      ],
      seller: 'Samsung Kenya',
      isFeatured: true,
      brand: 'Samsung',
    ),
    Product(
      id: 'phone_002',
      name: 'iPhone 14 Pro',
      description:
          'Apple iPhone 14 Pro with Dynamic Island, ProMotion display, and advanced camera system',
      price: 119999,
      originalPrice: 129999,
      category: 'Electronics',
      subcategory: 'Phones',
      imageUrl: 'https://via.placeholder.com/400x400?text=iPhone+14+Pro',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=iPhone+14+Pro',
        'https://via.placeholder.com/400x400?text=iPhone+14+Pro+Side',
        'https://via.placeholder.com/400x400?text=iPhone+14+Pro+Back'
      ],
      stock: 20,
      rating: 4.8,
      reviewCount: 512,
      createdAt: DateTime.now(),
      specifications: [
        'Screen: 6.1" Super Retina XDR',
        'Chip: A16 Bionic',
        'Camera: Triple Camera System',
        'Battery: Up to 26 hours',
        '5G support',
        'Ceramic Shield'
      ],
      seller: 'Apple Authorized',
      isFeatured: true,
      brand: 'Apple',
    ),
    Product(
      id: 'phone_003',
      name: 'Xiaomi Redmi Note 11',
      description:
          'Affordable Xiaomi phone with 90Hz display, 50MP camera, and fast charging',
      price: 13999,
      originalPrice: 17999,
      category: 'Electronics',
      subcategory: 'Phones',
      imageUrl: 'https://via.placeholder.com/400x400?text=Redmi+Note+11',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Redmi+Note+11',
        'https://via.placeholder.com/400x400?text=Redmi+Note+11+Side',
        'https://via.placeholder.com/400x400?text=Redmi+Note+11+Back'
      ],
      stock: 78,
      rating: 4.3,
      reviewCount: 245,
      createdAt: DateTime.now(),
      specifications: [
        'Screen: 6.43" AMOLED 90Hz',
        'RAM: 4GB',
        'Storage: 64GB',
        'Camera: 50MP',
        'Battery: 5000mAh',
        '33W Fast Charging'
      ],
      seller: 'Xiaomi Store',
      isFeatured: true,
      brand: 'Xiaomi',
    ),

    // Electronics - Laptops
    Product(
      id: 'laptop_001',
      name: 'MacBook Air M2',
      description:
          'Powerful MacBook Air with M2 chip, 8-core GPU, 512GB SSD, ideal for professionals',
      price: 129999,
      originalPrice: 139999,
      category: 'Electronics',
      subcategory: 'Laptops',
      imageUrl: 'https://via.placeholder.com/400x400?text=MacBook+Air+M2',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=MacBook+Air+M2',
        'https://via.placeholder.com/400x400?text=MacBook+Air+M2+Open',
        'https://via.placeholder.com/400x400?text=MacBook+Air+M2+Side'
      ],
      stock: 15,
      rating: 4.9,
      reviewCount: 189,
      createdAt: DateTime.now(),
      specifications: [
        'Screen: 13.6" Liquid Retina',
        'Chip: M2',
        'RAM: 8GB',
        'SSD: 512GB',
        'Battery: Up to 17 hours',
        'Weight: 1.24 kg'
      ],
      seller: 'Apple Store',
      isFeatured: true,
      brand: 'Apple',
    ),
    Product(
      id: 'laptop_002',
      name: 'Dell XPS 13',
      description:
          'Ultra-thin and light Dell XPS 13 with Intel i5, ideal for business and creative work',
      price: 89999,
      originalPrice: 99999,
      category: 'Electronics',
      subcategory: 'Laptops',
      imageUrl: 'https://via.placeholder.com/400x400?text=Dell+XPS+13',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Dell+XPS+13',
        'https://via.placeholder.com/400x400?text=Dell+XPS+13+Open',
        'https://via.placeholder.com/400x400?text=Dell+XPS+13+Detail'
      ],
      stock: 25,
      rating: 4.6,
      reviewCount: 156,
      createdAt: DateTime.now(),
      specifications: [
        'Screen: 13.3" FHD InfinityEdge',
        'Processor: Intel Core i5',
        'RAM: 8GB',
        'SSD: 512GB',
        'Battery: 52WHr',
        'Weight: 1.2 kg'
      ],
      seller: 'Dell Direct',
      isFeatured: true,
      brand: 'Dell',
    ),

    // Fashion - Men
    Product(
      id: 'fashion_001',
      name: 'Premium Cotton T-Shirt',
      description: 'Comfortable premium quality cotton t-shirt, available in multiple colors',
      price: 1499,
      originalPrice: 2499,
      category: 'Fashion',
      subcategory: 'Men',
      imageUrl: 'https://via.placeholder.com/400x400?text=Cotton+T-Shirt',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Cotton+T-Shirt',
        'https://via.placeholder.com/400x400?text=T-Shirt+Back',
        'https://via.placeholder.com/400x400?text=T-Shirt+Color'
      ],
      stock: 150,
      rating: 4.4,
      reviewCount: 98,
      createdAt: DateTime.now(),
      specifications: [
        '100% Cotton',
        'Sizes: XS-XXL',
        'Available colors: Black, White, Blue, Red',
        'Machine washable',
        'Comfortable fit'
      ],
      seller: 'Fashion Hub',
      brand: 'GenericBrand',
    ),
    Product(
      id: 'fashion_002',
      name: 'Casual Jeans',
      description:
          'Stylish casual jeans with stretch, perfect for everyday wear',
      price: 3499,
      originalPrice: 4999,
      category: 'Fashion',
      subcategory: 'Men',
      imageUrl: 'https://via.placeholder.com/400x400?text=Casual+Jeans',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Casual+Jeans',
        'https://via.placeholder.com/400x400?text=Jeans+Back',
        'https://via.placeholder.com/400x400?text=Jeans+Detail'
      ],
      stock: 89,
      rating: 4.5,
      reviewCount: 167,
      createdAt: DateTime.now(),
      specifications: [
        '98% Cotton, 2% Spandex',
        'Sizes: 28-40',
        'Slim fit design',
        'Durable stitching',
        'Available: Blue, Black, Gray'
      ],
      seller: 'Denim Store',
      brand: 'DenimPro',
    ),

    // Fashion - Women
    Product(
      id: 'fashion_003',
      name: 'Summer Dress',
      description: 'Beautiful summer dress with floral prints, perfect for casual outings',
      price: 2999,
      originalPrice: 4499,
      category: 'Fashion',
      subcategory: 'Women',
      imageUrl: 'https://via.placeholder.com/400x400?text=Summer+Dress',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Summer+Dress',
        'https://via.placeholder.com/400x400?text=Dress+Back',
        'https://via.placeholder.com/400x400?text=Dress+Side'
      ],
      stock: 120,
      rating: 4.6,
      reviewCount: 234,
      createdAt: DateTime.now(),
      specifications: [
        '100% Polyester',
        'Sizes: XS-XXL',
        'Floral pattern',
        'Lightweight and breathable',
        'Hand wash recommended'
      ],
      seller: 'Womens Fashion',
      brand: 'StyleCo',
    ),

    // Home & Garden
    Product(
      id: 'home_001',
      name: 'Stainless Steel Cookware Set',
      description:
          'Complete 12-piece stainless steel cookware set with lids, safe for all stovetops',
      price: 7999,
      originalPrice: 11999,
      category: 'Home & Garden',
      subcategory: 'Kitchen',
      imageUrl: 'https://via.placeholder.com/400x400?text=Cookware+Set',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Cookware+Set',
        'https://via.placeholder.com/400x400?text=Cookware+Details',
        'https://via.placeholder.com/400x400?text=Cookware+Complete'
      ],
      stock: 34,
      rating: 4.7,
      reviewCount: 289,
      createdAt: DateTime.now(),
      specifications: [
        '12-piece set',
        'Stainless steel construction',
        'Heat-resistant handles',
        'Oven-safe',
        'Induction compatible'
      ],
      seller: 'Kitchen Store',
      isFeatured: true,
      brand: 'KitchenMaster',
    ),
    Product(
      id: 'home_002',
      name: 'LED Ceiling Light',
      description: 'Modern LED ceiling light with 3-color temperature adjustable brightness',
      price: 3499,
      originalPrice: 5499,
      category: 'Home & Garden',
      subcategory: 'Lighting',
      imageUrl: 'https://via.placeholder.com/400x400?text=LED+Ceiling+Light',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=LED+Ceiling+Light',
        'https://via.placeholder.com/400x400?text=Light+Installation',
        'https://via.placeholder.com/400x400?text=Light+Close'
      ],
      stock: 56,
      rating: 4.5,
      reviewCount: 145,
      createdAt: DateTime.now(),
      specifications: [
        'Power: 36W',
        'Light color: Adjustable',
        'Brightness: Dimmable',
        'Ceiling mounted',
        'Energy efficient'
      ],
      seller: 'Lighting Pro',
      brand: 'BrightLED',
    ),
    Product(
      id: 'home_003',
      name: 'Bed Sheets Set',
      description:
          'Luxury Egyptian cotton bed sheets set, 300 thread count, soft and durable',
      price: 4999,
      originalPrice: 7999,
      category: 'Home & Garden',
      subcategory: 'Bedding',
      imageUrl: 'https://via.placeholder.com/400x400?text=Bed+Sheets',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Bed+Sheets',
        'https://via.placeholder.com/400x400?text=Sheets+Texture',
        'https://via.placeholder.com/400x400?text=Sheets+Folded'
      ],
      stock: 67,
      rating: 4.6,
      reviewCount: 212,
      createdAt: DateTime.now(),
      specifications: [
        '100% Egyptian Cotton',
        '300 Thread Count',
        'Sizes: Single, Double, Queen, King',
        'Colors: White, Blue, Gray',
        'Machine washable'
      ],
      seller: 'Bedding Store',
      brand: 'ComfortHome',
    ),

    // Sports & Outdoors
    Product(
      id: 'sports_001',
      name: 'Running Shoes',
      description: 'Professional running shoes with cushioned sole, perfect for jogging and running',
      price: 5999,
      originalPrice: 8999,
      category: 'Sports & Outdoors',
      subcategory: 'Footwear',
      imageUrl: 'https://via.placeholder.com/400x400?text=Running+Shoes',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Running+Shoes',
        'https://via.placeholder.com/400x400?text=Shoes+Side',
        'https://via.placeholder.com/400x400?text=Shoes+Bottom'
      ],
      stock: 92,
      rating: 4.5,
      reviewCount: 354,
      createdAt: DateTime.now(),
      specifications: [
        'Size: 5-13',
        'Cushioned sole',
        'Lightweight design',
        'Breathable mesh',
        'Colors: Black, White, Blue, Red'
      ],
      seller: 'Sports Store',
      isFeatured: true,
      brand: 'SportsFit',
    ),
    Product(
      id: 'sports_002',
      name: 'Yoga Mat',
      description:
          'Non-slip yoga mat with carrying strap, perfect for yoga and meditation',
      price: 1999,
      originalPrice: 3499,
      category: 'Sports & Outdoors',
      subcategory: 'Fitness',
      imageUrl: 'https://via.placeholder.com/400x400?text=Yoga+Mat',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Yoga+Mat',
        'https://via.placeholder.com/400x400?text=Yoga+Mat+Roll',
        'https://via.placeholder.com/400x400?text=Yoga+Mat+Texture'
      ],
      stock: 134,
      rating: 4.4,
      reviewCount: 189,
      createdAt: DateTime.now(),
      specifications: [
        'Material: TPE',
        'Thickness: 6mm',
        'Dimensions: 173cm x 61cm',
        'Non-slip surface',
        'Carrying strap included'
      ],
      seller: 'Fitness Hub',
      brand: 'YogaPro',
    ),
    Product(
      id: 'sports_003',
      name: 'Dumbbell Set',
      description: 'Adjustable dumbbell set, 10kg total weight, perfect for home gym',
      price: 4499,
      originalPrice: 6999,
      category: 'Sports & Outdoors',
      subcategory: 'Gym Equipment',
      imageUrl: 'https://via.placeholder.com/400x400?text=Dumbbell+Set',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Dumbbell+Set',
        'https://via.placeholder.com/400x400?text=Dumbbells+Detail',
        'https://via.placeholder.com/400x400?text=Dumbbells+Rack'
      ],
      stock: 45,
      rating: 4.6,
      reviewCount: 267,
      createdAt: DateTime.now(),
      specifications: [
        'Material: Cast Iron with rubber coating',
        'Total Weight: 10kg',
        'Adjustable weights',
        'Color: Black with red accents',
        'Includes carrying rack'
      ],
      seller: 'Gym Store',
      brand: 'FitWorks',
    ),

    // Books
    Product(
      id: 'book_001',
      name: 'Flutter for Beginners',
      description:
          'Complete guide to learning Flutter development from scratch, with practical examples',
      price: 1999,
      originalPrice: 2999,
      category: 'Books',
      subcategory: 'Technology',
      imageUrl: 'https://via.placeholder.com/400x400?text=Flutter+Book',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Flutter+Book',
        'https://via.placeholder.com/400x400?text=Flutter+Book+Back',
        'https://via.placeholder.com/400x400?text=Flutter+Book+Interior'
      ],
      stock: 78,
      rating: 4.7,
      reviewCount: 123,
      createdAt: DateTime.now(),
      specifications: [
        'Author: Tech Experts',
        'Pages: 450',
        'Language: English',
        'Published: 2023',
        'ISBN: 1234567890'
      ],
      seller: 'Book Store',
      brand: 'Tech Publishers',
    ),
    Product(
      id: 'book_002',
      name: 'The Art of Success',
      description: 'Inspirational book about achieving your goals and building success habits',
      price: 1499,
      originalPrice: 2499,
      category: 'Books',
      subcategory: 'Self-Help',
      imageUrl: 'https://via.placeholder.com/400x400?text=Art+of+Success',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Art+of+Success',
        'https://via.placeholder.com/400x400?text=Success+Back',
        'https://via.placeholder.com/400x400?text=Success+Pages'
      ],
      stock: 94,
      rating: 4.5,
      reviewCount: 287,
      createdAt: DateTime.now(),
      specifications: [
        'Author: Success Coach',
        'Pages: 320',
        'Language: English',
        'Published: 2022',
        'ISBN: 9876543210'
      ],
      seller: 'Book Store',
      brand: 'Success Press',
    ),

    // Beauty & Personal Care
    Product(
      id: 'beauty_001',
      name: 'Facial Care Kit',
      description: 'Complete facial care kit with cleanser, toner, moisturizer, and serum',
      price: 3999,
      originalPrice: 5999,
      category: 'Beauty & Personal Care',
      subcategory: 'Skincare',
      imageUrl: 'https://via.placeholder.com/400x400?text=Facial+Care+Kit',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Facial+Care+Kit',
        'https://via.placeholder.com/400x400?text=Care+Kit+Products',
        'https://via.placeholder.com/400x400?text=Care+Kit+All'
      ],
      stock: 56,
      rating: 4.6,
      reviewCount: 198,
      createdAt: DateTime.now(),
      specifications: [
        'Products: 4 pieces',
        'For: All skin types',
        'Natural ingredients',
        'Dermatologist tested',
        'Free sample sachet'
      ],
      seller: 'Beauty Store',
      isFeatured: true,
      brand: 'SkinGlow',
    ),
    Product(
      id: 'beauty_002',
      name: 'Hair Shampoo & Conditioner',
      description: 'Professional salon-quality shampoo and conditioner for healthy hair',
      price: 1999,
      originalPrice: 3499,
      category: 'Beauty & Personal Care',
      subcategory: 'Hair Care',
      imageUrl: 'https://via.placeholder.com/400x400?text=Hair+Care',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=Hair+Care',
        'https://via.placeholder.com/400x400?text=Hair+Set',
        'https://via.placeholder.com/400x400?text=Hair+Detail'
      ],
      stock: 89,
      rating: 4.4,
      reviewCount: 156,
      createdAt: DateTime.now(),
      specifications: [
        'Set: Shampoo 500ml + Conditioner 500ml',
        'Hair Type: All types',
        'Sulfate-free',
        'Moisturizing formula',
        'Fruity fragrance'
      ],
      seller: 'Hair Salon',
      brand: 'HairCare Pro',
    ),

    // Toys & Games
    Product(
      id: 'toys_001',
      name: 'LEGO Building Set',
      description: 'Creative LEGO building set with 500 pieces, recommended for ages 8+',
      price: 2999,
      originalPrice: 4499,
      category: 'Toys & Games',
      subcategory: 'Building Toys',
      imageUrl: 'https://via.placeholder.com/400x400?text=LEGO+Set',
      imageUrls: [
        'https://via.placeholder.com/400x400?text=LEGO+Set',
        'https://via.placeholder.com/400x400?text=LEGO+Build',
        'https://via.placeholder.com/400x400?text=LEGO+Pieces'
      ],
      stock: 67,
      rating: 4.7,
      reviewCount: 234,
      createdAt: DateTime.now(),
      specifications: [
        'Pieces: 500',
        'Age: 8+',
        'Materials: Plastic',
        'Assembly time: 3-4 hours',
        'Multiple building options'
      ],
      seller: 'Toy Store',
      isFeatured: true,
      brand: 'LEGO',
    ),
  ];

  /// Get all products
  static List<Product> getAllProducts() {
    return sampleProducts;
  }

  /// Get unique categories
  static List<String> getCategories() {
    final categories = <String>{};
    for (var product in sampleProducts) {
      categories.add(product.category);
    }
    return categories.toList()..sort();
  }

  /// Get products by category
  static List<Product> getProductsByCategory(String category) {
    return sampleProducts
        .where((product) => product.category == category)
        .toList();
  }

  /// Get featured products
  static List<Product> getFeaturedProducts() {
    return sampleProducts.where((product) => product.isFeatured).toList();
  }

  /// Search products
  static List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return sampleProducts
        .where((product) =>
            product.name.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery) ||
            product.brand?.toLowerCase().contains(lowerQuery) == true)
        .toList();
  }
}

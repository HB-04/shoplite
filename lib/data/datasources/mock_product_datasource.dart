import '../../domain/entities/product.dart';

class MockProductDataSource {
  static final List<Product> _products = [
    const Product(
      id: 1,
      title: 'Wireless Bluetooth Headphones',
      description: 'High-quality wireless headphones with noise cancellation and 30-hour battery life. Perfect for music lovers and professionals.',
      price: 199.99,
      category: 'Electronics',
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300',
      rating: 4.5,
      reviewCount: 324,
    ),
    const Product(
      id: 2,
      title: 'Organic Cotton T-Shirt',
      description: 'Comfortable organic cotton t-shirt in various colors. Sustainable fashion for everyday wear.',
      price: 29.99,
      category: 'Clothing',
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300',
      rating: 4.2,
      reviewCount: 156,
    ),
    const Product(
      id: 3,
      title: 'Smart Fitness Watch',
      description: 'Advanced fitness tracking with heart rate monitor, GPS, and smartphone connectivity. Track your health goals.',
      price: 299.99,
      category: 'Electronics',
      imageUrl: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=300',
      rating: 4.7,
      reviewCount: 892,
    ),
    const Product(
      id: 4,
      title: 'Premium Coffee Maker',
      description: 'Professional-grade coffee maker with programmable settings and thermal carafe. Perfect morning companion.',
      price: 149.99,
      category: 'Home',
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=300',
      rating: 4.3,
      reviewCount: 243,
    ),
    const Product(
      id: 5,
      title: 'Bestselling Mystery Novel',
      description: 'Gripping thriller that will keep you on the edge of your seat. From the acclaimed author of...',
      price: 14.99,
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=300',
      rating: 4.6,
      reviewCount: 1247,
    ),
    const Product(
      id: 6,
      title: 'Leather Crossbody Bag',
      description: 'Handcrafted genuine leather crossbody bag. Stylish and functional for daily use.',
      price: 89.99,
      category: 'Clothing',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300',
      rating: 4.4,
      reviewCount: 187,
    ),
    const Product(
      id: 7,
      title: 'Wireless Charging Pad',
      description: 'Fast wireless charging for all Qi-compatible devices. Sleek design with LED indicator.',
      price: 39.99,
      category: 'Electronics',
      imageUrl: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=300',
      rating: 4.1,
      reviewCount: 456,
    ),
    const Product(
      id: 8,
      title: 'Indoor Plant Collection',
      description: 'Set of 3 low-maintenance indoor plants perfect for home or office. Includes ceramic pots.',
      price: 49.99,
      category: 'Home',
      imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=300',
      rating: 4.8,
      reviewCount: 321,
    ),
    const Product(
      id: 9,
      title: 'Denim Jacket',
      description: 'Classic denim jacket with modern fit. Versatile piece for any wardrobe.',
      price: 79.99,
      category: 'Clothing',
      imageUrl: 'https://images.unsplash.com/photo-1544966503-7cc5ac882d5a?w=300',
      rating: 4.0,
      reviewCount: 203,
    ),
    const Product(
      id: 10,
      title: 'Cookbook: Healthy Meals',
      description: '100 quick and healthy meal recipes for busy lifestyles. Nutritionist approved.',
      price: 24.99,
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300',
      rating: 4.5,
      reviewCount: 678,
    ),
  ];

  static List<Product> getAllProducts() {
    return List.from(_products);
  }

  static List<Product> getProductsByCategory(String category) {
    if (category == 'All Categories') {
      return getAllProducts();
    }
    return _products.where((product) => product.category == category).toList();
  }

  static List<Product> searchProducts(String query) {
    if (query.isEmpty) return getAllProducts();
    
    final lowercaseQuery = query.toLowerCase();
    return _products
        .where((product) =>
            product.title.toLowerCase().contains(lowercaseQuery) ||
            product.description.toLowerCase().contains(lowercaseQuery) ||
            product.category.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  static Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getCategories() {
    final categories = _products.map((product) => product.category).toSet().toList();
    categories.sort();
    categories.insert(0, 'All Categories');
    return categories;
  }

  static List<Product> getProductsPaginated(int page, int limit) {
    final startIndex = page * limit;
    final endIndex = (startIndex + limit).clamp(0, _products.length);
    
    if (startIndex >= _products.length) {
      return [];
    }
    
    return _products.sublist(startIndex, endIndex);
  }

  static Future<List<Product>> getProductsAsync({
    String? category,
    String? searchQuery,
    int page = 0,
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    var filteredProducts = getAllProducts();
    
    // Apply category filter
    if (category != null && category != 'All Categories') {
      filteredProducts = getProductsByCategory(category);
    }
    
    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
              product.category.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    
    // Apply pagination
    final startIndex = page * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredProducts.length);
    
    if (startIndex >= filteredProducts.length) {
      return [];
    }
    
    return filteredProducts.sublist(startIndex, endIndex);
  }
}

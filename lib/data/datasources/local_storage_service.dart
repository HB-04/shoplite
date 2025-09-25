import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_product.dart';
import '../models/api_response.dart';
import '../../core/security/secure_storage.dart';

class LocalStorageService {
  static const String _cachePrefix = 'cache_';
  static const String _cacheTTLPrefix = 'cache_ttl_';
  static const String favoritesKey = 'favorites';
  static const String cartKey = 'cart';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String categoriesKey = 'categories';
  
  // Cache TTL in milliseconds (30 minutes)
  static const int cacheTTLDuration = 30 * 60 * 1000;

  static LocalStorageService? _instance;
  SharedPreferences? _prefs;
  SecureStorage? _secureStorage;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    _instance!._secureStorage ??= SecureStorageImpl();
    return _instance!;
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _prefs!;
  }

  SecureStorage get secureStorage {
    if (_secureStorage == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _secureStorage!;
  }

  // Cache Management
  Future<void> cacheProductsResponse(
    String key,
    ProductsResponse response,
  ) async {
    final cacheKey = '$_cachePrefix$key';
    final ttlKey = '$_cacheTTLPrefix$key';
    final ttl = DateTime.now().millisecondsSinceEpoch + cacheTTLDuration;

    await prefs.setString(cacheKey, jsonEncode({
      'products': response.products.map((p) => p.toJson()).toList(),
      'total': response.total,
      'skip': response.skip,
      'limit': response.limit,
    }));
    await prefs.setInt(ttlKey, ttl);
  }

  Future<ProductsResponse?> getCachedProductsResponse(String key) async {
    final cacheKey = '$_cachePrefix$key';
    final ttlKey = '$_cacheTTLPrefix$key';

    final ttl = prefs.getInt(ttlKey);
    if (ttl == null || DateTime.now().millisecondsSinceEpoch > ttl) {
      // Cache expired or doesn't exist
      await _removeCachedData(key);
      return null;
    }

    final cachedData = prefs.getString(cacheKey);
    if (cachedData == null) return null;

    try {
      final json = jsonDecode(cachedData) as Map<String, dynamic>;
      return ProductsResponse.fromJson(json);
    } catch (e) {
      // Corrupted cache data
      await _removeCachedData(key);
      return null;
    }
  }

  Future<void> cacheProduct(ApiProduct product) async {
    final cacheKey = '${_cachePrefix}product_${product.id}';
    final ttlKey = '${_cacheTTLPrefix}product_${product.id}';
    final ttl = DateTime.now().millisecondsSinceEpoch + cacheTTLDuration;

    await prefs.setString(cacheKey, jsonEncode(product.toJson()));
    await prefs.setInt(ttlKey, ttl);
  }

  Future<ApiProduct?> getCachedProduct(int id) async {
    final cacheKey = '${_cachePrefix}product_$id';
    final ttlKey = '${_cacheTTLPrefix}product_$id';

    final ttl = prefs.getInt(ttlKey);
    if (ttl == null || DateTime.now().millisecondsSinceEpoch > ttl) {
      await _removeCachedData('product_$id');
      return null;
    }

    final cachedData = prefs.getString(cacheKey);
    if (cachedData == null) return null;

    try {
      final json = jsonDecode(cachedData) as Map<String, dynamic>;
      return ApiProduct.fromJson(json);
    } catch (e) {
      await _removeCachedData('product_$id');
      return null;
    }
  }

  Future<void> cacheCategories(List<String> categories) async {
    final ttl = DateTime.now().millisecondsSinceEpoch + cacheTTLDuration;
    await prefs.setStringList(categoriesKey, categories);
    await prefs.setInt('${_cacheTTLPrefix}categories', ttl);
  }

  Future<List<String>?> getCachedCategories() async {
    final ttl = prefs.getInt('${_cacheTTLPrefix}categories');
    if (ttl == null || DateTime.now().millisecondsSinceEpoch > ttl) {
      return null;
    }
    return prefs.getStringList(categoriesKey);
  }

  Future<void> _removeCachedData(String key) async {
    await prefs.remove('$_cachePrefix$key');
    await prefs.remove('$_cacheTTLPrefix$key');
  }

  // Favorites Management
  Future<void> addToFavorites(int productId) async {
    final favorites = await getFavorites();
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await prefs.setStringList(
        favoritesKey,
        favorites.map((id) => id.toString()).toList(),
      );
    }
  }

  Future<void> removeFromFavorites(int productId) async {
    final favorites = await getFavorites();
    favorites.remove(productId);
    await prefs.setStringList(
      favoritesKey,
      favorites.map((id) => id.toString()).toList(),
    );
  }

  Future<List<int>> getFavorites() async {
    final favoritesStr = prefs.getStringList(favoritesKey) ?? [];
    return favoritesStr.map((str) => int.parse(str)).toList();
  }

  Future<bool> isFavorite(int productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }

  // Cart Management
  Future<void> addToCart(int productId, int quantity) async {
    final cart = await getCart();
    final existingIndex = cart.indexWhere((item) => item['productId'] == productId);
    
    if (existingIndex != -1) {
      cart[existingIndex]['quantity'] = cart[existingIndex]['quantity'] + quantity;
    } else {
      cart.add({
        'productId': productId,
        'quantity': quantity,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
    
    await _saveCart(cart);
  }

  Future<void> updateCartItemQuantity(int productId, int quantity) async {
    final cart = await getCart();
    final existingIndex = cart.indexWhere((item) => item['productId'] == productId);
    
    if (existingIndex != -1) {
      if (quantity <= 0) {
        cart.removeAt(existingIndex);
      } else {
        cart[existingIndex]['quantity'] = quantity;
      }
      await _saveCart(cart);
    }
  }

  Future<void> removeFromCart(int productId) async {
    final cart = await getCart();
    cart.removeWhere((item) => item['productId'] == productId);
    await _saveCart(cart);
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final cartStr = prefs.getString(cartKey);
    if (cartStr == null) return [];
    
    try {
      final List<dynamic> cartJson = jsonDecode(cartStr);
      return cartJson.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCart() async {
    await prefs.remove(cartKey);
  }

  Future<void> _saveCart(List<Map<String, dynamic>> cart) async {
    await prefs.setString(cartKey, jsonEncode(cart));
  }

  // Auth Management - Using Secure Storage
  Future<void> saveAuthToken(String token) async {
    await secureStorage.write(SecureStorageKeys.authToken, token);
  }

  Future<String?> getAuthToken() async {
    return await secureStorage.read(SecureStorageKeys.authToken);
  }

  Future<void> saveUserData(LoginResponse userData) async {
    await prefs.setString(userDataKey, jsonEncode(userData.toJson()));
  }

  Future<LoginResponse?> getUserData() async {
    final userStr = prefs.getString(userDataKey);
    if (userStr == null) return null;
    
    try {
      final json = jsonDecode(userStr) as Map<String, dynamic>;
      return LoginResponse.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    await secureStorage.delete(SecureStorageKeys.authToken);
    await prefs.remove(userDataKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Theme Management
  Future<void> saveThemeMode(String themeMode) async {
    await prefs.setString(themeKey, themeMode);
  }

  Future<String> getThemeMode() async {
    return prefs.getString(themeKey) ?? 'system';
  }

  // Clear all data
  Future<void> clearAll() async {
    await prefs.clear();
  }
}

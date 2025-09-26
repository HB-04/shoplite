import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../core/helpers/app_exceptions.dart';
import '../../core/helpers/result.dart';
import '../../core/services/connectivity_service.dart';

const Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'appName': 'ShopLite',
    'catalogTitle': 'Products',
    'searchHint': 'Search products...',
    'categoryAll': 'All Categories',
    'favoritesLabel': 'Favorites',
    'cartLabel': 'Cart',
    'addToCart': 'Add',
    'loginTitle': 'Login',
    'loginButton': 'Login',
    'loginSuccess': 'Login successful',
    'loginError': 'Invalid credentials',
    'offlineBanner': 'Offline Mode: Showing cached products',
    'emptyCart': 'Your cart is empty',
    'placeOrder': 'Place Order',
    'orderSuccess': 'Order placed successfully!',
    'retry': 'Retry',
    'loading': 'Loading...',
    'languageToggle': 'Language',
  },
  'hi': {
    'appName': 'शॉपलाइट',
    'catalogTitle': 'उत्पाद',
    'searchHint': 'उत्पाद खोजें...',
    'categoryAll': 'सभी श्रेणियाँ',
    'favoritesLabel': 'पसंदीदा',
    'cartLabel': 'कार्ट',
    'addToCart': 'जोड़ें',
    'loginTitle': 'लॉगिन',
    'loginButton': 'लॉगिन',
    'loginSuccess': 'लॉगिन सफल',
    'loginError': 'गलत प्रमाण',
    'offlineBanner': 'ऑफ़लाइन मोड: कैश्ड उत्पाद दिखा रहे हैं',
    'emptyCart': 'आपकी कार्ट खाली है',
    'placeOrder': 'ऑर्डर करें',
    'orderSuccess': 'ऑर्डर सफलतापूर्वक पूरा हुआ!',
    'retry': 'पुनः प्रयास करें',
    'loading': 'लोड हो रहा है...',
    'languageToggle': 'भाषा',
  }
};

enum AppConnectionStatus { online, offline, unknown }

class AppStateProvider extends ChangeNotifier {
  final ProductRepository _productRepository;
  final AuthRepository _authRepository;
  final CartRepository _cartRepository;
  final FavoritesRepository _favoritesRepository;
  final ConnectivityService _connectivityService;

  AppStateProvider({
    required ProductRepository productRepository,
    required AuthRepository authRepository,
    required CartRepository cartRepository,
    required FavoritesRepository favoritesRepository,
    required ConnectivityService connectivityService,
  })  : _productRepository = productRepository,
        _authRepository = authRepository,
        _cartRepository = cartRepository,
        _favoritesRepository = favoritesRepository,
        _connectivityService = connectivityService {
    _initializeApp();
  }

  // App state
  bool _isInitialized = false;
  AppConnectionStatus _connectionStatus = AppConnectionStatus.unknown;
  ThemeMode _themeMode = ThemeMode.system;
  String? _errorMessage;
  Locale _currentLocale = const Locale('en');
  String? _pendingDeepLinkProductId;

  // Auth state
  User? _currentUser;
  bool _isAuthLoading = false;
  String? _authError;

  // Products state
  List<Product> _products = [];
  List<String> _categories = ['All Categories'];
  String _selectedCategory = 'All Categories';
  String _searchQuery = '';
  bool _isProductsLoading = false;
  bool _hasMoreProducts = true;
  int _currentPage = 0;
  static const int _pageSize = 20;
  String? _productsError;

  // Cart state
  List<CartItem> _cartItems = [];
  bool _isCartLoading = false;
  double _cartTotal = 0.0;
  int _cartItemsCount = 0;
  String? _cartError;

  // Favorites state
  List<Product> _favoriteProducts = [];
  Set<int> _favoriteIds = {};
  bool _isFavoritesLoading = false;
  String? _favoritesError;

  // Product detail state
  Product? _selectedProduct;
  bool _isProductDetailLoading = false;
  String? _productDetailError;

  // Getters
  bool get isInitialized => _isInitialized;
  AppConnectionStatus get connectionStatus => _connectionStatus;
  ThemeMode get themeMode => _themeMode;
  String? get errorMessage => _errorMessage;
  Locale get currentLocale => _currentLocale;

  // Auth getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAuthLoading => _isAuthLoading;
  String? get authError => _authError;

  // Products getters
  List<Product> get products => _products;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isProductsLoading => _isProductsLoading;
  bool get hasMoreProducts => _hasMoreProducts;
  String? get productsError => _productsError;

  // Cart getters
  List<CartItem> get cartItems => _cartItems;
  bool get isCartLoading => _isCartLoading;
  double get cartTotal => _cartTotal;
  int get cartItemsCount => _cartItemsCount;
  String? get cartError => _cartError;

  // Favorites getters
  List<Product> get favoriteProducts => _favoriteProducts;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isFavoritesLoading => _isFavoritesLoading;
  String? get favoritesError => _favoritesError;

  // Product detail getters
  Product? get selectedProduct => _selectedProduct;
  bool get isProductDetailLoading => _isProductDetailLoading;
  String? get productDetailError => _productDetailError;

  static AppStateProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppStateProvider>(context, listen: listen);
  }

  String translate(String key) {
    final languageCode = _currentLocale.languageCode;
    final values = _localizedValues[languageCode] ?? _localizedValues['en']!;
    return values[key] ?? key;
  }

  void toggleLocale() {
    _currentLocale = _currentLocale.languageCode == 'en'
        ? const Locale('hi')
        : const Locale('en');
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  void setInitialRoute(String route) {
    final productId = _parseProductDeepLink(route);
    if (productId != null) {
      _pendingDeepLinkProductId = productId;
    }
  }

  String? consumeDeepLinkProductId() {
    final id = _pendingDeepLinkProductId;
    _pendingDeepLinkProductId = null;
    return id;
  }

  String? _parseProductDeepLink(String route) {
    if (route.startsWith('/product/')) {
      final id = route.replaceFirst('/product/', '');
      if (int.tryParse(id) != null) {
        return id;
      }
    }
    return null;
  }

  // App initialization
  Future<void> _initializeApp() async {
    try {
      // Check auth status (non-blocking)
      _checkAuthStatus().catchError((_) {
        // Auth failure is non-critical for initialization
      });
      
      // Check connectivity first
      final hasConnectivity = await _connectivityService.checkConnectivity();
      _connectionStatus = hasConnectivity ? AppConnectionStatus.online : AppConnectionStatus.offline;
      
      // Try to load categories and products
      if (hasConnectivity) {
        try {
          await _loadCategories();
          await _loadProducts(refresh: true);
        } catch (e) {
          // Network error during initialization - try cached data
          _connectionStatus = AppConnectionStatus.offline;
          await _loadCachedData();
        }
      } else {
        // No connectivity - load from cache
        await _loadCachedData();
      }
      
      // Load local data (these should not fail)
      try {
        await _loadCart();
        await _loadFavorites();
      } catch (e) {
        // Error loading local data - initialize empty states
        _cartItems = [];
        _favoriteProducts = [];
        _favoriteIds = {};
      }
      
      _isInitialized = true;
      notifyListeners();
      
      // Start periodic connectivity check
      _startConnectivityCheck();
      
    } catch (e) {
      // Critical initialization error
      _errorMessage = 'Failed to initialize app. Please restart.';
      _connectionStatus = AppConnectionStatus.offline;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      await _loadCategories(); // This will try cache first
      await _loadProducts(refresh: false); // This will load from cache
    } catch (cacheError) {
      // Cache error - set default categories and load fallback mock data
      _categories = ['All Categories', 'Beauty', 'Fragrances', 'Furniture', 'Laptops', 'Smartphones'];
      await _loadFallbackMockData();
      _productsError = 'Showing demo products. Please check your connection for latest data.';
    }
  }

  Timer? _connectivityTimer;
  
  void _startConnectivityCheck() {
    _connectivityTimer?.cancel();
    
    // Initial check
    _connectivityService.checkConnectivity().then((hasConnectivity) {
      _updateConnectivityStatus(hasConnectivity);
    });

    // Start listening for changes
    _connectivityService.startListening((hasConnectivity) {
      _updateConnectivityStatus(hasConnectivity);
    });
  }

  void _updateConnectivityStatus(bool hasConnectivity) {
    final newStatus = hasConnectivity ? AppConnectionStatus.online : AppConnectionStatus.offline;
    if (_connectionStatus != newStatus) {
      _connectionStatus = newStatus;
      notifyListeners();
      
      // If we're back online, refresh data
      if (hasConnectivity) {
        refreshProducts();
      }
    }
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  // Auth methods
  Future<void> _checkAuthStatus() async {
    _isAuthLoading = true;
    notifyListeners();

    try {
      final userResult = await _authRepository.getCurrentUser();
      if (userResult.isSuccess) {
        _currentUser = userResult.data;
      }
      _authError = null;
    } catch (e) {
      _authError = e.toString();
    }

    _isAuthLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(username, password);
      if (result.isSuccess && result.data != null) {
        _currentUser = result.data;
        await _loadCart(); // Reload cart after login
        _isAuthLoading = false;
        notifyListeners();
        return true;
      } else {
        _authError = result.exception?.message ?? 'Login failed';
        _isAuthLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _authError = e.toString();
      _isAuthLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      _currentUser = null;
      _cartItems.clear();
      _cartTotal = 0.0;
      _cartItemsCount = 0;
      _authError = null;
    } catch (e) {
      _authError = e.toString();
    }

    _isAuthLoading = false;
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // Products methods
  Future<void> _loadCategories() async {
    try {
      final result = await _productRepository.getCategories();
      if (result.isSuccess && result.data != null) {
        _categories = result.data!;
        } else {
          // Fallback to default categories (matching DummyJSON categories)
          _categories = ['All Categories', 'Beauty', 'Fragrances', 'Furniture', 'Laptops', 'Smartphones'];
        }
      } catch (e) {
        // Error loading categories - fallback to default categories
        _categories = ['All Categories', 'Beauty', 'Fragrances', 'Furniture', 'Laptops', 'Smartphones'];
      }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _products.clear();
      _hasMoreProducts = true;
    }

    if (!_hasMoreProducts || _isProductsLoading) return;

    _isProductsLoading = true;
    _productsError = null;
    notifyListeners();

      try {
        final skip = _currentPage * _pageSize;
        final result = await _productRepository.getProducts(
          limit: _pageSize,
          skip: skip,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          category: _selectedCategory != 'All Categories' ? _selectedCategory : null,
        );

        if (result.isSuccess && result.data != null) {
          if (refresh) {
            _products = result.data!;
          } else {
            _products.addAll(result.data!);
          }
          
          _hasMoreProducts = result.data!.length == _pageSize;
          _currentPage++;
          _connectionStatus = AppConnectionStatus.online;
          _productsError = null; // Clear any previous error
        } else {
          _productsError = result.exception?.message ?? 'Failed to load products';
          if (result.exception is NetworkException) {
            _connectionStatus = AppConnectionStatus.offline;
          }
          
          // If this is during initialization and we have no products, load fallback
          if (refresh && _products.isEmpty) {
            await _loadFallbackMockData();
            _productsError = 'Showing demo products. Please check your connection.';
          }
        }
      } catch (e) {
        // Error loading products
        _productsError = 'Network error occurred';
        _connectionStatus = AppConnectionStatus.offline;
        
        // If this is during initialization and we have no products, load fallback
        if (refresh && _products.isEmpty) {
          await _loadFallbackMockData();
          _productsError = 'Showing demo products. Please check your connection.';
        }
      }

    _isProductsLoading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    await _loadProducts(refresh: true);
  }

  Future<void> loadMoreProducts() async {
    await _loadProducts();
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _loadProducts(refresh: true);
    }
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _loadProducts(refresh: true);
    }
  }

  // Product detail methods
  Future<void> loadProductDetail(int productId) async {
    _isProductDetailLoading = true;
    _productDetailError = null;
    notifyListeners();

    try {
      final result = await _productRepository.getProduct(productId);
      if (result.isSuccess && result.data != null) {
        _selectedProduct = result.data;
      } else {
        _productDetailError = result.exception?.message ?? 'Failed to load product';
      }
    } catch (e) {
      _productDetailError = e.toString();
    }

    _isProductDetailLoading = false;
    notifyListeners();
  }

  // Cart methods
  Future<void> _loadCart() async {
    if (!isAuthenticated) return;

    _isCartLoading = true;
    notifyListeners();

    try {
      final itemsResult = await _cartRepository.getCartItems();
      final totalResult = await _cartRepository.getCartTotal();
      final countResult = await _cartRepository.getCartItemsCount();

      if (itemsResult.isSuccess && itemsResult.data != null) {
        _cartItems = itemsResult.data!;
      }

      if (totalResult.isSuccess && totalResult.data != null) {
        _cartTotal = totalResult.data!;
      }

      if (countResult.isSuccess && countResult.data != null) {
        _cartItemsCount = countResult.data!;
      }

      _cartError = null;
    } catch (e) {
      _cartError = e.toString();
    }

    _isCartLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (!isAuthenticated) return false;

    try {
      final result = await _cartRepository.addToCart(product, quantity);
      if (result.isSuccess) {
        await _loadCart();
        return true;
      } else {
        _cartError = result.exception?.message ?? 'Failed to add to cart';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromCart(int productId) async {
    if (!isAuthenticated) return false;

    try {
      final result = await _cartRepository.removeFromCart(productId);
      if (result.isSuccess) {
        await _loadCart();
        return true;
      } else {
        _cartError = result.exception?.message ?? 'Failed to remove from cart';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCartQuantity(int productId, int quantity) async {
    if (!isAuthenticated) return false;

    try {
      final result = await _cartRepository.updateQuantity(productId, quantity);
      if (result.isSuccess) {
        await _loadCart();
        return true;
      } else {
        _cartError = result.exception?.message ?? 'Failed to update quantity';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> clearCart() async {
    if (!isAuthenticated) return;

    try {
      await _cartRepository.clearCart();
      await _loadCart();
    } catch (e) {
      _cartError = e.toString();
      notifyListeners();
    }
  }

  // Favorites methods
  Future<void> _loadFavorites() async {
    _isFavoritesLoading = true;
    notifyListeners();

    try {
      final result = await _favoritesRepository.getFavorites();
      if (result.isSuccess && result.data != null) {
        _favoriteProducts = result.data!;
        _favoriteIds = _favoriteProducts.map((p) => p.id).toSet();
      }
      _favoritesError = null;
    } catch (e) {
      _favoritesError = e.toString();
    }

    _isFavoritesLoading = false;
    notifyListeners();
  }

  Future<bool> toggleFavorite(int productId) async {
    try {
      final isFavorite = _favoriteIds.contains(productId);
      
      if (isFavorite) {
        final result = await _favoritesRepository.removeFromFavorites(productId);
        if (result.isSuccess) {
          _favoriteIds.remove(productId);
          _favoriteProducts.removeWhere((p) => p.id == productId);
          
          // Update the product in the main products list
          final productIndex = _products.indexWhere((p) => p.id == productId);
          if (productIndex != -1) {
            _products[productIndex] = _products[productIndex].copyWith(isFavorite: false);
          }
          
          // Update selected product if it matches
          if (_selectedProduct?.id == productId) {
            _selectedProduct = _selectedProduct!.copyWith(isFavorite: false);
          }
          
          notifyListeners();
          return true;
        }
      } else {
        final result = await _favoritesRepository.addToFavorites(productId);
        if (result.isSuccess) {
          _favoriteIds.add(productId);
          
          // Update the product in the main products list
          final productIndex = _products.indexWhere((p) => p.id == productId);
          if (productIndex != -1) {
            _products[productIndex] = _products[productIndex].copyWith(isFavorite: true);
            _favoriteProducts.add(_products[productIndex]);
          }
          
          // Update selected product if it matches
          if (_selectedProduct?.id == productId) {
            _selectedProduct = _selectedProduct!.copyWith(isFavorite: true);
          }
          
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      _favoritesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool isProductFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  // Theme methods
  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  // Utility methods
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearProductsError() {
    _productsError = null;
    notifyListeners();
  }

  void clearCartError() {
    _cartError = null;
    notifyListeners();
  }

  // Fallback method to load mock data when both network and cache fail
  Future<void> _loadFallbackMockData() async {
    _products = [
      const Product(
        id: 1,
        title: 'Demo Laptop',
        description: 'This is a demo product shown when offline. Please connect to internet for real products.',
        price: 999.99,
        category: 'Laptops',
        imageUrl: 'https://via.placeholder.com/300x300/4A90E2/FFFFFF?text=Demo+Laptop',
        rating: 4.0,
        reviewCount: 10,
        stock: 5,
      ),
      const Product(
        id: 2,
        title: 'Demo Smartphone',
        description: 'Another demo product for offline viewing. Connect to see real products from our catalog.',
        price: 699.99,
        category: 'Smartphones',
        imageUrl: 'https://via.placeholder.com/300x300/50E3C2/FFFFFF?text=Demo+Phone',
        rating: 4.5,
        reviewCount: 25,
        stock: 10,
      ),
    ];
    _hasMoreProducts = false;
    notifyListeners();
  }
}

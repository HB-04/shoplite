import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/helpers/result.dart';
import '../../core/helpers/app_exceptions.dart';
import '../datasources/api_service.dart';
import '../datasources/local_storage_service.dart';
import '../models/api_product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  ProductRepositoryImpl({
    required ApiService apiService,
    required LocalStorageService localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  @override
  Future<Result<List<Product>>> getProducts({
    int limit = 20,
    int skip = 0,
    String? search,
    String? category,
  }) async {
    try {
      // Generate cache key based on parameters
      final cacheKey = _generateCacheKey(limit, skip, search, category);

      // Try to get from cache first
      final cachedResponse = await _localStorage.getCachedProductsResponse(cacheKey);
      
      try {
        // Fetch from API
        final apiResponse = await _apiService.getProducts(
          limit: limit,
          skip: skip,
          search: search,
          category: category,
        );
        
        // Cache the response
        await _localStorage.cacheProductsResponse(cacheKey, apiResponse);
        
        // Convert and return
        final products = await _convertApiProductsToProducts(apiResponse.products);
        return Success(products);
        
      } catch (e) {
        // If API fails, try to return cached data
        if (cachedResponse != null) {
          final products = await _convertApiProductsToProducts(cachedResponse.products);
          return Success(products);
        }
        
        // No cache available, return error
        if (e is AppException) {
          return Failure(e);
        }
        return Failure(UnknownException(message: e.toString()));
      }
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<Product>> getProduct(int id) async {
    try {
      // Check cache first
      final cachedProduct = await _localStorage.getCachedProduct(id);
      
      try {
        // Fetch from API
        final apiProduct = await _apiService.getProduct(id);
        
        // Cache the product
        await _localStorage.cacheProduct(apiProduct);
        
        // Convert and return
        final product = await _convertApiProductToProduct(apiProduct);
        return Success(product);
        
      } catch (e) {
        // If API fails, try to return cached data
        if (cachedProduct != null) {
          final product = await _convertApiProductToProduct(cachedProduct);
          return Success(product);
        }
        
        // No cache available, return error
        if (e is AppException) {
          return Failure(e);
        }
        return Failure(UnknownException(message: e.toString()));
      }
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getCategories() async {
    try {
      // Check cache first
      final cachedCategories = await _localStorage.getCachedCategories();
      
      try {
        // Fetch from API
        final categories = await _apiService.getCategories();
        
        // Cache the categories
        await _localStorage.cacheCategories(categories);
        
        return Success(categories);
        
      } catch (e) {
        // If API fails, try to return cached data
        if (cachedCategories != null) {
          return Success(cachedCategories);
        }
        
        // No cache available, return error
        if (e is AppException) {
          return Failure(e);
        }
        return Failure(UnknownException(message: e.toString()));
      }
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getFavoriteProducts() async {
    try {
      final favoriteIds = await _localStorage.getFavorites();
      final List<Product> favoriteProducts = [];

      // Get each favorite product (from cache if available)
      for (final id in favoriteIds) {
        final result = await getProduct(id);
        if (result.isSuccess && result.data != null) {
          favoriteProducts.add(result.data!);
        }
      }

      return Success(favoriteProducts);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  // Helper methods
  String _generateCacheKey(int limit, int skip, String? search, String? category) {
    final searchPart = search?.isNotEmpty == true ? '_search_$search' : '';
    final categoryPart = category?.isNotEmpty == true && category != 'All Categories' 
        ? '_cat_$category' : '';
    return 'products_${limit}_$skip$searchPart$categoryPart';
  }

  Future<List<Product>> _convertApiProductsToProducts(List<ApiProduct> apiProducts) async {
    final products = <Product>[];
    for (final apiProduct in apiProducts) {
      final product = await _convertApiProductToProduct(apiProduct);
      products.add(product);
    }
    return products;
  }

  Future<Product> _convertApiProductToProduct(ApiProduct apiProduct) async {
    final isFavorite = await _localStorage.isFavorite(apiProduct.id);
    
    return Product(
      id: apiProduct.id,
      title: apiProduct.title,
      description: apiProduct.description,
      price: apiProduct.price,
      category: apiProduct.category,
      imageUrl: apiProduct.thumbnail,
      images: apiProduct.images,
      rating: apiProduct.rating,
      reviewCount: apiProduct.stock, // Using stock as review count for demo
      brand: apiProduct.brand,
      stock: apiProduct.stock,
      discountPercentage: apiProduct.discountPercentage,
      isFavorite: isFavorite,
    );
  }
}
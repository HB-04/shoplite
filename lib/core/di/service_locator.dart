import 'package:shoplite/core/services/connectivity_service.dart';

import '../../data/datasources/api_service.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../presentation/providers/app_state_provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  ApiService? _apiService;
  LocalStorageService? _localStorageService;
  ConnectivityService? _connectivityService;

  // Repositories
  ProductRepository? _productRepository;
  AuthRepository? _authRepository;
  CartRepository? _cartRepository;
  FavoritesRepository? _favoritesRepository;

  // Providers
  AppStateProvider? _appStateProvider;

  // Initialize all dependencies
  Future<void> init() async {
    // Initialize services
    _localStorageService = await LocalStorageService.getInstance();
    _apiService = ApiService();
    _connectivityService = ConnectivityService();

    // Initialize repositories
    _productRepository = ProductRepositoryImpl(
      apiService: _apiService!,
      localStorage: _localStorageService!,
    );

    _authRepository = AuthRepositoryImpl(
      apiService: _apiService!,
      localStorage: _localStorageService!,
    );

    _cartRepository = CartRepositoryImpl(
      localStorage: _localStorageService!,
      productRepository: _productRepository!,
    );

    _favoritesRepository = FavoritesRepositoryImpl(
      localStorage: _localStorageService!,
      productRepository: _productRepository!,
    );

    // Initialize providers
    _appStateProvider = AppStateProvider(
      productRepository: _productRepository!,
      authRepository: _authRepository!,
      cartRepository: _cartRepository!,
      favoritesRepository: _favoritesRepository!,
      connectivityService: _connectivityService!,
    );
  }

  // Getters
  ApiService get apiService {
    if (_apiService == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _apiService!;
  }

  LocalStorageService get localStorageService {
    if (_localStorageService == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _localStorageService!;
  }

  ConnectivityService get connectivityService {
    if (_connectivityService == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _connectivityService!;
  }

  ProductRepository get productRepository {
    if (_productRepository == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _productRepository!;
  }

  AuthRepository get authRepository {
    if (_authRepository == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _authRepository!;
  }

  CartRepository get cartRepository {
    if (_cartRepository == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _cartRepository!;
  }

  FavoritesRepository get favoritesRepository {
    if (_favoritesRepository == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _favoritesRepository!;
  }

  AppStateProvider get appStateProvider {
    if (_appStateProvider == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _appStateProvider!;
  }

  // Clean up resources
  void dispose() {
    _apiService?.dispose();
    _connectivityService?.dispose();
    _apiService = null;
    _localStorageService = null;
    _connectivityService = null;
    _productRepository = null;
    _authRepository = null;
    _cartRepository = null;
    _favoritesRepository = null;
    _appStateProvider = null;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoplite/presentation/providers/app_state_provider.dart';
import 'package:shoplite/domain/entities/product.dart';
import 'package:shoplite/domain/entities/cart_item.dart';
import 'package:shoplite/domain/entities/user.dart';
import 'package:shoplite/domain/repositories/product_repository.dart';
import 'package:shoplite/domain/repositories/auth_repository.dart';
import 'package:shoplite/domain/repositories/cart_repository.dart';
import 'package:shoplite/domain/repositories/favorites_repository.dart';
import 'package:shoplite/core/helpers/result.dart';
import 'package:shoplite/core/helpers/app_exceptions.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> products;
  final List<String> categories;
  FakeProductRepository({required this.products, required this.categories});

  @override
  Future<Result<List<Product>>> getProducts({
    int limit = 20,
    int skip = 0,
    String? search,
    String? category,
  }) async {
    return Success(products);
  }

  @override
  Future<Result<Product>> getProduct(int id) async {
    return Success(products.firstWhere((item) => item.id == id));
  }

  @override
  Future<Result<List<String>>> getCategories() async {
    return Success(categories);
  }

  @override
  Future<Result<List<Product>>> getFavoriteProducts() async {
    return Success(products);
  }
}

class FakeAuthRepository implements AuthRepository {
  final User? user;
  final AppException? exception;
  FakeAuthRepository({this.user, this.exception});

  @override
  Future<Result<User>> login(String username, String password) async {
    if (exception != null) return Failure(exception!);
    return Success(user!);
  }

  @override
  Future<Result<void>> logout() async {
    return const Success(null);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    if (user != null) {
      return Success(user);
    }
    return const Success(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    return user != null;
  }
}

class FakeCartRepository implements CartRepository {
  @override
  Future<Result<void>> addToCart(Product product, int quantity) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> clearCart() async {
    return const Success(null);
  }

  @override
  Future<Result<int>> getCartItemsCount() async {
    return const Success(0);
  }

  @override
  Future<Result<List<CartItem>>> getCartItems() async {
    return const Success([]);
  }

  @override
  Future<Result<double>> getCartTotal() async {
    return const Success(0);
  }

  @override
  Future<Result<void>> removeFromCart(int productId) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> updateQuantity(int productId, int quantity) async {
    return const Success(null);
  }
}

class FakeFavoritesRepository implements FavoritesRepository {
  final List<Product> favorites;
  FakeFavoritesRepository(this.favorites);

  @override
  Future<Result<void>> addToFavorites(int productId) async {
    return const Success(null);
  }

  @override
  Future<Result<List<Product>>> getFavorites() async {
    return Success(favorites);
  }

  @override
  Future<Result<void>> removeFromFavorites(int productId) async {
    return const Success(null);
  }

  @override
  Future<Result<bool>> isFavorite(int productId) async {
    final isFav = favorites.any((product) => product.id == productId);
    return Success(isFav);
  }
}

void main() {
  group('AppStateProvider', () {
    late Product sampleProduct;
    late FakeProductRepository productRepository;
    late FakeCartRepository cartRepository;
    late FakeFavoritesRepository favoritesRepository;
    late FakeAuthRepository authRepository;

    setUp(() {
      sampleProduct = Product(
        id: 1,
        title: 'Sample Product',
        description: 'Sample description',
        price: 49.99,
        category: 'Tech',
        imageUrl: 'image.png',
        images: const ['image.png'],
        rating: 4.0,
        reviewCount: 10,
        brand: 'Brand',
        stock: 5,
        discountPercentage: 0.0,
      );

      productRepository = FakeProductRepository(
        products: [sampleProduct],
        categories: ['All Categories', 'Tech'],
      );
      cartRepository = FakeCartRepository();
      favoritesRepository = FakeFavoritesRepository([sampleProduct]);
      authRepository = FakeAuthRepository(user: null);
    });

    test('initializes with products and categories', () async {
      final provider = AppStateProvider(
        productRepository: productRepository,
        authRepository: authRepository,
        cartRepository: cartRepository,
        favoritesRepository: favoritesRepository,
      );

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.products.isNotEmpty, isTrue);
      expect(provider.categories.contains('Tech'), isTrue);
      expect(provider.connectionStatus, isNot(AppConnectionStatus.unknown));
    });

    test('successful login updates authentication state', () async {
      authRepository = FakeAuthRepository(user: User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        token: 'abc',
      ));

      final provider = AppStateProvider(
        productRepository: productRepository,
        authRepository: authRepository,
        cartRepository: cartRepository,
        favoritesRepository: favoritesRepository,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final success = await provider.login('test', 'password');

      expect(success, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.email, equals('test@example.com'));
    });

    test('failed login sets auth error', () async {
      authRepository = FakeAuthRepository(
        exception: UnauthorizedException(message: 'Invalid credentials'),
      );

      final provider = AppStateProvider(
        productRepository: productRepository,
        authRepository: authRepository,
        cartRepository: cartRepository,
        favoritesRepository: favoritesRepository,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final success = await provider.login('test', 'wrong');

      expect(success, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.authError, equals('Invalid credentials'));
    });
  });
}

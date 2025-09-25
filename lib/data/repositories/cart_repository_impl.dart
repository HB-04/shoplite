import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/helpers/result.dart';
import '../../core/helpers/app_exceptions.dart';
import '../datasources/local_storage_service.dart';

class CartRepositoryImpl implements CartRepository {
  final LocalStorageService _localStorage;
  final ProductRepository _productRepository;

  CartRepositoryImpl({
    required LocalStorageService localStorage,
    required ProductRepository productRepository,
  })  : _localStorage = localStorage,
        _productRepository = productRepository;

  @override
  Future<Result<void>> addToCart(Product product, int quantity) async {
    try {
      await _localStorage.addToCart(product.id, quantity);
      return const Success(null);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFromCart(int productId) async {
    try {
      await _localStorage.removeFromCart(productId);
      return const Success(null);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateQuantity(int productId, int quantity) async {
    try {
      await _localStorage.updateCartItemQuantity(productId, quantity);
      return const Success(null);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<CartItem>>> getCartItems() async {
    try {
      final cartData = await _localStorage.getCart();
      final List<CartItem> cartItems = [];

      for (final item in cartData) {
        final productId = item['productId'] as int;
        final quantity = item['quantity'] as int;
        final addedAt = DateTime.fromMillisecondsSinceEpoch(item['addedAt'] as int);

        // Get product details
        final productResult = await _productRepository.getProduct(productId);
        if (productResult.isSuccess && productResult.data != null) {
          final cartItem = CartItem(
            product: productResult.data!,
            quantity: quantity,
            addedAt: addedAt,
          );
          cartItems.add(cartItem);
        }
      }

      return Success(cartItems);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearCart() async {
    try {
      await _localStorage.clearCart();
      return const Success(null);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<double>> getCartTotal() async {
    try {
      final cartItemsResult = await getCartItems();
      if (cartItemsResult.isFailure) {
        return Failure(cartItemsResult.exception!);
      }

      final cartItems = cartItemsResult.data!;
      double total = 0.0;
      
      for (final item in cartItems) {
        total += item.totalPrice;
      }

      return Success(total);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> getCartItemsCount() async {
    try {
      final cartData = await _localStorage.getCart();
      int totalCount = 0;
      
      for (final item in cartData) {
        totalCount += item['quantity'] as int;
      }

      return Success(totalCount);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }
}

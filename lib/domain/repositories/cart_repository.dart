import '../entities/cart_item.dart';
import '../entities/product.dart';
import '../../core/helpers/result.dart';

abstract class CartRepository {
  Future<Result<void>> addToCart(Product product, int quantity);
  Future<Result<void>> removeFromCart(int productId);
  Future<Result<void>> updateQuantity(int productId, int quantity);
  Future<Result<List<CartItem>>> getCartItems();
  Future<Result<void>> clearCart();
  Future<Result<double>> getCartTotal();
  Future<Result<int>> getCartItemsCount();
}

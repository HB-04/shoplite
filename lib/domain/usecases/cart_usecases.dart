import '../entities/cart_item.dart';
import '../entities/product.dart';
import '../repositories/cart_repository.dart';
import '../../core/helpers/result.dart';

class GetCartItemsUseCase {
  final CartRepository _cartRepository;

  GetCartItemsUseCase(this._cartRepository);

  Future<Result<List<CartItem>>> call() async {
    return await _cartRepository.getCartItems();
  }
}

class AddToCartUseCase {
  final CartRepository _cartRepository;

  AddToCartUseCase(this._cartRepository);

  Future<Result<void>> call(Product product, {int quantity = 1}) async {
    return await _cartRepository.addToCart(product, quantity);
  }
}

class RemoveFromCartUseCase {
  final CartRepository _cartRepository;

  RemoveFromCartUseCase(this._cartRepository);

  Future<Result<void>> call(int productId) async {
    return await _cartRepository.removeFromCart(productId);
  }
}

class UpdateCartQuantityUseCase {
  final CartRepository _cartRepository;

  UpdateCartQuantityUseCase(this._cartRepository);

  Future<Result<void>> call(int productId, int quantity) async {
    return await _cartRepository.updateQuantity(productId, quantity);
  }
}

class ClearCartUseCase {
  final CartRepository _cartRepository;

  ClearCartUseCase(this._cartRepository);

  Future<Result<void>> call() async {
    return await _cartRepository.clearCart();
  }
}

class GetCartTotalUseCase {
  final CartRepository _cartRepository;

  GetCartTotalUseCase(this._cartRepository);

  Future<Result<double>> call() async {
    return await _cartRepository.getCartTotal();
  }
}

class GetCartItemsCountUseCase {
  final CartRepository _cartRepository;

  GetCartItemsCountUseCase(this._cartRepository);

  Future<Result<int>> call() async {
    return await _cartRepository.getCartItemsCount();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shoplite/data/datasources/local_storage_service.dart';
import 'package:shoplite/data/datasources/mock_product_datasource.dart';
import 'package:shoplite/data/repositories/cart_repository_impl.dart';
import 'package:shoplite/data/repositories/product_repository_impl.dart';
import 'package:shoplite/domain/entities/product.dart';
import 'package:shoplite/domain/repositories/cart_repository.dart';
import 'package:shoplite/domain/repositories/product_repository.dart';
import 'package:shoplite/core/helpers/result.dart';

class FakeLocalStorageService extends LocalStorageService {
  FakeLocalStorageService._();

  static Future<FakeLocalStorageService> create() async {
    final service = FakeLocalStorageService._();
    service._prefs = await LocalStorageService.getInstance()
        .then((value) => value.prefs);
    service._secureStorage = LocalStorageService.getInstance()
        .then((value) => value.secureStorage);
    return service;
  }
}

void main() {
  late LocalStorageService localStorage;
  late ProductRepository productRepository;
  late CartRepository cartRepository;
  late Product testProduct;

  setUpAll(() async {
    localStorage = await LocalStorageService.getInstance();

    final mockProducts = MockProductDataSource.getAllProducts();

    for (final product in mockProducts) {
      await localStorage.cacheProduct(product.toApiProduct());
    }

    productRepository = ProductRepositoryImpl(
      apiService: MockApiService(),
      localStorage: localStorage,
    );

    cartRepository = CartRepositoryImpl(
      localStorage: localStorage,
      productRepository: productRepository,
    );

    final productResult = await productRepository.getProducts(limit: 1);
    testProduct = productResult.data!.first;
  });

  tearDown(() async {
    await localStorage.clearCart();
  });

  test('Add to cart returns success', () async {
    final result = await cartRepository.addToCart(testProduct, 1);
    expect(result, isA<Success<void>>());

    final itemsResult = await cartRepository.getCartItems();
    expect(itemsResult.isSuccess, true);
    expect(itemsResult.data, isNotEmpty);
    expect(itemsResult.data!.first.product.id, testProduct.id);
    expect(itemsResult.data!.first.quantity, 1);
  });

  test('Update cart quantity updates total', () async {
    await cartRepository.addToCart(testProduct, 1);
    await cartRepository.updateQuantity(testProduct.id, 3);

    final itemsResult = await cartRepository.getCartItems();
    expect(itemsResult.isSuccess, true);
    expect(itemsResult.data!.first.quantity, 3);

    final totalResult = await cartRepository.getCartTotal();
    expect(totalResult.data, testProduct.price * 3);
  });

  test('Remove from cart removes item', () async {
    await cartRepository.addToCart(testProduct, 1);
    await cartRepository.removeFromCart(testProduct.id);

    final itemsResult = await cartRepository.getCartItems();
    expect(itemsResult.data, isEmpty);
  });

  test('Clear cart empties cart', () async {
    await cartRepository.addToCart(testProduct, 1);
    await cartRepository.clearCart();

    final itemsResult = await cartRepository.getCartItems();
    final countResult = await cartRepository.getCartItemsCount();

    expect(itemsResult.data, isEmpty);
    expect(countResult.data, 0);
  });
}

extension on Product {
  ApiProduct toApiProduct() {
    return ApiProduct(
      id: id,
      title: title,
      description: description,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      brand: brand,
      category: category,
      thumbnail: imageUrl,
      images: images,
    );
  }
}



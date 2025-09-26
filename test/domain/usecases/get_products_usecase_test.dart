import 'package:flutter_test/flutter_test.dart';
import 'package:shoplite/domain/entities/product.dart';
import 'package:shoplite/domain/repositories/product_repository.dart';
import 'package:shoplite/domain/usecases/product_usecases.dart';
import 'package:shoplite/core/helpers/result.dart';
import 'package:shoplite/core/helpers/app_exceptions.dart';

class FakeProductRepositorySuccess implements ProductRepository {
  final List<Product> products;
  FakeProductRepositorySuccess(this.products);
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
  Future<Result<Product>> getProduct(int id) =>
      throw UnimplementedError();

  @override
  Future<Result<List<String>>> getCategories() =>
      throw UnimplementedError();

  @override
  Future<Result<List<Product>>> getFavoriteProducts() =>
      throw UnimplementedError();
}

class FakeProductRepositoryFailure implements ProductRepository {
  final AppException exception;
  FakeProductRepositoryFailure(this.exception);
  @override
  Future<Result<List<Product>>> getProducts({
    int limit = 20,
    int skip = 0,
    String? search,
    String? category,
  }) async {
    return Failure(exception);
  }

  @override
  Future<Result<Product>> getProduct(int id) =>
      throw UnimplementedError();

  @override
  Future<Result<List<String>>> getCategories() =>
      throw UnimplementedError();

  @override
  Future<Result<List<Product>>> getFavoriteProducts() =>
      throw UnimplementedError();
}

void main() {
  group('GetProductsUseCase', () {
    final sampleProduct = Product(
      id: 1,
      title: 'Sample Product',
      description: 'Sample description',
      price: 99.99,
      category: 'Tech',
      imageUrl: 'image.png',
      images: const ['image.png'],
      rating: 4.5,
      reviewCount: 10,
      brand: 'Brand',
      stock: 5,
      discountPercentage: 5.0,
    );

    test('returns Success when repository succeeds', () async {
      final repository = FakeProductRepositorySuccess([sampleProduct]);
      final useCase = GetProductsUseCase(repository);

      final result = await useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.title, equals('Sample Product'));
    });

    test('returns Failure when repository fails', () async {
      final repository = FakeProductRepositoryFailure(
        NetworkException(message: 'Network error'),
      );
      final useCase = GetProductsUseCase(repository);

      final result = await useCase();

      expect(result.isFailure, isTrue);
      expect(result.exception, isA<NetworkException>());
    });
  });
}

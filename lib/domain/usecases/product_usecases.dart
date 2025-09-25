import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../core/helpers/result.dart';

class GetProductsUseCase {
  final ProductRepository _productRepository;

  GetProductsUseCase(this._productRepository);

  Future<Result<List<Product>>> call({
    int limit = 20,
    int skip = 0,
    String? search,
    String? category,
  }) async {
    return await _productRepository.getProducts(
      limit: limit,
      skip: skip,
      search: search,
      category: category,
    );
  }
}

class GetProductByIdUseCase {
  final ProductRepository _productRepository;

  GetProductByIdUseCase(this._productRepository);

  Future<Result<Product>> call(int productId) async {
    return await _productRepository.getProduct(productId);
  }
}

class GetCategoriesUseCase {
  final ProductRepository _productRepository;

  GetCategoriesUseCase(this._productRepository);

  Future<Result<List<String>>> call() async {
    return await _productRepository.getCategories();
  }
}

class SearchProductsUseCase {
  final ProductRepository _productRepository;

  SearchProductsUseCase(this._productRepository);

  Future<Result<List<Product>>> call(String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    return await _productRepository.getProducts(
      search: query,
      limit: limit,
      skip: skip,
    );
  }
}

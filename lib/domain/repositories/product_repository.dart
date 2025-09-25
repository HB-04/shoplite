import '../entities/product.dart';
import '../../core/helpers/result.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts({
    int limit = 20,
    int skip = 0,
    String? search,
    String? category,
  });

  Future<Result<Product>> getProduct(int id);

  Future<Result<List<String>>> getCategories();

  Future<Result<List<Product>>> getFavoriteProducts();
}

import '../entities/product.dart';
import '../../core/helpers/result.dart';

abstract class FavoritesRepository {
  Future<Result<void>> addToFavorites(int productId);
  Future<Result<void>> removeFromFavorites(int productId);
  Future<Result<bool>> isFavorite(int productId);
  Future<Result<List<Product>>> getFavorites();
}

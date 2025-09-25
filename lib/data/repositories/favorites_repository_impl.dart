import '../../domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/helpers/result.dart';
import '../../core/helpers/app_exceptions.dart';
import '../datasources/local_storage_service.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final LocalStorageService _localStorage;
  final ProductRepository _productRepository;

  FavoritesRepositoryImpl({
    required LocalStorageService localStorage,
    required ProductRepository productRepository,
  })  : _localStorage = localStorage,
        _productRepository = productRepository;

  @override
  Future<Result<void>> addToFavorites(int productId) async {
    try {
      await _localStorage.addToFavorites(productId);
      return const Success(null);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFromFavorites(int productId) async {
    try {
      await _localStorage.removeFromFavorites(productId);
      return const Success(null);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> isFavorite(int productId) async {
    try {
      final isFavorite = await _localStorage.isFavorite(productId);
      return Success(isFavorite);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getFavorites() async {
    try {
      return await _productRepository.getFavoriteProducts();
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }
}

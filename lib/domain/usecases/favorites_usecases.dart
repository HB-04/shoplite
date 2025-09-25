import '../entities/product.dart';
import '../repositories/favorites_repository.dart';
import '../../core/helpers/result.dart';

class GetFavoritesUseCase {
  final FavoritesRepository _favoritesRepository;

  GetFavoritesUseCase(this._favoritesRepository);

  Future<Result<List<Product>>> call() async {
    return await _favoritesRepository.getFavorites();
  }
}

class AddToFavoritesUseCase {
  final FavoritesRepository _favoritesRepository;

  AddToFavoritesUseCase(this._favoritesRepository);

  Future<Result<void>> call(int productId) async {
    return await _favoritesRepository.addToFavorites(productId);
  }
}

class RemoveFromFavoritesUseCase {
  final FavoritesRepository _favoritesRepository;

  RemoveFromFavoritesUseCase(this._favoritesRepository);

  Future<Result<void>> call(int productId) async {
    return await _favoritesRepository.removeFromFavorites(productId);
  }
}

class ToggleFavoriteUseCase {
  final FavoritesRepository _favoritesRepository;

  ToggleFavoriteUseCase(this._favoritesRepository);

  Future<Result<bool>> call(int productId) async {
    // Get current favorites to check if product is already favorited
    final favoritesResult = await _favoritesRepository.getFavorites();
    
    if (favoritesResult.isSuccess && favoritesResult.data != null) {
      final favorites = favoritesResult.data!;
      final isFavorite = favorites.any((product) => product.id == productId);
      
      if (isFavorite) {
        final result = await _favoritesRepository.removeFromFavorites(productId);
        return result.isSuccess ? const Success(false) : Failure(result.exception!);
      } else {
        final result = await _favoritesRepository.addToFavorites(productId);
        return result.isSuccess ? const Success(true) : Failure(result.exception!);
      }
    }
    
    return Failure(favoritesResult.exception!);
  }
}

class IsFavoriteUseCase {
  final FavoritesRepository _favoritesRepository;

  IsFavoriteUseCase(this._favoritesRepository);

  Future<bool> call(int productId) async {
    final result = await _favoritesRepository.getFavorites();
    if (result.isSuccess && result.data != null) {
      return result.data!.any((product) => product.id == productId);
    }
    return false;
  }
}

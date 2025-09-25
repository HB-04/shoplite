import '../entities/user.dart';
import '../../core/helpers/result.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String username, String password);
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
  Future<bool> isAuthenticated();
}

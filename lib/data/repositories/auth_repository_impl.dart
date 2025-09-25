import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/helpers/result.dart';
import '../../core/helpers/app_exceptions.dart';
import '../datasources/api_service.dart';
import '../datasources/local_storage_service.dart';
import '../models/api_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  AuthRepositoryImpl({
    required ApiService apiService,
    required LocalStorageService localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  @override
  Future<Result<User>> login(String username, String password) async {
    try {
      final request = LoginRequest(
        username: username,
        password: password,
      );

      final loginResponse = await _apiService.login(request);
      
      // Save auth data
      await _localStorage.saveAuthToken(loginResponse.token);
      await _localStorage.saveUserData(loginResponse);

      // Convert to domain user
      final user = User(
        id: loginResponse.id,
        email: loginResponse.email,
        name: '${loginResponse.firstName} ${loginResponse.lastName}',
        token: loginResponse.token,
      );

      return Success(user);
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _localStorage.clearAuth();
      return const Success(null);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userData = await _localStorage.getUserData();
      if (userData == null) {
        return const Success(null);
      }

      final user = User(
        id: userData.id,
        email: userData.email,
        name: '${userData.firstName} ${userData.lastName}',
        token: userData.token,
      );

      return Success(user);
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _localStorage.isAuthenticated();
  }
}

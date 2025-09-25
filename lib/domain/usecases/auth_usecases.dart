import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/helpers/result.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<Result<User>> call(String username, String password) async {
    return await _authRepository.login(username, password);
  }
}

class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<Result<void>> call() async {
    return await _authRepository.logout();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<Result<User?>> call() async {
    return await _authRepository.getCurrentUser();
  }
}

class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);

  Future<bool> call() async {
    return await _authRepository.isAuthenticated();
  }
}

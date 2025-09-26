import 'package:flutter_test/flutter_test.dart';
import 'package:shoplite/domain/entities/user.dart';
import 'package:shoplite/domain/repositories/auth_repository.dart';
import 'package:shoplite/domain/usecases/auth_usecases.dart';
import 'package:shoplite/core/helpers/result.dart';
import 'package:shoplite/core/helpers/app_exceptions.dart';

class FakeAuthRepositorySuccess implements AuthRepository {
  final User user;
  FakeAuthRepositorySuccess(this.user);

  @override
  Future<Result<User>> login(String username, String password) async {
    return Success(user);
  }

  @override
  Future<Result<void>> logout() => throw UnimplementedError();

  @override
  Future<Result<User?>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<bool> isAuthenticated() => throw UnimplementedError();
}

class FakeAuthRepositoryFailure implements AuthRepository {
  final AppException exception;
  FakeAuthRepositoryFailure(this.exception);

  @override
  Future<Result<User>> login(String username, String password) async {
    return Failure(exception);
  }

  @override
  Future<Result<void>> logout() => throw UnimplementedError();

  @override
  Future<Result<User?>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<bool> isAuthenticated() => throw UnimplementedError();
}

void main() {
  group('LoginUseCase', () {
    test('returns Success when credentials are valid', () async {
      final user = User(id: 1, email: 'test@example.com', name: 'Test User', token: 'abc');
      final repository = FakeAuthRepositorySuccess(user);
      final useCase = LoginUseCase(repository);

      final result = await useCase('user', 'pass');

      expect(result.isSuccess, isTrue);
      expect(result.data, equals(user));
    });

    test('returns Failure when credentials are invalid', () async {
      final repository = FakeAuthRepositoryFailure(
        UnauthorizedException(message: 'Invalid credentials'),
      );
      final useCase = LoginUseCase(repository);

      final result = await useCase('user', 'wrong');

      expect(result.isFailure, isTrue);
      expect(result.exception, isA<UnauthorizedException>());
    });
  });
}

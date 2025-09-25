import 'app_exceptions.dart';

abstract class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  String toString() => 'Success(data: $data)';
}

class Failure<T> extends Result<T> {
  final AppException exception;
  
  const Failure(this.exception);
  
  @override
  String toString() => 'Failure(exception: $exception)';
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T? get data {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }
  
  AppException? get exception {
    if (this is Failure<T>) {
      return (this as Failure<T>).exception;
    }
    return null;
  }
  
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as Failure<T>).exception);
    }
  }
}

class BaseError {
  final String message;
  BaseError(this.message);
}

class ApiError extends BaseError {
  ApiError(String message) : super(message);
}

class ConnectivityError extends BaseError {
  ConnectivityError(String message) : super(message);
}

class UnexpectedError extends BaseError {
  UnexpectedError(String message) : super(message);
} 
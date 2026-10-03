abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
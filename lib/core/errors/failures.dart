abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
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

/// Cause d'un échec de localisation. Détermine le message affiché.
enum LocationProblem {
  denied,
  deniedForever,
  disabled,
  unsupported,
  timeout,
  unavailable,
}

/// Échec de localisation. Le message est destiné à l'utilisateur.
class LocationFailure extends Failure {
  LocationFailure(this.problem) : super(_messageFor(problem));

  final LocationProblem problem;

  static String _messageFor(LocationProblem problem) => switch (problem) {
    LocationProblem.denied =>
      'Localisation refusée. La carte reste accessible.',
    LocationProblem.deniedForever =>
      'Localisation bloquée. Autorisez-la dans les réglages de '
          'l’application ou du navigateur.',
    LocationProblem.disabled =>
      'Le service de localisation est désactivé. Activez-le dans les réglages.',
    LocationProblem.unsupported =>
      'La localisation n’est pas prise en charge sur cette plateforme. '
          'La carte reste accessible.',
    LocationProblem.timeout =>
      'Position introuvable dans le délai imparti. Réessayez à l’extérieur.',
    LocationProblem.unavailable =>
      'Position indisponible. Vérifiez la localisation et votre connexion.',
  };
}

/// Échec du calcul d'itinéraire. Le message est destiné à l'utilisateur.
class RoutingFailure extends Failure {
  const RoutingFailure(super.message);
}
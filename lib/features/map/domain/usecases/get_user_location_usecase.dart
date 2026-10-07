import 'package:latlong2/latlong.dart';

import '../repositories/location_repository.dart';

/// Obtient la position courante de l'utilisateur.
class GetUserLocationUseCase {
  const GetUserLocationUseCase(this._repository);

  final LocationRepository _repository;

  /// Lève une LocationFailure si la position ne peut pas être obtenue.
  Future<LatLng> call() => _repository.locate();
}
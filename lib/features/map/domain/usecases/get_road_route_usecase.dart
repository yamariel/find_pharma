import 'package:latlong2/latlong.dart';

import '../entities/road_route.dart';
import '../repositories/routing_repository.dart';
import 'get_user_location_usecase.dart';

/// Calcule l'itinéraire automobile entre l'utilisateur et une destination.
class GetRoadRouteUseCase {
  const GetRoadRouteUseCase(this._getUserLocation, this._routingRepository);

  final GetUserLocationUseCase _getUserLocation;
  final RoutingRepository _routingRepository;

  /// La position est redemandée à **chaque** appel : un itinéraire ne se
  /// calcule jamais depuis une position mise en cache.
  ///
  /// Lève une LocationFailure ou une RoutingFailure.
  Future<RoadRoute> call(LatLng destination) async {
    final LatLng origin = await _getUserLocation();
    return _routingRepository.route(origin, destination);
  }
}
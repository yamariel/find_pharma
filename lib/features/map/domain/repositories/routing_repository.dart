import 'package:latlong2/latlong.dart';

import '../entities/road_route.dart';

/// Contrat de calcul d'itinéraire routier entre deux points.
///
/// Lève une RoutingFailure quand l'itinéraire ne peut pas être calculé.
abstract interface class RoutingRepository {
  Future<RoadRoute> route(LatLng origin, LatLng destination);

  /// Libère les ressources réseau de l'implémentation.
  void dispose();
}
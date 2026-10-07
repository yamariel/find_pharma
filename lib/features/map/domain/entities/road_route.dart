import 'package:latlong2/latlong.dart';

/// Itinéraire routier entre deux points, tel que renvoyé par le service de
/// routage.
class RoadRoute {
  RoadRoute({
    required List<LatLng> points,
    required this.distanceMeters,
    required this.durationSeconds,
  }) : points = List.unmodifiable(points);

  /// Tracé complet, du départ à l'arrivée.
  final List<LatLng> points;

  final double distanceMeters;
  final double durationSeconds;
}
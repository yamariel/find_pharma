/// Valide des coordonnées géographiques WGS84.
///
/// Lève une [ArgumentError] si la latitude ou la longitude sort des bornes.
void validateCoordinates(double latitude, double longitude) {
  if (!latitude.isFinite ||
      !longitude.isFinite ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180) {
    throw ArgumentError('Coordonnées WGS84 invalides.');
  }
}
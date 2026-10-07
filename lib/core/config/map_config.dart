/// Réglages de la carte, injectables depuis l'application hôte.
///
/// Chaque valeur a un défaut utilisable. `--dart-define` permet de changer de
/// fournisseur de tuiles ou de serveur OSRM sans recompiler le module.
class MapConfig {
  const MapConfig({
    this.tileUrl = const String.fromEnvironment(
      'MAP_TILE_URL',
      defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),
    this.tileAttribution = const String.fromEnvironment(
      'MAP_TILE_ATTRIBUTION',
      defaultValue: '© OpenStreetMap contributors',
    ),
    this.tileAttributionUrl = const String.fromEnvironment(
      'MAP_TILE_ATTRIBUTION_URL',
      defaultValue: 'https://www.openstreetmap.org/copyright',
    ),
    this.routingUrl = const String.fromEnvironment(
      'MAP_ROUTING_URL',
      defaultValue: 'https://router.project-osrm.org',
    ),
    this.userAgent = 'org.findpharma.app',
    this.fallbackLatitude = _doualaLatitude,
    this.fallbackLongitude = _doualaLongitude,
    this.fallbackZoom = 12.0,
  });

  /// Douala : zone couverte par la première version.
  static const double _doualaLatitude = 4.0511;
  static const double _doualaLongitude = 9.7679;

  final String tileUrl;
  final String tileAttribution;
  final String tileAttributionUrl;

  /// Racine du serveur OSRM. Doit exposer `route/v1/driving`.
  final String routingUrl;
  final String userAgent;

  /// Centre de la caméra avant toute donnée : ni position client, ni pharmacie
  /// chargée. Ce n'est pas une position mesurée, et l'écran ne l'affiche jamais
  /// comme telle.
  final double fallbackLatitude;
  final double fallbackLongitude;

  final double fallbackZoom;
}
/// May also be supplied by the host app from its runtime configuration.
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
  });
  final String tileUrl;
  final String tileAttribution;
  final String tileAttributionUrl;

  /// OSRM server root. Must serve a car profile at route/v1/driving.
  final String routingUrl;
  final String userAgent;
}

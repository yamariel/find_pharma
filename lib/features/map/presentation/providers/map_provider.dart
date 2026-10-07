import 'package:find_pharma/features/map/domain/entities/map_pharmacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pharmacies/presentation/providers/pharmacy_provider.dart';

import '../../../../core/config/map_config.dart';
import '../../data/datasources/geolocator_location_data_source.dart';
import '../../data/datasources/osrm_routing_data_source.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/routing_repository.dart';
import '../../domain/usecases/get_road_route_usecase.dart';
import '../../domain/usecases/get_user_location_usecase.dart';

/// Configuration de la carte, fournie par --dart-define.
final Provider<MapConfig> mapConfigProvider = Provider<MapConfig>(
  (Ref ref) => const MapConfig(),
);

final Provider<LocationRepository> locationRepositoryProvider =
    Provider<LocationRepository>((Ref ref) => GeolocatorLocationDataSource());

/// Riverpod ferme le client HTTP à la destruction du provider : le widget
/// n'a plus à porter ce cycle de vie.
final Provider<RoutingRepository> routingRepositoryProvider =
    Provider<RoutingRepository>((Ref ref) {
      final MapConfig config = ref.watch(mapConfigProvider);
      final RoutingRepository repository = OsrmRoutingDataSource(
        baseUrl: config.routingUrl,
        userAgent: config.userAgent,
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

final Provider<GetUserLocationUseCase> getUserLocationUseCaseProvider =
    Provider<GetUserLocationUseCase>(
      (Ref ref) => GetUserLocationUseCase(ref.watch(locationRepositoryProvider)),
    );

final Provider<GetRoadRouteUseCase> getRoadRouteUseCaseProvider =
    Provider<GetRoadRouteUseCase>(
      (Ref ref) => GetRoadRouteUseCase(
        ref.watch(getUserLocationUseCaseProvider),
        ref.watch(routingRepositoryProvider),
      ),
    );

/// Adaptation des fiches métier au contrat public du module carte.
final mapProvider = Provider<AsyncValue<List<MapPharmacy>>>((ref) {
  return ref
      .watch(pharmaciesProvider)
      .whenData(
        (pharmacies) => pharmacies
            .map(
              (pharmacy) => MapPharmacy(
                id: pharmacy.id,
                name: pharmacy.name,
                latitude: pharmacy.latitude,
                longitude: pharmacy.longitude,
                address: pharmacy.address,
              ),
            )
            .toList(),
      );
});

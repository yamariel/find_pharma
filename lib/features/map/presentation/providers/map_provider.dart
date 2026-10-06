import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../map/models/map_pharmacy.dart';
import '../../../pharmacies/presentation/providers/pharmacy_provider.dart';

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

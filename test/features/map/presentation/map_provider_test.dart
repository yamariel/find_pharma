import 'dart:async';

import 'package:find_pharma/features/map/presentation/providers/map_provider.dart';
import 'package:find_pharma/features/pharmacies/domain/entities/pharmacy.dart';
import 'package:find_pharma/features/pharmacies/presentation/providers/pharmacy_provider.dart';
import 'package:find_pharma/map/models/map_pharmacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'le catalogue alimente la carte sans inventer ouverture ou stock',
    () async {
      final result = Completer<List<Pharmacy>>();
      final container = ProviderContainer(
        overrides: [pharmaciesProvider.overrideWith((ref) => result.future)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(mapProvider, (_, _) {});
      addTearDown(subscription.close);
      expect(container.read(mapProvider).isLoading, isTrue);

      result.complete(const [
        Pharmacy(
          id: 'officine',
          name: 'Officine',
          district: 'Centre',
          latitude: -4.3,
          longitude: 15.3,
          phone: '+243123456',
          address: 'Rue du centre',
        ),
      ]);
      await container.read(pharmaciesProvider.future);

      final pharmacy = container.read(mapProvider).requireValue.single;
      expect(pharmacy.id, 'officine');
      expect(pharmacy.latitude, -4.3);
      expect(pharmacy.longitude, 15.3);
      expect(pharmacy.address, 'Rue du centre');
      expect(pharmacy.opening, OpeningStatus.unknown);
      expect(pharmacy.availability, MedicineAvailability.unknown);
      expect(pharmacy.priceLabel, isNull);
    },
  );

  test(
    'une erreur de catalogue ne produit pas de pharmacies de démonstration',
    () async {
      final container = ProviderContainer(
        overrides: [
          pharmaciesProvider.overrideWith(
            (ref) async => throw StateError('offline'),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(mapProvider, (_, _) {});
      addTearDown(subscription.close);
      await expectLater(
        container.read(pharmaciesProvider.future),
        throwsStateError,
      );
      expect(container.read(mapProvider).hasError, isTrue);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../map/pharmacy_map_screen.dart';
import '../../../pharmacies/presentation/providers/pharmacy_provider.dart';
import '../providers/map_provider.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key, this.selectedPharmacyId});

  final String? selectedPharmacyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmacies = ref.watch(mapProvider);
    return PharmacyMapScreen(
      pharmacies: pharmacies.asData?.value ?? const [],
      selectedPharmacyId: selectedPharmacyId,
      loading: pharmacies.isLoading,
      errorMessage: pharmacies.hasError
          ? 'Impossible de charger les pharmacies. Réessayez.'
          : null,
      onRetry: () => ref.invalidate(pharmaciesProvider),
    );
  }
}

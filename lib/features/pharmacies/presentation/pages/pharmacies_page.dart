import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/geo/user_position.dart';
import '../../domain/entities/pharmacy.dart';
import '../providers/pharmacy_provider.dart';
import '../widgets/pharmacy_card.dart';

/// Liste des pharmacies, triée par distance quand la position est connue.
class PharmaciesPage extends ConsumerWidget {
  const PharmaciesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Pharmacy>> pharmacies = ref.watch(pharmaciesProvider);
    final UserPosition? position = ref.watch(userPositionProvider);

    double? distanceTo(Pharmacy pharmacy) {
      final UserPosition? from = position;
      if (from == null) {
        return null;
      }
      return pharmacy.distanceToKm(from.latitude, from.longitude);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacies')),
      body: pharmacies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => _ErrorView(
          message: error is Failure
              ? error.message
              : 'Impossible de charger les pharmacies.',
          onRetry: () => ref.invalidate(pharmaciesProvider),
        ),
        data: (List<Pharmacy> list) {
          if (list.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pharmaciesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                final Pharmacy pharmacy = list[index];
                return PharmacyCard(
                  pharmacy: pharmacy,
                  distanceKm: distanceTo(pharmacy),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.local_pharmacy_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune pharmacie enregistrée pour le moment.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
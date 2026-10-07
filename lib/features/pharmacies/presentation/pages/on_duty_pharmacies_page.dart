import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/geo/user_position.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/pharmacy.dart';
import '../providers/pharmacy_provider.dart';
import '../widgets/pharmacy_card.dart';

/// Pharmacies de garde à l'instant présent.
///
/// Sans `Scaffold` : la page vit dans l'onglet « Garde », qui a déjà le sien.
class OnDutyPharmaciesPage extends ConsumerWidget {
  const OnDutyPharmaciesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Pharmacy>> onDuty = ref.watch(
      onDutyPharmaciesProvider,
    );
    final UserPosition? position = ref.watch(userPositionProvider);

    double? distanceTo(Pharmacy pharmacy) {
      final UserPosition? from = position;
      if (from == null) {
        return null;
      }
      return pharmacy.distanceToKm(from.latitude, from.longitude);
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: onDuty.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => _Message(
              icon: Icons.cloud_off,
              text: error is Failure
                  ? error.message
                  : 'Impossible de charger les pharmacies de garde.',
              onRetry: () => ref.invalidate(onDutyPharmaciesProvider),
            ),
            data: (List<Pharmacy> list) {
              if (list.isEmpty) {
                return const _Message(
                  icon: Icons.nightlight_outlined,
                  text:
                      'Aucune pharmacie de garde déclarée en ce moment.\n'
                      'Les officines publient leur tour de garde depuis leur '
                      'espace.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(onDutyPharmaciesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Pharmacy pharmacy = list[index];
                    final DateTime? until = pharmacy.onDutyUntil;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        PharmacyCard(
                          pharmacy: pharmacy,
                          distanceKm: distanceTo(pharmacy),
                          onTap: () =>
                              context.push('/pharmacies/${pharmacy.id}'),
                        ),
                        if (until != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              'De garde jusqu\'au '
                              '${DateFormatter.formatDateTime(until)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VoidCallback? retry = onRetry;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (retry != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton(onPressed: retry, child: const Text('Réessayer')),
            ],
          ],
        ),
      ),
    );
  }
}
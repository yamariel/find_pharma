import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/pharmacy.dart';
import '../providers/pharmacy_provider.dart';

/// Fiche détaillée d'une pharmacie.
class PharmacyDetailPage extends ConsumerWidget {
  const PharmacyDetailPage({required this.pharmacyId, super.key});

  final String pharmacyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Pharmacy> pharmacy = ref.watch(
      pharmacyByIdProvider(pharmacyId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacie')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: pharmacy.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error is Failure
                      ? error.message
                      : 'Impossible de charger cette pharmacie.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (Pharmacy found) => _DetailBody(pharmacy: found),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.pharmacy});

  final Pharmacy pharmacy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? address = pharmacy.address;
    final String? secondaryPhone = pharmacy.secondaryPhone;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(pharmacy.name, style: theme.textTheme.headlineSmall),
            ),
            if (pharmacy.verifiedByPharmacy)
              Icon(Icons.verified, color: theme.colorScheme.primary),
          ],
        ),
        const SizedBox(height: 24),
        _InfoRow(
          icon: Icons.place_outlined,
          label: 'Quartier',
          value: pharmacy.district,
        ),
        if (address != null)
          _InfoRow(
            icon: Icons.map_outlined,
            label: 'Adresse',
            value: address,
          ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Téléphone',
          value: pharmacy.phone,
        ),
        if (secondaryPhone != null)
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Autre numéro',
            value: secondaryPhone,
          ),
        _InfoRow(
          icon: Icons.mail_outline,
          label: 'E-mail',
          value: pharmacy.email ?? 'Non renseigné',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../domain/entities/pharmacy.dart';

/// Carte d'une pharmacie dans la liste.
class PharmacyCard extends StatelessWidget {
  const PharmacyCard({
    required this.pharmacy,
    this.distanceKm,
    this.onTap,
    super.key,
  });

  final Pharmacy pharmacy;

  /// Distance depuis l'utilisateur, `null` si la position est inconnue.
  final double? distanceKm;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double? distance = distanceKm;
    final String? address = pharmacy.address;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            pharmacy.name,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pharmacy.verifiedByPharmacy) ...<Widget>[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address == null
                          ? pharmacy.district
                          : '${pharmacy.district} · $address',
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(pharmacy.phone, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (distance != null) ...<Widget>[
                const SizedBox(width: 12),
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
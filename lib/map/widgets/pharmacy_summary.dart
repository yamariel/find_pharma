import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_pharmacy.dart';

String openingLabel(OpeningStatus status) => switch (status) {
  OpeningStatus.open => 'Ouverte',
  OpeningStatus.closed => 'Fermée',
  OpeningStatus.unknown => 'Ouverture inconnue',
};
IconData openingIcon(OpeningStatus status) => switch (status) {
  OpeningStatus.open => Icons.local_pharmacy,
  OpeningStatus.closed => Icons.lock_outline,
  OpeningStatus.unknown => Icons.help_outline,
};
Color openingColor(OpeningStatus status) => switch (status) {
  OpeningStatus.open => Colors.teal.shade700,
  OpeningStatus.closed => Colors.red.shade800,
  OpeningStatus.unknown => Colors.blueGrey.shade700,
};

class PharmacySummary extends StatelessWidget {
  const PharmacySummary({
    super.key,
    required this.pharmacy,
    this.position,
    this.medicine,
    required this.routing,
    required this.onRoute,
    required this.onClose,
    this.onView,
  });
  final MapPharmacy pharmacy;
  final LatLng? position;
  final MedicineContext? medicine;
  final bool routing;
  final VoidCallback onRoute;
  final VoidCallback onClose;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final sellers = pharmacy.presentSellerNames;
    final distance = position == null
        ? null
        : const Distance().as(LengthUnit.Kilometer, position!, pharmacy.point);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pharmacy.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                tooltip: 'Fermer la fiche',
              ),
            ],
          ),
          if (pharmacy.address != null) Text(pharmacy.address!),
          Row(
            children: [
              Icon(
                openingIcon(pharmacy.opening),
                size: 18,
                color: openingColor(pharmacy.opening),
              ),
              const SizedBox(width: 6),
              Text(openingLabel(pharmacy.opening)),
            ],
          ),
          if (distance != null)
            Text(
              '${distance.toStringAsFixed(2)} km à vol d’oiseau depuis votre position relevée',
            ),
          Text(
            sellers == null
                ? 'Présence des vendeurs non renseignée'
                : sellers.isEmpty
                ? 'Aucun vendeur déclaré présent'
                : 'Vendeurs présents : ${sellers.join(', ')}',
          ),
          if (medicine != null) ...[
            Text(
              medicine!.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(switch (pharmacy.availability) {
              MedicineAvailability.available => 'Disponible selon la recherche',
              MedicineAvailability.unavailable =>
                'Indisponible selon la recherche',
              MedicineAvailability.unknown => 'Disponibilité non renseignée',
            }),
            Text(
              pharmacy.priceLabel == null
                  ? 'Prix non renseigné'
                  : 'Prix : ${pharmacy.priceLabel}',
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilledButton.icon(
                onPressed: routing ? null : onRoute,
                icon: const Icon(Icons.directions_car),
                label: Text(routing ? 'Calcul en cours…' : 'Itinéraire'),
              ),
              if (onView != null)
                OutlinedButton(
                  onPressed: onView,
                  child: const Text('Voir la pharmacie'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

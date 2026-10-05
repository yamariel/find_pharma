import 'package:flutter/material.dart';

import '../../domain/entities/inventory_item.dart';

import 'package:find_pharma/core/utils/medicine_ui.dart';

/// Ligne "Pharmacie X • distance • prix • statut du stock" (maquette : DISPONIBILITÉ À PROXIMITÉ).
class AvailabilityTile extends StatelessWidget {
  final InventoryItem item;
  final bool highlight; // la plus proche est mise en valeur
  final VoidCallback? onCall;
  const AvailabilityTile({
    super.key,
    required this.item,
    this.highlight = false,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final fresh = item.isFresh();
    final name = item.pharmacyName.isEmpty
        ? 'Pharmacie ${item.pharmacyId}'
        : item.pharmacyName;
    final meta = [
      if (item.distanceKm != null) formatDistance(item.distanceKm!),
      '~ ${formatCfa(item.price)}',
    ].join('  •  ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedicineColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? MedicineColors.primary : MedicineColors.tileGrey,
          width: highlight ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: const TextStyle(color: MedicineColors.textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      fresh ? Icons.check_circle : Icons.info_outline,
                      size: 15,
                      color: fresh
                          ? MedicineColors.success
                          : MedicineColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        fresh
                            ? 'En stock (Vérifié ${timeAgo(item.age)})'
                            : 'Disponibilité non confirmée',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: fresh
                              ? MedicineColors.success
                              : MedicineColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onCall != null)
            IconButton.filled(
              tooltip: 'Appeler $name',
              onPressed: onCall,
              icon: const Icon(Icons.call),
            ),
        ],
      ),
    );
  }
}

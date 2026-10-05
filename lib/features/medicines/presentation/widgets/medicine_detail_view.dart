import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:find_pharma/core/utils/medicine_ui.dart';

import '../../domain/entities/medicine.dart';
import '../providers/medicine_provider.dart';
import 'availability_tile.dart';
import 'alternative_card.dart';

/// Détail d'un médicament, disponibilités déclarées et équivalents DCI.
class MedicineDetailView extends ConsumerWidget {
  final Medicine medicine;
  final ValueChanged<Medicine>? onSelectAlternative;
  const MedicineDetailView({
    super.key,
    required this.medicine,
    this.onSelectAlternative,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(pharmaciesWithStockProvider(medicine.id));
    final alternatives = ref.watch(genericAlternativesProvider(medicine));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.medication_outlined,
              color: MedicineColors.primary,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medicine.dci} • ${medicine.dosage} • ${medicine.form}',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: MedicineColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Boîte de ${medicine.packSize} • ${medicine.lab}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Badge(medicine.isGeneric ? 'Générique' : 'Marque'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: MedicineColors.primary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Disponibilité en pharmacie',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        stock.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('$e'),
          data: (items) {
            if (items.isEmpty) {
              return const Text(
                "Aucune pharmacie n'a ce médicament en stock pour le moment.",
                style: TextStyle(color: MedicineColors.textMuted),
              );
            }
            final sorted = [...items]
              ..sort(
                (a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999),
              );
            return Column(
              children: [
                for (var i = 0; i < sorted.length; i++)
                  AvailabilityTile(item: sorted[i], highlight: i == 0),
              ],
            );
          },
        ),
        alternatives.maybeWhen(
          data: (list) => list.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.autorenew,
                          color: MedicineColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Médicaments avec la même DCI',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final alt in list)
                      AlternativeCard(
                        medicine: alt,
                        onTap: onSelectAlternative == null
                            ? null
                            : () => onSelectAlternative!(alt),
                      ),
                  ],
                ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: MedicineColors.primaryLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: MedicineColors.primary,
      ),
    ),
  );
}

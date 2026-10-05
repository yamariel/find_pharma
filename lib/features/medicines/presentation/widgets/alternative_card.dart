import 'package:flutter/material.dart';
import 'package:find_pharma/core/utils/medicine_ui.dart';

import '../../domain/entities/medicine.dart';

/// Carte d'une alternative (même DCI, dosage et forme) : section "Alternatives économiques".
class AlternativeCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;
  const AlternativeCard({super.key, required this.medicine, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: MedicineColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: MedicineColors.tileGrey),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: MedicineColors.primaryLight,
                child: Icon(
                  Icons.medication_outlined,
                  color: MedicineColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: MedicineColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Même DCI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: MedicineColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicine.dosage} • ${medicine.form} • Boîte de ${medicine.packSize}',
                      style: const TextStyle(
                        color: MedicineColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}

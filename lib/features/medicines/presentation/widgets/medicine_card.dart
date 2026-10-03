import 'package:flutter/material.dart';

import '../../domain/entities/medicine.dart';

import 'package:find_pharma/core/utils/medicine_ui.dart';

/// Carte d'un médicament dans la liste de résultats de recherche.
class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;
  const MedicineCard({super.key, required this.medicine, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: MedicineColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: MedicineColors.tileGrey),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: const Icon(
          Icons.medication_outlined,
          color: MedicineColors.primary,
          size: 26,
        ),
        title: Text(
          medicine.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${medicine.dci} • ${medicine.dosage} • ${medicine.form}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

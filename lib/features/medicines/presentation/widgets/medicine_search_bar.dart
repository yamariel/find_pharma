import 'package:flutter/material.dart';
import 'package:find_pharma/core/utils/medicine_ui.dart';

/// Barre de recherche de médicaments (le debounce est géré par la page).
class MedicineSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  const MedicineSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Rechercher un médicament…',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: MedicineColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

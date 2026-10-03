import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:find_pharma/core/utils/medicine_ui.dart';

import '../../domain/entities/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../widgets/medicine_search_bar.dart';
import '../widgets/medicine_detail_view.dart';

/// Écran : barre de recherche -> liste de résultats -> page du médicament.
class SearchMedicinesPage extends ConsumerStatefulWidget {
  /// Si renseigné, lance la recherche au démarrage et ouvre le 1er résultat.
  final String initialQuery;
  const SearchMedicinesPage({super.key, this.initialQuery = ''});

  @override
  ConsumerState<SearchMedicinesPage> createState() =>
      _SearchMedicinesPageState();
}

class _SearchMedicinesPageState extends ConsumerState<SearchMedicinesPage> {
  late final TextEditingController _controller;
  Timer? _debounce;
  Medicine? _selected;
  bool _autoSelectFirst = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _autoSelectFirst = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref
            .read(medicineSearchProvider.notifier)
            .search(widget.initialQuery),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Debounce : on attend 300 ms sans frappe avant d'interroger la base.
  void _onChanged(String text) {
    _debounce?.cancel();
    _autoSelectFirst = false;
    setState(() => _selected = null);
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(medicineSearchProvider.notifier).search(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Medicine>>>(medicineSearchProvider, (_, next) {
      if (!_autoSelectFirst) return;
      next.whenData((list) {
        if (list.isNotEmpty) {
          _autoSelectFirst = false;
          setState(() => _selected = list.first);
        }
      });
    });
    final results = ref.watch(medicineSearchProvider);

    return Scaffold(
      backgroundColor: MedicineColors.background,
      appBar: AppBar(
        backgroundColor: MedicineColors.background,
        elevation: 0,
        leading: _selected == null
            ? null
            : IconButton(
                tooltip: 'Retour aux résultats',
                onPressed: () => setState(() => _selected = null),
                icon: const Icon(Icons.arrow_back),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FINDPHARMA',
              style: TextStyle(fontSize: 11, color: MedicineColors.textMuted),
            ),
            Text(
              _selected == null ? 'Médicaments' : 'Détail du médicament',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: MedicineSearchBar(
              controller: _controller,
              onChanged: _onChanged,
            ),
          ),
          Expanded(child: _body(results)),
        ],
      ),
    );
  }

  Widget _body(AsyncValue<List<Medicine>> results) {
    if (_selected != null) {
      return MedicineDetailView(
        medicine: _selected!,
        onSelectAlternative: (m) => setState(() => _selected = m),
      );
    }
    return results.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Recherche en cours...'),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 32),
              const SizedBox(height: 8),
              const Text('La recherche a échoué. Vérifiez votre connexion.'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(medicineSearchProvider.notifier)
                    .search(_controller.text),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          final hasQuery = _controller.text.trim().isNotEmpty;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasQuery
                        ? Icons.search_off_outlined
                        : Icons.medication_outlined,
                    size: 38,
                    color: MedicineColors.primary,
                  ),
                  const SizedBox(height: 12),
                  if (hasQuery)
                    Text(
                      'Aucun médicament trouvé',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    'RÉSULTATS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MedicineColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${list.length} médicament${list.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final medicine = list[index];
                  return MedicineCard(
                    medicine: medicine,
                    onTap: () => setState(() => _selected = medicine),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

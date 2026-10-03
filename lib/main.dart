import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/medicines/data/repositories/fake_medicine_repository.dart';
import 'features/medicines/domain/entities/inventory_item.dart';
import 'features/medicines/domain/entities/medicine.dart';
import 'features/medicines/domain/usecases/add_medicine_usecase.dart';
import 'features/medicines/domain/usecases/adjust_stock_usecase.dart';
import 'features/medicines/domain/usecases/search_medicines_usecase.dart';
import 'features/medicines/presentation/pages/search_medicines_page.dart';
import 'features/medicines/presentation/providers/medicine_provider.dart';

import 'package:find_pharma/core/utils/medicine_ui.dart';

/// EXPLORATEUR DE CODE : une entrée de menu = une étape du projet,
/// avec TON vrai code qui s'exécute à droite.
///   flutter run -d chrome -t lib/main_steps.dart

final fakeRepoProvider = Provider<FakeMedicineRepository>(
  (ref) => throw UnimplementedError('override dans main()'),
);

void main() {
  final fake = FakeMedicineRepository();
  runApp(
    ProviderScope(
      overrides: [
        medicineRepositoryProvider.overrideWithValue(fake),
        fakeRepoProvider.overrideWithValue(fake),
      ],
      child: MaterialApp(
        title: 'FindPharma : explorateur du code',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: MedicineColors.primary),
          useMaterial3: true,
        ),
        home: const StepsHome(),
      ),
    ),
  );
}

class StepsHome extends StatefulWidget {
  const StepsHome({super.key});
  @override
  State<StepsHome> createState() => _StepsHomeState();
}

class _StepsHomeState extends State<StepsHome> {
  int _i = 0;

  static const _titles = [
    ('Modèles', Icons.category_outlined),
    ('Données', Icons.storage_outlined),
    ('Règles', Icons.rule_outlined),
    ('État', Icons.sync_alt),
    ('Recherche', Icons.phone_android),
    ('Stock', Icons.inventory_2_outlined),
    ('Historique', Icons.history),
  ];

  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[
      EntitiesStep(),
      RepositoryStep(),
      UsecasesStep(),
      ProvidersStep(),
      ClientPageStep(),
      StockStep(),
      HistoryStep(),
    ];
    final extended = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _i,
            onDestinationSelected: (v) => setState(() => _i = v),
            extended: extended,
            labelType: extended ? null : NavigationRailLabelType.selected,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.local_pharmacy, color: MedicineColors.primary),
            ),
            destinations: [
              for (final t in _titles)
                NavigationRailDestination(icon: Icon(t.$2), label: Text(t.$1)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages[_i]),
        ],
      ),
    );
  }
}

// ───────────────────────── Composants communs ─────────────────────────

class StepFrame extends StatelessWidget {
  final String title;
  final Widget child;
  const StepFrame({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const Divider(height: 28),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Boutons qui exécutent du vrai code et affichent le résultat.
class ActionRunner extends StatefulWidget {
  final Map<String, Future<String> Function()> actions;
  const ActionRunner({super.key, required this.actions});
  @override
  State<ActionRunner> createState() => _ActionRunnerState();
}

class _ActionRunnerState extends State<ActionRunner> {
  String _out = '';
  bool _busy = false;

  Future<void> _run(Future<String> Function() action) async {
    setState(() => _busy = true);
    String res;
    try {
      res = await action();
    } catch (e) {
      res = '❌ ${e.runtimeType} : $e';
    }
    if (!mounted) return;
    setState(() {
      _out = res;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in widget.actions.entries)
              FilledButton.tonal(
                onPressed: _busy ? null : () => _run(e.value),
                child: Text(e.key),
              ),
          ],
        ),
        if (_out.isNotEmpty || _busy) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _busy ? '⏳ exécution…' : _out,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _kv(String k, String v) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 3),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 190,
        child: Text(
          k,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: MedicineColors.textMuted,
          ),
        ),
      ),
      Expanded(child: Text(v)),
    ],
  ),
);

Widget _h(String t) => Padding(
  padding: const EdgeInsets.only(top: 16, bottom: 8),
  child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
);

// ───────────────────────── Étape 1 : Entités ─────────────────────────

class EntitiesStep extends ConsumerWidget {
  const EntitiesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fake = ref.watch(fakeRepoProvider);
    final m = fake.catalog.first;
    final fresh = fake.stockOf('ph1').first;
    final stale = fake.stockOf('ph2').first;
    return StepFrame(
      title: 'Modèles',
      child: ListView(
        children: [
          _h('Medicine'),
          _kv('id', m.id),
          _kv('name', m.name),
          _kv('dci', m.dci),
          _kv('dosage / form', '${m.dosage} / ${m.form}'),
          _kv('packSize', '${m.packSize}'),
          _kv('lab', m.lab),
          _kv('isGeneric', '${m.isGeneric}'),
          for (final it in [fresh, stale]) ...[
            _h('InventoryItem : ${it.pharmacyName}'),
            _kv('quantity', '${it.quantity}'),
            _kv('price', formatCfa(it.price)),
            _kv('inStock (getter)', '${it.inStock}'),
            _kv('age (getter)', timeAgo(it.age)),
            _kv('isFresh() (24 h)', '${it.isFresh()}'),
            _kv(
              '→ badge affiché',
              it.isFresh()
                  ? 'En stock (Vérifié ${timeAgo(it.age)})'
                  : 'Disponibilité non confirmée',
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── Étape 2 : Repository ─────────────────────────

class RepositoryStep extends ConsumerWidget {
  const RepositoryStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(medicineRepositoryProvider);
    final fake = ref.watch(fakeRepoProvider);
    String names(List<Medicine> l) => l.isEmpty
        ? '[] (aucun résultat)'
        : l.map((m) => '• ${m.name}').join('\n');
    return StepFrame(
      title: 'Données',
      child: ActionRunner(
        actions: {
          'searchMedicines("para")': () async =>
              names(await repo.searchMedicines('para')),
          'searchMedicines("zzz")': () async =>
              names(await repo.searchMedicines('zzz')),
          'getGenericAlternatives(Doliprane)': () async =>
              names(await repo.getGenericAlternatives(fake.catalog.first)),
          'watchPharmaciesWithStock(doliprane500)': () async {
            final l = await repo.watchPharmaciesWithStock('doliprane500').first;
            return l
                .map(
                  (s) =>
                      '• ${s.pharmacyName} : ${s.quantity} boîtes à ${formatCfa(s.price)}',
                )
                .join('\n');
          },
        },
      ),
    );
  }
}

// ───────────────────────── Étape 3 : Règles métier ─────────────────────────

class UsecasesStep extends ConsumerWidget {
  const UsecasesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(medicineRepositoryProvider);
    final fake = ref.watch(fakeRepoProvider);
    final doli = fake.catalog.first;
    return StepFrame(
      title: 'Règles',
      child: ActionRunner(
        actions: {
          'Rechercher "a" (1 lettre)': () async {
            final r = await SearchMedicinesUsecase(repo)('a');
            return '${r.length} résultat → règle : minimum 2 lettres, aucune requête envoyée.';
          },
          'Rechercher "doli"': () async {
            final r = await SearchMedicinesUsecase(repo)('doli');
            return r.map((m) => '• ${m.name}').join('\n');
          },
          'Ajouter un médicament sans nom': () async {
            await AddMedicineUsecase(repo)(
              const Medicine(
                id: 'x',
                name: '',
                dci: '',
                dosage: '',
                form: '',
                packSize: 0,
                lab: '',
              ),
            );
            return 'ajouté';
          },
          'Ajuster le stock de 0': () async {
            await AdjustStockUsecase(repo)(
              pharmacyId: 'ph1',
              medicine: doli,
              delta: 0,
              userId: 'demo',
              reason: 'adjustment',
            );
            return 'ok';
          },
          'Sortie de 999 boîtes': () async {
            await AdjustStockUsecase(repo)(
              pharmacyId: 'ph1',
              medicine: doli,
              delta: -999,
              userId: 'demo',
              reason: 'sale',
            );
            return 'ok';
          },
          'Vendre 1 boîte (valide)': () async {
            await AdjustStockUsecase(repo)(
              pharmacyId: 'ph1',
              medicine: doli,
              delta: -1,
              userId: 'demo',
              reason: 'sale',
            );
            final q = fake.stockOf('ph1').first.quantity;
            return '✅ vente enregistrée, nouveau stock Doliprane (ph1) : $q';
          },
        },
      ),
    );
  }
}

// ───────────────────────── Étape 4 : Providers ─────────────────────────

class ProvidersStep extends ConsumerWidget {
  const ProvidersStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(medicineSearchProvider);
    final stock = ref.watch(pharmaciesWithStockProvider('doliprane500'));
    final fake = ref.read(fakeRepoProvider);
    final notifier = ref.read(medicineSearchProvider.notifier);

    final (label, color) = search.isLoading
        ? ('AsyncLoading ⏳', Colors.orange)
        : search.hasError
        ? ('AsyncError ❌ ${search.error}', Colors.red)
        : (
            'AsyncData ✅ ${search.value?.length ?? 0} résultat(s)',
            Colors.green,
          );

    return StepFrame(
      title: 'État des données',
      child: ListView(
        children: [
          _h('1) AsyncNotifier : medicineSearchProvider'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => notifier.search('para'),
                child: const Text('search("para")'),
              ),
              FilledButton.tonal(
                onPressed: () => notifier.search('zzz'),
                child: const Text('search("zzz")'),
              ),
              FilledButton.tonal(
                onPressed: () => notifier.search('a'),
                child: const Text('search("a")'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Chip(
            label: Text(label),
            backgroundColor: color.withValues(alpha: 0.15),
            side: BorderSide(color: color),
          ),
          for (final m in search.value ?? <Medicine>[])
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text('• ${m.name}'),
            ),
          _h('2) StreamProvider : pharmaciesWithStockProvider("doliprane500")'),
          FilledButton.icon(
            icon: const Icon(Icons.sell_outlined),
            label: const Text('Vendre 1 Doliprane (ph1)'),
            onPressed: () => ref
                .read(stockActionProvider.notifier)
                .adjust(
                  pharmacyId: 'ph1',
                  medicine: fake.catalog.first,
                  delta: -1,
                  userId: 'demo',
                  reason: 'sale',
                ),
          ),
          const SizedBox(height: 8),
          stock.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in items)
                  Text('• ${s.pharmacyName} : ${s.quantity} boîtes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Étape 5 : Page client ─────────────────────────

class ClientPageStep extends StatelessWidget {
  const ClientPageStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepFrame(
      title: 'Recherche',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26, width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: const SearchMedicinesPage(initialQuery: 'Doliprane'),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Étape 6 : Stock pharmacie ─────────────────────────

class StockStep extends ConsumerWidget {
  const StockStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fake = ref.watch(fakeRepoProvider);

    ref.listen<AsyncValue<void>>(stockActionProvider, (_, s) {
      s.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('❌ $e')));
        },
      );
    });

    Future<void> adjust(Medicine m, int delta, {int? price}) => ref
        .read(stockActionProvider.notifier)
        .adjust(
          pharmacyId: 'ph1',
          medicine: m,
          delta: delta,
          userId: 'pharmacien-demo',
          reason: delta > 0 ? 'restock' : 'sale',
          newPrice: price,
        );

    return StepFrame(
      title: 'Stock de la pharmacie',
      child: StreamBuilder<List<InventoryItem>>(
        stream: fake.watchPharmacyInventory('ph1'),
        builder: (context, snap) {
          final items = snap.data ?? fake.stockOf('ph1');
          return ListView(
            children: [
              for (final it in items)
                Card(
                  child: ListTile(
                    title: Text(
                      it.medicineName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Quantité : ${it.quantity}   •   ${formatCfa(it.price)}   •   maj ${timeAgo(it.age)}',
                    ),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        OutlinedButton(
                          onPressed: () => adjust(
                            fake.catalog.firstWhere(
                              (m) => m.id == it.medicineId,
                            ),
                            -1,
                          ),
                          child: const Text('−1'),
                        ),
                        OutlinedButton(
                          onPressed: () => adjust(
                            fake.catalog.firstWhere(
                              (m) => m.id == it.medicineId,
                            ),
                            -50,
                          ),
                          child: const Text('−50'),
                        ),
                        FilledButton(
                          onPressed: () => adjust(
                            fake.catalog.firstWhere(
                              (m) => m.id == it.medicineId,
                            ),
                            10,
                          ),
                          child: const Text('+10'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Ajouter Amoxicilline à mon stock (10 à 2 200 CFA)',
                  ),
                  onPressed: () => adjust(
                    fake.catalog.firstWhere((m) => m.id == 'amoxicilline500'),
                    10,
                    price: 2200,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ───────────────────────── Étape 7 : Historique ─────────────────────────

class HistoryStep extends ConsumerWidget {
  const HistoryStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fake = ref.watch(fakeRepoProvider);
    return StepFrame(
      title: 'Historique des stocks',
      child: StreamBuilder<void>(
        stream: fake.changes,
        builder: (context, _) {
          final list = fake.movements;
          if (list.isEmpty) {
            return const Text(
              'Aucun mouvement pour l\'instant.',
              style: TextStyle(color: MedicineColors.textMuted),
            );
          }
          return ListView(
            children: [
              for (final mv in list)
                ListTile(
                  dense: true,
                  leading: Icon(
                    mv.delta > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                    color: mv.delta > 0 ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    '${mv.medicineName} : ${mv.delta > 0 ? '+' : ''}${mv.delta}',
                  ),
                  subtitle: Text(
                    '${mv.reason} • stock après : ${mv.quantityAfter} • ${mv.pharmacyId} • ${timeAgo(DateTime.now().difference(mv.at))}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:find_pharma/core/errors/medicine_exceptions.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';

/// Une ligne d'historique (version démo de la collection stockMovements).
class StockMovement {
  final DateTime at;
  final String pharmacyId;
  final String medicineName;
  final int delta;
  final int quantityAfter;
  final String reason;
  const StockMovement({
    required this.at,
    required this.pharmacyId,
    required this.medicineName,
    required this.delta,
    required this.quantityAfter,
    required this.reason,
  });
}

/// REPOSITORY DE DÉMO : données en mémoire, aucun Firebase nécessaire.
/// Il se comporte comme le vrai : le stock change, l'historique se remplit,
/// et les flux (Stream) se mettent à jour en temps réel.
class FakeMedicineRepository implements MedicineRepository {
  final List<Medicine> _medicines = [
    const Medicine(
      id: 'doliprane500', name: 'Doliprane 500mg', dci: 'Paracétamol',
      dosage: '500mg', form: 'Comprimé effervescent', packSize: 16,
      lab: 'Sanofi',
    ),
    const Medicine(
      id: 'para-generique500', name: 'Paracétamol Générique 500mg',
      dci: 'Paracétamol', dosage: '500mg', form: 'Comprimé effervescent',
      packSize: 20, lab: 'Éthique', isGeneric: true,
      referenceMedicineId: 'doliprane500',
    ),
    const Medicine(
      id: 'efferalgan500', name: 'Efferalgan 500mg', dci: 'Paracétamol',
      dosage: '500mg', form: 'Comprimé effervescent', packSize: 16,
      lab: 'UPSA',
    ),
    const Medicine(
      id: 'amoxicilline500', name: 'Amoxicilline 500mg', dci: 'Amoxicilline',
      dosage: '500mg', form: 'Gélule', packSize: 12, lab: 'Biogaran',
      isGeneric: true, requiresPrescription: true,
    ),
  ];

  InventoryItem _inv(String ph, String name, String med, int qty, int price,
      Duration ago, double km) {
    final m = _medicines.firstWhere((x) => x.id == med);
    return InventoryItem(
      pharmacyId: ph, pharmacyName: name, medicineId: med,
      medicineName: m.name, dci: m.dci, quantity: qty, price: price,
      updatedAt: DateTime.now().subtract(ago), updatedBy: 'demo',
      distanceKm: km,
    );
  }

  late final List<InventoryItem> _stock = [
    _inv('ph1', 'Pharmacie du Progrès', 'doliprane500', 12, 1250,
        const Duration(hours: 3), 0.65),
    _inv('ph2', "Grande Pharmacie de l'Avenue", 'doliprane500', 5, 1300,
        const Duration(hours: 30), 1.4),
    _inv('ph3', 'Pharmacie Centrale', 'para-generique500', 40, 650,
        const Duration(hours: 2), 1.2),
    _inv('ph1', 'Pharmacie du Progrès', 'efferalgan500', 8, 1500,
        const Duration(hours: 3), 0.65),
    _inv('ph3', 'Pharmacie Centrale', 'amoxicilline500', 20, 2200,
        const Duration(hours: 5), 1.2),
  ];

  /// Historique des mouvements (le plus récent en premier).
  final List<StockMovement> movements = [];

  final _changes = StreamController<void>.broadcast();

  /// Se déclenche à chaque modification (stock ou historique).
  Stream<void> get changes => _changes.stream;

  List<Medicine> get catalog => List.unmodifiable(_medicines);

  List<InventoryItem> stockOf(String pharmacyId) =>
      _stock.where((s) => s.pharmacyId == pharmacyId).toList();

  /// Flux de l'inventaire complet d'UNE pharmacie (écran côté pharmacie).
  Stream<List<InventoryItem>> watchPharmacyInventory(String pharmacyId) async* {
    yield stockOf(pharmacyId);
    await for (final _ in _changes.stream) {
      yield stockOf(pharmacyId);
    }
  }

  List<InventoryItem> _inStock(String medicineId) => _stock
      .where((s) => s.medicineId == medicineId && s.quantity > 0)
      .toList();

  @override
  Future<List<Medicine>> searchMedicines(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return _medicines
        .where((m) =>
            m.name.toLowerCase().contains(q) || m.dci.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<Medicine>> getGenericAlternatives(Medicine m) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _medicines
        .where((x) =>
            x.id != m.id &&
            x.dci.toLowerCase() == m.dci.toLowerCase() &&
            x.dosage == m.dosage &&
            x.form == m.form)
        .toList();
  }

  @override
  Stream<List<InventoryItem>> watchPharmaciesWithStock(String medicineId) async* {
    yield _inStock(medicineId);
    await for (final _ in _changes.stream) {
      yield _inStock(medicineId);
    }
  }

  @override
  Future<void> addMedicine(Medicine medicine) async {
    _medicines.add(medicine);
    _changes.add(null);
  }

  @override
  Future<void> adjustStock({
    required String pharmacyId,
    required Medicine medicine,
    required int delta,
    required String userId,
    required String reason,
    int? newPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final i = _stock.indexWhere(
        (s) => s.pharmacyId == pharmacyId && s.medicineId == medicine.id);
    final old = i >= 0 ? _stock[i] : null;
    final updated = (old?.quantity ?? 0) + delta;
    // Même règle que la transaction Firestore : jamais de stock négatif.
    if (updated < 0) throw const InsufficientStockException();

    final item = InventoryItem(
      pharmacyId: pharmacyId,
      pharmacyName: old?.pharmacyName ?? 'Pharmacie $pharmacyId',
      medicineId: medicine.id,
      medicineName: medicine.name,
      dci: medicine.dci,
      quantity: updated,
      price: newPrice ?? old?.price ?? 0,
      updatedAt: DateTime.now(),
      updatedBy: userId,
      distanceKm: old?.distanceKm,
    );
    if (i >= 0) {
      _stock[i] = item;
    } else {
      _stock.add(item);
    }
    movements.insert(
      0,
      StockMovement(
        at: DateTime.now(), pharmacyId: pharmacyId,
        medicineName: medicine.name, delta: delta,
        quantityAfter: updated, reason: reason,
      ),
    );
    _changes.add(null);
  }
}

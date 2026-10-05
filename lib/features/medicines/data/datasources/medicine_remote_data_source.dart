import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_pharma/core/errors/medicine_exceptions.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/medicine.dart';
import '../models/inventory_item_model.dart';
import '../models/medicine_model.dart';

/// DATASOURCE = le SEUL endroit qui parle à Firestore.
/// UTILITÉ : si une requête est lente ou fausse, tu sais où chercher.
class MedicineRemoteDataSource {
  final FirebaseFirestore _db;
  MedicineRemoteDataSource(this._db);

  CollectionReference<Map<String, dynamic>> get _medicines =>
      _db.collection('medicines');

  DocumentReference<Map<String, dynamic>> _inventoryRef(
          String pharmacyId, String medicineId) =>
      _db.collection('pharmacies').doc(pharmacyId)
          .collection('inventory').doc(medicineId);

  /// Recherche par préfixe : "para" trouve "paracétamol".
  /// Astuce : '\uf8ff' est un caractère Unicode très haut qui borne la plage.
  Future<List<Medicine>> search(String query) async {
    final q = query.toLowerCase();
    final snap = await _medicines
        .orderBy('nameLower')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .limit(20)
        .get();
    return snap.docs.map(MedicineModel.fromDoc).toList();
  }

  /// Alternatives : même molécule, même dosage, même forme.
  /// (Nécessite un index composite : dciLower + dosage + form)
  Future<List<Medicine>> genericAlternatives(Medicine m) async {
    final snap = await _medicines
        .where('dciLower', isEqualTo: m.dci.toLowerCase())
        .where('dosage', isEqualTo: m.dosage)
        .where('form', isEqualTo: m.form)
        .limit(10)
        .get();
    return snap.docs
        .map(MedicineModel.fromDoc)
        .where((x) => x.id != m.id)
        .toList();
  }

  /// collectionGroup = interroge TOUTES les sous-collections "inventory"
  /// de toutes les pharmacies d'un coup. snapshots() = temps réel.
  Stream<List<InventoryItem>> watchStock(String medicineId) {
    return _db
        .collectionGroup('inventory')
        .where('medicineId', isEqualTo: medicineId)
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((s) => s.docs.map(InventoryItemModel.fromDoc).toList());
  }

  Future<void> add(Medicine m) =>
      _medicines.doc(m.id).set(MedicineModel.toMap(m));

  /// TRANSACTION : lecture + écriture atomiques.
  /// Si deux ventes arrivent en même temps, Firestore rejoue la transaction
  /// et le stock ne devient jamais négatif ni faux.
  Future<void> adjustStock({
    required String pharmacyId,
    required Medicine medicine,
    required int delta,
    required String userId,
    required String reason,
    int? newPrice,
  }) {
    final ref = _inventoryRef(pharmacyId, medicine.id);
    final movementRef = _db
        .collection('pharmacies').doc(pharmacyId)
        .collection('stockMovements').doc();

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['quantity'] ?? 0) as int;
      final updated = current + delta;
      if (updated < 0) throw const InsufficientStockException();

      final data = <String, dynamic>{
        'pharmacyId': pharmacyId,
        'medicineId': medicine.id,
        'medicineName': medicine.name,
        'dci': medicine.dci,
        'quantity': updated,
        'updatedAt': FieldValue.serverTimestamp(), // heure du serveur, fiable
        'updatedBy': userId,
        'price': ?newPrice,
      };
      tx.set(ref, data, SetOptions(merge: true));

      // Historique : trace de chaque mouvement (audit, litiges, statistiques)
      tx.set(movementRef, {
        'medicineId': medicine.id,
        'delta': delta,
        'quantityAfter': updated,
        'reason': reason,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

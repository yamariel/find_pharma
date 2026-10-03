import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicine.dart';

/// MODÈLE = traducteur Firestore <-> Entité.
/// UTILITÉ : toute la connaissance du format Firestore est isolée ici.
class MedicineModel {
  /// Document Firestore -> Entité
  static Medicine fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Medicine(
      id: doc.id,
      name: d['name'] ?? '',
      dci: d['dci'] ?? '',
      dosage: d['dosage'] ?? '',
      form: d['form'] ?? '',
      packSize: (d['packSize'] ?? 0) as int,
      lab: d['lab'] ?? '',
      isGeneric: d['isGeneric'] ?? false,
      referenceMedicineId: d['referenceMedicineId'],
      imageUrl: d['imageUrl'],
      requiresPrescription: d['requiresPrescription'] ?? false,
    );
  }

  /// Entité -> Map à écrire dans Firestore.
  /// On ajoute ici les champs techniques de recherche (nameLower, keywords).
  static Map<String, dynamic> toMap(Medicine m) => {
        'name': m.name,
        'nameLower': m.name.toLowerCase(),
        'dci': m.dci,
        'dciLower': m.dci.toLowerCase(),
        'dosage': m.dosage,
        'form': m.form,
        'packSize': m.packSize,
        'lab': m.lab,
        'isGeneric': m.isGeneric,
        'referenceMedicineId': m.referenceMedicineId,
        'imageUrl': m.imageUrl,
        'requiresPrescription': m.requiresPrescription,
        'searchKeywords': _keywords(m),
      };

  /// Mots-clés pour la recherche : on découpe nom + DCI en mots.
  static List<String> _keywords(Medicine m) => {
        ...m.name.toLowerCase().split(RegExp(r'\s+')),
        ...m.dci.toLowerCase().split(RegExp(r'\s+')),
      }.where((w) => w.length > 1).toList();
}

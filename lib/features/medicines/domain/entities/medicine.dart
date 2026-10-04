/// ENTITÉ = objet métier pur (aucune dépendance à Firebase ou Flutter).
/// UTILITÉ : si demain tu changes de base de données, cette classe ne bouge pas.
class Medicine {
  final String id;
  final String name; // ex: "Doliprane 500mg"
  final String dci; // molécule active, ex: "Paracétamol"
  final String dosage; // ex: "500mg"
  final String form; // ex: "Comprimé effervescent"
  final int packSize; // ex: 16
  final String lab;
  final bool isGeneric;
  final String? referenceMedicineId; // null si c'est le médicament de référence
  final String? imageUrl;
  final bool requiresPrescription;

  const Medicine({
    required this.id,
    required this.name,
    required this.dci,
    required this.dosage,
    required this.form,
    required this.packSize,
    required this.lab,
    this.isGeneric = false,
    this.referenceMedicineId,
    this.imageUrl,
    this.requiresPrescription = false,
  });

  // Égalité basée sur l'id : indispensable pour utiliser Medicine
  // comme paramètre d'un provider.family (Riverpod compare les paramètres).
  @override
  bool operator ==(Object other) => other is Medicine && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

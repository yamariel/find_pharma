import '../../domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  AdminModel({
    required super.id,
    required super.nom,
    required super.email,
  });

  /// Firestore → AdminModel
  factory AdminModel.fromMap(String id, Map<String, dynamic> data) {
    return AdminModel(
      id: id,
      nom: data['nom'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  /// AdminModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
    };
  }

  /// Créer un AdminModel à partir d’un AdminEntity
  factory AdminModel.fromEntity(AdminEntity entity) {
    return AdminModel(
      id: entity.id,
      nom: entity.nom,
      email: entity.email,
    );
  }

  /// Convertir AdminModel → AdminEntity
  AdminEntity toEntity() {
    return AdminEntity(
      id: id,
      nom: nom,
      email: email,
    );
  }
}

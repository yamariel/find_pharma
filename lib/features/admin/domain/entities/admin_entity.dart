import '../../domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  const AdminModel({
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
  @override
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
    };
  }

  /// AdminEntity → AdminModel
  factory AdminModel.fromEntity(AdminEntity entity) {
    return AdminModel(
      id: entity.id,
      nom: entity.nom,
      email: entity.email,
    );
  }

  /// AdminModel → AdminEntity
  AdminEntity toEntity() {
    return AdminEntity(
      id: id,
      nom: nom,
      email: email,
    );
  }
}

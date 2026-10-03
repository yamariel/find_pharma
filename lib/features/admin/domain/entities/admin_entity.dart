class AdminEntity {
  final String id;
  final String nom;
  final String email;

  AdminEntity({
    required this.id,
    required this.nom,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
    };
  }

  factory AdminEntity.fromMap(String id, Map<String, dynamic> map) {
    return AdminEntity(
      id: id,
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

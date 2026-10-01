
class UserEntity {
  final String uid;            // id Firebase
  final String nom;
  final String prenom;
  final String email;
  final String role;           // "client", "pharmacy", "admin"
  final String? phone;         // optionnel
  final String? adresse;       // optionnel

  UserEntity({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.phone,
    this.adresse,
  });

  factory UserEntity.fromMap(Map<String, dynamic> data, String uid) {
    return UserEntity(
      uid: uid,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'client',
      phone: data['phone'],
      adresse: data['adresse'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
      'phone': phone,
      'adresse': adresse,
    };
  }
}

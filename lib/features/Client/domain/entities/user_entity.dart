class UserEntity {
  final String uid;
  final String nom;
  final String email;
  final String role;
  final String? phone;
  final String? adresse;
  final String? token;

  const UserEntity({
    required this.uid,
    required this.nom,
    required this.email,
    required this.role,
    this.phone,
    this.adresse,
    this.token,
  });
}
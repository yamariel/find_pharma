import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.nom,
    required super.email,
    required super.role,
    super.phone,
    super.adresse,
    super.token,
  });

  /// Firestore -> UserModel
  factory UserModel.fromMap(
      Map<String, dynamic> data,
      String uid, {
        String? token,
      }) {
    return UserModel(
      uid: uid,
      nom: data['nom'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'client',
      phone: data['phone'] as String?,
      adresse: data['adresse'] as String?,
      token: token,
    );
  }

  /// UserModel -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'role': role,
      'phone': phone,
      'adresse': adresse,
    };
  }

  /// Créer le modèle à partir d'un User Firebase
  factory UserModel.fromFirebaseUser(
      dynamic firebaseUser, {
        String? token,
        Map<String, dynamic>? firestoreData,
      }) {
    final data = firestoreData ?? {};

    return UserModel(
      uid: firebaseUser.uid,
      nom: data['nom'] as String? ?? '',
      email: firebaseUser.email ?? data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'client',
      phone: firebaseUser.phoneNumber ?? data['phone'] as String?,
      adresse: data['adresse'] as String?,
      token: token,
    );
  }
}
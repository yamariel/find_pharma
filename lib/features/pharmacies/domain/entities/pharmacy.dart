import 'dart:math' as math;

/// Entité métier représentant une pharmacie.
///
/// Dart pur : aucun import Flutter, aucun import Firestore.
/// Les conversions depuis et vers Firestore appartiennent à [PharmacyModel],
/// dans la couche data.
///
/// Immuable : toute modification passe par [copyWith].
class Pharmacy {
  const Pharmacy({
    required this.id,
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    this.address,
    this.secondaryPhone,
    this.verifiedByPharmacy = false,
    this.updatedAt,
  });

  /// Identifiant lisible et stable, ex. `pharmacie-akwa-centre`.
  final String id;

  final String name;
  final String district;

  /// Position réelle de l'officine. Jamais de valeur par défaut :
  final double latitude;
  final double longitude;

  /// Numéro principal, celui que compose le bouton d'appel.
  final String phone;

  final String? email;
  final String? address;
  final String? secondaryPhone;

  /// Passe à `true` quand l'officine a validé elle-même sa fiche.
  final bool verifiedByPharmacy;

  final DateTime? updatedAt;

  /// Distance à vol d'oiseau en kilomètres, depuis un point donné.
  ///
  /// Formule de Haversine. Suffisante pour trier des résultats à l'échelle
  /// d'un quartier ;
  double distanceToKm(double fromLatitude, double fromLongitude) {
    const double earthRadiusKm = 6371.0;

    final double deltaLatitude = _toRadians(latitude - fromLatitude);
    final double deltaLongitude = _toRadians(longitude - fromLongitude);

    final double a =
        math.sin(deltaLatitude / 2) * math.sin(deltaLatitude / 2) +
        math.cos(_toRadians(fromLatitude)) *
            math.cos(_toRadians(latitude)) *
            math.sin(deltaLongitude / 2) *
            math.sin(deltaLongitude / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;

  Pharmacy copyWith({
    String? id,
    String? name,
    String? district,
    double? latitude,
    double? longitude,
    String? phone,
    String? address,
    String? secondaryPhone,
    bool? verifiedByPharmacy,
    DateTime? updatedAt,
    String? email,
  }) {
    return Pharmacy(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      verifiedByPharmacy: verifiedByPharmacy ?? this.verifiedByPharmacy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pharmacy &&
        other.id == id &&
        other.name == name &&
        other.district == district &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.phone == phone &&
        other.email == email &&
        other.address == address &&
        other.secondaryPhone == secondaryPhone &&
        other.verifiedByPharmacy == verifiedByPharmacy &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    district,
    latitude,
    longitude,
    phone,
    email,
    address,
    secondaryPhone,
    verifiedByPharmacy,
    updatedAt,
  );

  @override
  String toString() => 'Pharmacy($id, $name, $district)';
}
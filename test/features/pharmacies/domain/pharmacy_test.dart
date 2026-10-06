import 'package:find_pharma/features/pharmacies/domain/entities/pharmacy.dart';
import 'package:flutter_test/flutter_test.dart';

/// Construit une pharmacie de test. Les paramètres nommés permettent de ne
/// surcharger que ce qui compte dans chaque cas, sans répéter dix champs.
Pharmacy buildPharmacy({
  String id = 'pharmacie-akwa-centre',
  String name = 'Pharmacie du Centre',
  String district = 'Akwa',
  double latitude = 4.0511,
  double longitude = 9.7085,
  String phone = '+237600000000',
  String email = 'contact@pharmacieducentre.cm',
  String? address,
  String? secondaryPhone,
  bool verifiedByPharmacy = false,
  DateTime? updatedAt,
}) {
  return Pharmacy(
    id: id,
    name: name,
    district: district,
    latitude: latitude,
    longitude: longitude,
    phone: phone,
    email: email,
    address: address,
    secondaryPhone: secondaryPhone,
    verifiedByPharmacy: verifiedByPharmacy,
    updatedAt: updatedAt,
  );
}

void main() {
  group('Pharmacy.distanceToKm', () {
    test('renvoie zéro depuis sa propre position', () {
      final Pharmacy pharmacy = buildPharmacy(latitude: 4.0511, longitude: 9.7085);

      expect(pharmacy.distanceToKm(4.0511, 9.7085), closeTo(0.0, 0.0001));
    });

    test('un degré de latitude vaut environ 111,19 km', () {
      final Pharmacy pharmacy = buildPharmacy(latitude: 1.0, longitude: 0.0);

      expect(pharmacy.distanceToKm(0.0, 0.0), closeTo(111.194927, 0.001));
    });

    test('distance réelle entre Akwa et Bonanjo à Douala', () {
      final Pharmacy akwa = buildPharmacy(latitude: 4.0511, longitude: 9.7085);

      expect(akwa.distanceToKm(4.0469, 9.6900), closeTo(2.104446, 0.001));
    });

    test('est symétrique : A vers B égale B vers A', () {
      final Pharmacy akwa = buildPharmacy(latitude: 4.0511, longitude: 9.7085);
      final Pharmacy bonanjo = buildPharmacy(latitude: 4.0469, longitude: 9.6900);

      expect(
        akwa.distanceToKm(bonanjo.latitude, bonanjo.longitude),
        closeTo(bonanjo.distanceToKm(akwa.latitude, akwa.longitude), 0.0001),
      );
    });
  });

  group('Pharmacy.copyWith', () {
    test('ne modifie que le champ fourni', () {
      final Pharmacy original = buildPharmacy(name: 'Pharmacie du Centre');

      final Pharmacy modified = original.copyWith(name: 'Pharmacie Bonanjo');

      expect(modified.name, 'Pharmacie Bonanjo');
      expect(modified.id, original.id);
      expect(modified.district, original.district);
      expect(modified.latitude, original.latitude);
      expect(modified.phone, original.phone);
    });

    test('sans argument, produit un objet égal à l\'original', () {
      final Pharmacy original = buildPharmacy();

      expect(original.copyWith(), original);
    });

    test('bascule verifiedByPharmacy', () {
      final Pharmacy original = buildPharmacy(verifiedByPharmacy: false);

      expect(original.copyWith(verifiedByPharmacy: true).verifiedByPharmacy, isTrue);
    });
  });

  group('Pharmacy, égalité', () {
    test('deux pharmacies aux mêmes champs sont égales', () {
      expect(buildPharmacy(), buildPharmacy());
    });

    test('deux pharmacies égales partagent le même hashCode', () {
      expect(buildPharmacy().hashCode, buildPharmacy().hashCode);
    });

    test('un identifiant différent casse l\'égalité', () {
      expect(buildPharmacy(id: 'a'), isNot(buildPharmacy(id: 'b')));
    });

    test('une position différente casse l\'égalité', () {
      expect(
        buildPharmacy(latitude: 4.0511),
        isNot(buildPharmacy(latitude: 4.0512)),
      );
    });
  });
}
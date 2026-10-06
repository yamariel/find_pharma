import 'package:find_pharma/core/geo/user_position.dart';
import 'package:find_pharma/features/pharmacies/domain/entities/pharmacy.dart';
import 'package:find_pharma/features/pharmacies/domain/repositories/pharmacy_repository.dart';
import 'package:find_pharma/features/pharmacies/domain/usecases/get_pharmacies_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux repository : si le contrat gagne une méthode, ce fichier ne compile
/// plus et on le sait tout de suite.
class _FakePharmacyRepository implements PharmacyRepository {
  _FakePharmacyRepository(this.pharmacies);

  final List<Pharmacy> pharmacies;

  @override
  Future<List<Pharmacy>> getPharmacies() async => pharmacies;

  @override
  Future<Pharmacy> getPharmacyById(String id) => throw UnimplementedError();

  @override
  Future<void> savePharmacy(Pharmacy pharmacy) => throw UnimplementedError();
}

const Pharmacy akwa = Pharmacy(
  id: 'akwa',
  name: 'Pharmacie Akwa',
  district: 'Akwa',
  latitude: 4.0511,
  longitude: 9.7085,
  email: 'contact@pharmacieducentre.cm',
  phone: '+237690000001',
);

const Pharmacy bonanjo = Pharmacy(
  id: 'bonanjo',
  name: 'Pharmacie Bonanjo',
  district: 'Bonanjo',
  latitude: 4.0469,
  longitude: 9.6900,
  email: 'bonanjo@findpharma.cm',
  phone: '+237690000002',
);

const Pharmacy deido = Pharmacy(
  id: 'deido',
  name: 'Pharmacie Deido',
  district: 'Deido',
  latitude: 4.0667,
  longitude: 9.7000,
  email: 'deido@findpharma.cm',
  phone: '+237690000003',
);

void main() {
  // Depuis Bonanjo : bonanjo 0,00 km, akwa 2,10 km, deido 2,47 km.
  const UserPosition fromBonanjo = (latitude: 4.0469, longitude: 9.6900);

  List<String> idsOf(List<Pharmacy> pharmacies) =>
      pharmacies.map((Pharmacy pharmacy) => pharmacy.id).toList();

  test('sans position, conserve l ordre du repository', () async {
    final GetPharmaciesUseCase getPharmacies = GetPharmaciesUseCase(
      _FakePharmacyRepository(<Pharmacy>[deido, akwa, bonanjo]),
    );

    expect(idsOf(await getPharmacies()), <String>['deido', 'akwa', 'bonanjo']);
  });

  test('avec une position, trie par distance croissante', () async {
    final GetPharmaciesUseCase getPharmacies = GetPharmaciesUseCase(
      _FakePharmacyRepository(<Pharmacy>[deido, akwa, bonanjo]),
    );

    expect(
      idsOf(await getPharmacies(from: fromBonanjo)),
      <String>['bonanjo', 'akwa', 'deido'],
    );
  });

  test('ne modifie pas la liste renvoyee par le repository', () async {
    final List<Pharmacy> source = <Pharmacy>[deido, akwa, bonanjo];
    final GetPharmaciesUseCase getPharmacies = GetPharmaciesUseCase(
      _FakePharmacyRepository(source),
    );

    await getPharmacies(from: fromBonanjo);

    expect(idsOf(source), <String>['deido', 'akwa', 'bonanjo']);
  });

  test('renvoie une liste vide quand il n y a aucune pharmacie', () async {
    final GetPharmaciesUseCase getPharmacies = GetPharmaciesUseCase(
      _FakePharmacyRepository(<Pharmacy>[]),
    );

    expect(await getPharmacies(from: fromBonanjo), isEmpty);
  });
}
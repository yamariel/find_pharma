import 'package:find_pharma/features/pharmacies/domain/entities/pharmacy.dart';
import 'package:find_pharma/features/pharmacies/domain/repositories/pharmacy_repository.dart';
import 'package:find_pharma/features/pharmacies/domain/usecases/get_on_duty_pharmacies_usecase.dart';
import 'package:find_pharma/features/pharmacies/domain/usecases/get_pharmacies_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Les fixtures ne peuvent pas etre `const` : aucun constructeur de DateTime
/// ne l est.
Pharmacy pharmacyOnDuty(String id, {DateTime? from, DateTime? until}) {
  return Pharmacy(
    id: id,
    name: 'Pharmacie $id',
    district: id,
    latitude: 4.05,
    longitude: 9.70,
    email: '$id@findpharma.cm',
    phone: '+237690000000',
    onDutyFrom: from,
    onDutyUntil: until,
  );
}

void main() {
  final DateTime monday = DateTime.utc(2026, 10, 5, 8);
  final DateTime friday = DateTime.utc(2026, 10, 9, 8);
  final DateTime sunday = DateTime.utc(2026, 10, 11, 8);

  GetOnDutyPharmaciesUseCase useCaseAt(DateTime now, List<Pharmacy> data) {
    return GetOnDutyPharmaciesUseCase(
      GetPharmaciesUseCase(_FakePharmacyRepository(data)),
      () => now,
    );
  }

  List<String> idsOf(List<Pharmacy> pharmacies) =>
      pharmacies.map((Pharmacy pharmacy) => pharmacy.id).toList();

  test('ne garde que les pharmacies dont la garde couvre l instant', () async {
    final List<Pharmacy> data = <Pharmacy>[
      pharmacyOnDuty('en-garde', from: monday, until: sunday),
      pharmacyOnDuty('garde-passee', from: monday, until: friday),
      pharmacyOnDuty('sans-garde'),
    ];

    final List<Pharmacy> result = await useCaseAt(
      DateTime.utc(2026, 10, 10, 8),
      data,
    )();

    expect(idsOf(result), <String>['en-garde']);
  });

  test('une seule borne renseignee ne vaut pas une garde', () async {
    final List<Pharmacy> data = <Pharmacy>[
      pharmacyOnDuty('debut-seul', from: monday),
      pharmacyOnDuty('fin-seule', until: sunday),
    ];

    expect(await useCaseAt(friday, data)(), isEmpty);
  });

  test('la borne de debut est incluse, celle de fin exclue', () async {
    final List<Pharmacy> data = <Pharmacy>[
      pharmacyOnDuty('a', from: monday, until: friday),
    ];

    expect(idsOf(await useCaseAt(monday, data)()), <String>['a']);
    expect(await useCaseAt(friday, data)(), isEmpty);
  });

  test('renvoie une liste vide quand aucune pharmacie n existe', () async {
    expect(await useCaseAt(friday, <Pharmacy>[])(), isEmpty);
  });
}
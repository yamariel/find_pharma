import '../../domain/entities/pharmacy.dart';

class PharmacyLocalMockDatasource {
  static final List<Pharmacy> fakePharmacies = [
    const Pharmacy(
      id: 'pharmacie-plateau-central',
      name: 'Pharmacie du Plateau',
      district: 'Plateau',
      latitude: 5.3197,
      longitude: -4.0171,
      phone: '+225 27 20 22 00 00',
      address: 'Avenue Lamblin',
      verifiedByPharmacy: true,
    ),
    const Pharmacy(
      id: 'pharmacie-cocody-vallons',
      name: 'Pharmacie Sainte Cécile',
      district: 'Cocody',
      latitude: 5.3599,
      longitude: -3.9876,
      phone: '+225 27 22 40 00 00',
      address: 'Boulevard des Martyrs, Les Vallons',
      verifiedByPharmacy: false,
    ),
    const Pharmacy(
      id: 'pharmacie-yopougon-maracana',
      name: 'Pharmacie de la Paix',
      district: 'Yopougon',
      latitude: 5.3361,
      longitude: -4.0883,
      phone: '+225 27 23 45 00 00',
      address: 'Quartier Maroc',
      verifiedByPharmacy: true,
    ),
  ];

  Future<List<Pharmacy>> getPharmacies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return fakePharmacies;
  }
}
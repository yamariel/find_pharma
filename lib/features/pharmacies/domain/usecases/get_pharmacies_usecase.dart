import '../../../../core/geo/user_position.dart';
import '../entities/pharmacy.dart';
import '../repositories/pharmacy_repository.dart';

/// Récupère les pharmacies, triées par distance quand la position est connue.
class GetPharmaciesUseCase {
  const GetPharmaciesUseCase(this._repository);

  final PharmacyRepository _repository;

  /// Sans [from], la liste garde l'ordre du repository.
  Future<List<Pharmacy>> call({UserPosition? from}) async {
    final List<Pharmacy> pharmacies = await _repository.getPharmacies();
    if (from == null) {
      return pharmacies;
    }

    final double latitude = from.latitude;
    final double longitude = from.longitude;

    // Copie : sort() modifie en place, et cette liste ne nous appartient pas.
    final List<Pharmacy> sorted = List<Pharmacy>.of(pharmacies);
    sorted.sort((Pharmacy first, Pharmacy second) {
      return first
          .distanceToKm(latitude, longitude)
          .compareTo(second.distanceToKm(latitude, longitude));
    });
    return sorted;
  }
}
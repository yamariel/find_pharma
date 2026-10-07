import '../../../../core/geo/user_position.dart';
import '../entities/pharmacy.dart';
import 'get_pharmacies_usecase.dart';

/// Pharmacies dont la garde déclarée couvre l'instant présent.
///
/// Compose [GetPharmaciesUseCase] au lieu d'attaquer le repository
/// directement : la règle « les plus proches d'abord » reste écrite à un seul
/// endroit, et la garde hérite du tri sans le redéfinir.
class GetOnDutyPharmaciesUseCase {
  const GetOnDutyPharmaciesUseCase(this._getPharmacies, this._now);

  final GetPharmaciesUseCase _getPharmacies;

  /// Horloge injectée, jamais `DateTime.now()` en dur.
  final DateTime Function() _now;

  Future<List<Pharmacy>> call({UserPosition? from}) async {
    final List<Pharmacy> pharmacies = await _getPharmacies(from: from);
    final DateTime instant = _now();
    return pharmacies
        .where((Pharmacy pharmacy) => pharmacy.isOnDutyAt(instant))
        .toList(growable: false);
  }
}
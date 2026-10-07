import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Horloge de l'application.
///
/// Les use cases reçoivent cette fonction au lieu d'appeler `DateTime.now()`
/// eux-mêmes : un test peut alors figer l'instant, et la règle testée ne dépend
/// plus de l'heure à laquelle la suite tourne.
final Provider<DateTime Function()> clockProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Coordonnées de l'utilisateur au moment d'une recherche.
typedef UserPosition = ({double latitude, double longitude});

/// Position courante, `null` tant que la géolocalisation n'est pas branchée.
///
/// Le module carte n'aura qu'à surcharger ce provider.
final Provider<UserPosition?> userPositionProvider =
    Provider<UserPosition?>((Ref ref) => null);
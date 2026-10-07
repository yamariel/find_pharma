# Module carte

Carte des pharmacies : affichage, marqueurs regroupés, sélection, localisation
ponctuelle et itinéraire automobile OSRM.

## Organisation

| Couche | Contenu |
| --- | --- |
| `domain/entities` | `MapPharmacy`, `RoadRoute`, `validateCoordinates` |
| `domain/repositories` | `LocationRepository`, `RoutingRepository` |
| `domain/usecases` | `GetUserLocationUseCase`, `GetRoadRouteUseCase` |
| `data/datasources` | `GeolocatorLocationDataSource`, `OsrmRoutingDataSource` |
| `presentation/pages` | `MapPage`, route `/map` |
| `presentation/providers` | `mapProvider` — adapte `Pharmacy` en `MapPharmacy` |
| `presentation/widgets` | `PharmacyMapView` et ses widgets |
| `presentation/controllers` | `PharmacyMapController` — état d'écran |

Les échecs `LocationFailure` et `RoutingFailure` sont dans
`core/errors/failures.dart` et héritent de `Failure`.

## Contrat public

`PharmacyMapView` ne lit aucune base : l'hôte lui fournit les données.

- `pharmacies` : liste de `MapPharmacy`. Projection publique — identifiant, nom,
  coordonnées WGS84 valides, adresse facultative, `OpeningStatus`, noms publics
  des vendeurs présents, disponibilité, prix formaté. **Une donnée absente reste
  inconnue** : la carte ne déduit jamais l'ouverture ou la disponibilité.
- `medicine` : `MedicineContext` fourni par le module de recherche.
- `selectedPharmacyId`, `onSelectionChanged`, `onViewPharmacy` : sélection et
  ouverture de la fiche.
- `loading`, `errorMessage` (message public, jamais une exception Firebase),
  `onRetry` : les trois états d'affichage.
- `locationRepository`, `routingRepository`, `tileProvider` : injectables pour
  les tests.

## Utilisation

`MapPage` observe `mapProvider`, qui adapte `pharmaciesProvider` en
`MapPharmacy`. La route `/map` accepte `?pharmacyId=` pour ouvrir la carte sur
une pharmacie précise.

## Configuration

`MapConfig` lit ses valeurs via `--dart-define`, avec des valeurs par défaut
publiques : `MAP_TILE_URL`, `MAP_TILE_ATTRIBUTION`, `MAP_TILE_ATTRIBUTION_URL`,
`MAP_ROUTING_URL`.

Le routage limite les appels à une requête par seconde sur les serveurs OSRM
publics, conformément à leur politique d'usage.

## Limites connues

- Le repository pharmacies lit toute la collection ; le bornage géographique
  (zone, rayon, limite, pagination) reste à faire côté données.
- Sans position disponible, la carte reste consultable et se centre sur un point
  par défaut, qui n'est pas présenté comme une position mesurée.
- `RoutingRepository.dispose()` est une préoccupation d'implémentation encore
  présente dans le contrat ; elle disparaîtra quand Riverpod portera le cycle de
  vie du datasource.
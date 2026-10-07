# Module cartographique — intégration dans dev

Le module reste dans `lib/map`, avec ses tests dans `test/map` et
`integration_test/map_linux_test.dart`. La fusion de `dev` conserve son démarrage
Firebase/Riverpod, son routeur, ses thèmes et tous les modules de l’équipe.
La démonstration ne remplace plus `lib/main.dart`.

## Ouvrir et vérifier

Avec le SDK du dépôt (CI : Flutter 3.47.5), exécuter :

```sh
flutter pub get
# Créer un .env vide uniquement s’il n’existe pas (asset requis par dev).
flutter run -d linux -t lib/map/demo/main.dart
flutter analyze
flutter test
flutter test integration_test/map_linux_test.dart -d linux
```

Le point d’entrée de démonstration n’initialise pas Firebase. Ses pharmacies sont
fictives et signalées dans l’interface ; aucune donnée n’est écrite à distance.
`flutter run` sans cible démarre l’application de l’équipe.

## Fonctionnalités et contrat public

Importer `package:find_pharma/map/map.dart` et construire
`PharmacyMapScreen(pharmacies: resultats)` depuis la présentation de l’application.
Le composant propose la carte, les marqueurs regroupés, la sélection, une fiche
publique, la localisation ponctuelle, le recentrage et un itinéraire automobile
OSRM avec distance, durée estimée sans trafic en temps réel et effacement.
Le refus de localisation laisse la carte consultable, centrée par défaut sur
Kinshasa ; ce centre n’est pas présenté comme une position mesurée.

- `MapPharmacy` est une projection publique : identifiant, nom, latitude/longitude
  WGS84 valides, adresse facultative, `OpeningStatus` ouvert/fermé/inconnu,
  noms publics des vendeurs présents, disponibilité et prix de vente formaté.
  Une donnée absente reste inconnue. Le module métier fournit l’état d’ouverture.
- `medicine` reçoit un `MedicineContext`. Le module de recherche fournit uniquement
  les pharmacies correspondant au médicament et leur disponibilité/prix.
- `selectedPharmacyId`, `onSelectionChanged` et `onViewPharmacy` relient la sélection
  et l’écran de détail ; transmettre une nouvelle liste pour appliquer les filtres.
- `loading`, `errorMessage` (message public), `onRetry` distinguent le chargement,
  l’erreur et les résultats vides. Aucune erreur Firebase ne déclenche la démo.
- `locationService`, `routingService` et `tileProvider` sont injectables pour les tests.

La route `/map` et l’onglet carte client utilisent désormais `PharmacyMapScreen`
via `lib/features/map/presentation/pages/map_page.dart`. Le provider de carte
adapte le catalogue métier existant en `MapPharmacy`, avec chargement, erreur
et nouvelle tentative. Le paramètre `pharmacyId` permet à l’assistant de
présélectionner une pharmacie, même si le catalogue arrive ensuite. L’ouverture,
la présence des vendeurs et le stock restent inconnus faute de données associées.
Le callback de détail reste absent : `PharmacyDetailPage` est encore vide sur dev.
Aucun second repository Firebase n’a été créé.

Le backend doit fournir une requête bornée géographiquement (zone/rayon, limite,
pagination), des coordonnées valides et une projection publique des pharmacies,
avec les résultats de disponibilité/prix associés au médicament demandé.
Réutiliser les repositories et la logique d’ouverture de `dev` pour cette adaptation.
Le repository existant lit actuellement toute la collection : la requête bornée
reste à mettre en place avant un déploiement à grande échelle. L’intégration
ne modifie pas ce contrat métier et n’expose ni coûts d’achat ni données clients.
Aucune modification des règles Firebase n’est requise par cette fusion.

## Configuration

Paramètres de compilation `--dart-define=...`, ou instance `MapConfig` injectée :

| Paramètre | Valeur par défaut |
| --- | --- |
| `MAP_TILE_URL` | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |
| `MAP_TILE_ATTRIBUTION` | `© OpenStreetMap contributors` |
| `MAP_TILE_ATTRIBUTION_URL` | `https://www.openstreetmap.org/copyright` |
| `MAP_ROUTING_URL` | `https://router.project-osrm.org` |

Le serveur OSRM public est un serveur de démonstration : prévoir un fournisseur
approprié pour la production. L’URL racine doit exposer `/route/v1/driving` avec
un profil automobile. Les requêtes utilisent longitude,latitude ; la géométrie
GeoJSON reçue est convertie en latitude,longitude pour Flutter.
Respecter la [politique des tuiles OSM](https://operations.osmfoundation.org/policies/tiles/)
et conserver l’attribution ; pas de téléchargement massif/hors ligne.
L’identification réseau est configurable via `MapConfig.userAgent`.
Aucune clé secrète ne doit être ajoutée au code.

## Validation et limites connues

La précédente validation native Linux avait réussi le trajet OSRM réel
(75 points), son effacement et les scénarios de refus/erreur, mais échoué sur
l’affichage des tuiles : fond gris. Ce problème reste à diagnostiquer ; une suite
unitaire verte ne valide pas le rendu réel de la carte. La localisation réelle
n’avait pas pu être confirmée, le service de localisation Linux étant désactivé.

Validation après résolution des conflits (5 octobre 2026, base `dev` : `8d07730`) :
`flutter pub get` réussi, formatage des deux fichiers Dart adaptés sans changement,
`flutter analyze --no-pub` sans problème et `flutter test --no-pub` : **102 tests
réussis**. XML Android et plist Apple valides ; diff par rapport à `dev` sans
erreur d’espacement ni conflit restant.

La compilation et les tests natifs Linux n’ont pas été relancés pour cette fusion.
Ils restent à exécuter avec le point d’entrée isolé ; la réussite des 102 tests
n’inclut pas `integration_test/`. Android/iOS/macOS et le parcours Firebase complet
restent à vérifier sur les plateformes correspondantes. Le guidage vocal, la localisation
en arrière-plan et le recalcul continu restent hors périmètre.

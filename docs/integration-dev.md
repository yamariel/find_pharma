# Raccordement des modules de dev

Périmètre confirmé le 6 octobre 2026 : uniquement les modules déjà présents sur
`dev`, sans fusion d’autres branches, refonte des écrans ni ajout des fonctionnalités
manquantes. Aucun déploiement ou changement distant de données n’est effectué.

## Parcours raccordés

- Carte client et route `/map` : catalogue existant `pharmaciesProvider` adapté au
  composant `PharmacyMapScreen`, avec chargement, erreur et nouvelle tentative.
- Accueil visiteur : l’onglet Carte ouvre `/map`, l’onglet Médicaments utilise
  `SearchMedicinesPage`. Les liens de création de compte et d’accès réservé
  utilisent `/signup/client`.
- Accueil client : les raccourcis de recherche et de pharmacies conservent
  l’accueil dans la pile de navigation pour permettre le retour.
- Assistant : les pharmacies proviennent du repository métier existant au lieu
  du catalogue fictif. Appeler ouvre le composeur téléphonique ; Itinéraire ouvre
  la carte avec `pharmacyId`. L’utilisateur lance ensuite le calcul du trajet
  depuis le composant carte existant.
- Détail médicament : le bouton d’appel existant reçoit le téléphone de la fiche
  pharmacie correspondante. Un téléphone absent n’est pas inventé.
- Médicaments et pharmacies : même provider Firestore partagé.

La carte ne déduit pas l’ouverture, la présence des vendeurs ou la disponibilité
d’un médicament à partir de la seule existence d’une pharmacie.

## Éléments présents seulement sous forme d’ébauches

| Parcours | État dans dev |
| --- | --- |
| Liste des pharmacies | `PharmaciesPage` affiche un texte provisoire |
| Détail pharmacie | `PharmacyDetailPage` est une classe vide ; aucun callback de détail branché |
| Pharmacies de garde | Écrans provisoires et use case vide ; aucune sélection fiable possible |
| Favoris | Lien `/favorites`, sans route ni écran correspondant |
| Inscription pharmacie | Lien `/signup-pharmacy`, sans formulaire ni route correspondante |
| Vérification des pharmacies | Lien `/admin-verify-pharmacies`, sans écran correspondant |
| Gestion des utilisateurs | Lien `/admin-users` absent du routeur, onglet provisoire |
| Profil administrateur | Onglet provisoire |
| Mot de passe oublié | Bouton de connexion sans action |

Ces éléments ne sont pas remplacés par d’autres parcours : ils nécessitent un
travail distinct de développement ou l’apport des modules manquants.

## Vérification et limites

Validation du 6 octobre 2026 : `flutter analyze --no-pub` sans problème.
La suite complète a validé 122 tests sur 123 ; après correction d’une assertion
du test de navigation (pile de pages plutôt qu’URL), les quatre tests de
`test/integration/feature_navigation_test.dart` ont tous réussi. Aucun code
applicatif n’a changé entre ces deux exécutions. `git diff --check` est propre.

Les tests de navigation couvrent les liens visiteur et la transmission de la
pharmacie choisie par l’assistant. Les tests de provider vérifient le catalogue
et ses erreurs, sans pharmacies fictives. Un test de carte vérifie la sélection
d’une destination transmise avant la fin du chargement.

Les tests automatisés ne valident pas les règles et données Firebase distantes,
le service IA réel, les appels téléphoniques, les tuiles et la géolocalisation sur
appareil. Le parcours réel sur les plateformes cibles reste à vérifier.

Le repository pharmacie existant lit toute la collection : le bornage géographique
mentionné dans le README carte reste à réaliser. Les cartes de l’assistant
historique dépendent toujours du catalogue chargé lors d’un nouvel échange.

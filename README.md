# FindPharma

**Trouver une pharmacie ouverte et le médicament dont on a besoin, maintenant.**

[![CI](https://github.com/yamariel/find_pharma/actions/workflows/ci.yml/badge.svg?branch=dev)](https://github.com/yamariel/find_pharma/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A5%203.47.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A5%203.13.1-0175C2?logo=dart)](https://dart.dev)

Projet du **hackathon final — FlutterFire Summer Camp 2026**.

Application Flutter développée dans le cadre du **FlutterFire Summer Camp 2026**.
Objectif de développement durable visé : **ODD 3 — Bonne santé et bien-être**.

---

## Le problème

Chercher un médicament en urgence, le soir ou le week-end, se fait aujourd'hui au
téléphone ou à pied. Deux informations manquent au moment où elles comptent :
quelles pharmacies sont **ouvertes ou de garde** autour de moi, et laquelle a
réellement le médicament **en stock**. Se déplacer pour rien, de nuit et parfois
pour un enfant malade, est le coût le plus lourd du système actuel.

FindPharma répond à ces deux questions sur un téléphone, en quelques secondes.

---

## Fonctionnalités

**Côté patient**

- Pharmacies proches, triées par distance réelle.
- Filtre sur celles **ouvertes maintenant** et celles **de garde**.
- Recherche d'un médicament et disponibilité par pharmacie.
- Appel direct et itinéraire en un geste.
- Accès **sans compte** aux fonctions essentielles : quelqu'un qui ouvre
  l'application dans l'urgence ne doit pas s'inscrire d'abord.

**Côté pharmacie**

- Compte authentifié.
- Mise à jour de la fiche : coordonnées, horaires, position.
- Déclaration du stock et des périodes de garde.

---

## Architecture

**Feature-first + Clean Architecture.** Le code est découpé d'abord par
fonctionnalité métier, puis par couche. Tout ce qui concerne les pharmacies tient
dans un seul dossier, au lieu d'être réparti entre un `models/` et un `screens/`
communs à toute l'application.

```
lib/
├── core/                          # transverse, ne dépend d'aucune feature
│   └── errors/                    # exceptions (data) et failures (domaine)
└── features/
    └── pharmacies/
        ├── domain/                # Dart pur — ni Flutter, ni Firebase
        │   ├── entities/
        │   ├── repositories/      # contrats uniquement
        │   └── usecases/
        ├── data/
        │   ├── models/            # étend l'entité + sérialisation Firestore
        │   ├── datasources/
        │   └── repositories/      # implémentations des contrats
        └── presentation/
            ├── providers/         # Riverpod
            ├── pages/
            └── widgets/

test/                              # miroir de lib/
```

### La règle de dépendance

```
presentation  ──▶  domain  ◀──  data
```

Les flèches pointent **vers le domaine**, jamais dans l'autre sens :

- `domain/` n'importe ni Flutter, ni Firebase, ni Dio. Il est testable sans
  émulateur, sans appareil et sans réseau.
- `data/` connaît le domaine et le traduit : `PharmacyModel extends Pharmacy` et
  sait se construire depuis un document Firestore et s'y réécrire.
- `presentation/` ne parle au domaine qu'à travers les use cases.

Le jour où l'on change de base de données, seul `data/` bouge.

### Conventions

- **Typage explicite partout** : `final String name`, `Map<String, dynamic>`. Le
  code doit se lire sans l'IDE.
- **Entités immuables** : constructeur `const`, `copyWith`, `==` et `hashCode`.
- **Les types Firestore ne quittent pas `data/`** : `GeoPoint`, `Timestamp` et
  `FieldValue` n'apparaissent ni dans `domain/`, ni dans `presentation/`.
- **Imports `package:` dans les tests** : un import relatif depuis `test/` vers
  `lib/` crée deux identités pour la même classe et produit des erreurs de type
  incompréhensibles.

---

## Stack technique

| Dépendance | Version | Rôle |
|---|---|---|
| `flutter_riverpod` | ^3.4.3 | Gestion d'état et injection de dépendances |
| `go_router` | ^18.0.1 | Navigation déclarative et redirections |
| `firebase_core` | ^4.15.0 | Initialisation Firebase |
| `firebase_auth` | ^6.7.0 | Authentification des comptes pharmacie |
| `cloud_firestore` | ^6.10.0 | Pharmacies, stocks et gardes |
| `dio` | ^5.11.1 | Appels HTTP sortants |
| `hive_flutter` | ^1.1.0 | Cache local |
| `flutter_dotenv` | ^6.0.1 | Chargement des secrets depuis `.env` |
| `intl` | ^0.20.3 | Formatage des dates et des nombres |
| `flutter_lints` | ^6.0.0 | Analyse statique (dev) |

Backend : **Firebase**, projet `find-pharma-f9151`.

---

## Démarrage rapide

### 1. Vérifier le SDK

```bash
flutter --version
```

Il faut **Flutter ≥ 3.47.0** et **Dart ≥ 3.13.1**, bornes fixées par le
`pubspec.lock` versionné.

> Si `flutter pub get` échoue sur `version solving failed` en mentionnant le SDK
> Dart, votre Flutter est trop ancien : lancez `flutter upgrade`. **Ne baissez pas
> la contrainte dans `pubspec.yaml`** — cela réécrit le `pubspec.lock` partagé et
> casse l'environnement de toute l'équipe.

### 2. Installer

```bash
git clone https://github.com/yamariel/find_pharma.git
cd find_pharma
git switch dev
flutter pub get
```

### 3. Créer le fichier `.env`

`.env` est déclaré comme asset dans `pubspec.yaml` et n'est pas versionné. Sans
lui, l'application refuse de démarrer avec
`No file or variants found for asset: .env`.

```bash
cp .env.example .env
```

Un fichier vide suffit pour l'analyse statique et les tests.

### 4. Lancer

```bash
flutter run
```

---

## Tests

```bash
flutter test                              # toute la suite
flutter test test/features/pharmacies/    # un module
flutter test --coverage
```

Les tests du domaine et de la sérialisation ne nécessitent ni Firebase
initialisé, ni émulateur, ni connexion : `GeoPoint` et `Timestamp` sont des
classes de valeur pures, et `FieldValue.serverTimestamp()` ne fabrique qu'un
sentinel local. La suite tourne en quelques secondes, sur le poste de chacun
comme sur la CI.

Toute classe du domaine et tout modèle sont livrés avec leurs tests, dans la
même pull request.

---

## Intégration continue

Le workflow [`ci.yml`](.github/workflows/ci.yml) se déclenche sur chaque push et
chaque pull request visant `dev` ou `main`, et exécute `flutter pub get`,
`flutter analyze` puis `flutter test`.

`flutter analyze` a `--fatal-infos` actif par défaut : un message de niveau
`info` suffit à faire échouer le build. Lancez-le avant de pousser.

---

## Contribuer

Les conventions de branches, de commits et de revue sont définies dans
**[`REGLES.md`](REGLES.md)**, qui fait foi.

```bash
git switch dev
git pull origin dev
git switch -c feat/ma-tache
```

| | Format |
|---|---|
| Branche | `type/nom-de-la-tache` |
| Commit | `type: description courte` |
| Cible des pull requests | `dev` |

Un commit par unité logique, les dépendances ajoutées une par une. Aucun
développement directement sur `main`.

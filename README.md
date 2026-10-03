# FindPharma

Application mobile de géolocalisation de pharmacies et d'assistant de santé intelligent, développée avec Flutter.

## Code source (`lib/`)

```text
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
	│   │   ├── failures.dart
	│   │   └── medicine_exceptions.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── dio_provider.dart
│   │   └── firebase_config.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── app_router.dart
	│       ├── date_formatter.dart
	│       └── medicine_ui.dart
└── features/
	├── ai_assistant/
	│   ├── data/
	│   │   ├── datasources/
	│   │   │   └── ai_remote_data_source.dart
	│   │   ├── models/
	│   │   │   └── ai_response_model.dart
	│   │   └── repositories/
	│   │       └── ai_repository_impl.dart
	│   ├── domain/
	│   │   ├── entities/
	│   │   │   └── ai_suggestion.dart
	│   │   ├── repositories/
	│   │   │   └── ai_repository.dart
	│   │   └── usecases/
	│   │       └── ask_health_assistant_usecase.dart
	│   └── presentation/
	│       ├── pages/
	│       │   └── ai_chat_page.dart
	│       ├── providers/
	│       │   └── ai_provider.dart
	│       └── widgets/
	│           └── chat_bubble.dart
	├── auth/
	│   ├── data/
	│   │   ├── datasources/
	│   │   │   └── auth_remote_data_source.dart
	│   │   ├── models/
	│   │   │   └── user_model.dart
	│   │   └── repositories/
	│   │       └── auth_repository_impl.dart
	│   ├── domain/
	│   │   ├── entities/
	│   │   │   └── user_entity.dart
	│   │   ├── repositories/
	│   │   │   └── auth_repository.dart
	│   │   └── usecases/
	│   │       ├── login_usecase.dart
	│   │       ├── logout_usecase.dart
	│   │       └── register_usecase.dart
	│   └── presentation/
	│       ├── pages/
	│       │   ├── login_page.dart
	│       │   ├── profile_page.dart
	│       │   └── register_page.dart
	│       └── providers/
	│           ├── auth_provider.dart
	│           └── profile_provider.dart
	├── map/
	│   ├── data/
	│   │   ├── datasources/map_remote_data_source.dart
	│   │   ├── models/map_location_model.dart
	│   │   └── repositories/map_repository_impl.dart
	│   ├── domain/
	│   │   ├── entities/map_location.dart
	│   │   ├── repositories/map_repository.dart
	│   │   └── usecases/get_locations_usecase.dart
	│   └── presentation/
	│       ├── pages/map_page.dart
	│       ├── providers/map_provider.dart
	│       └── widgets/map_view.dart
	├── medicines/
	│   ├── data/
	│   │   ├── datasources/
	│   │   │   └── medicine_remote_data_source.dart
	│   │   ├── models/
	│   │   │   ├── inventory_item_model.dart
	│   │   │   └── medicine_model.dart
	│   │   └── repositories/
	│   │       ├── fake_medicine_repository.dart
	│   │       └── medicine_repository_impl.dart
	│   ├── domain/
	│   │   ├── entities/
	│   │   │   ├── inventory_item.dart
	│   │   │   └── medicine.dart
	│   │   ├── repositories/
	│   │   │   └── medicine_repository.dart
	│   │   └── usecases/
	│   │       ├── add_medicine_usecase.dart
	│   │       ├── adjust_stock_usecase.dart
	│   │       ├── get_cheaper_alternative_usecase.dart
	│   │       ├── search_medicines_usecase.dart
	│   │       └── watch_pharmacies_with_stock_usecase.dart
	│   └── presentation/
	│       ├── pages/
	│       │   └── search_medicines_page.dart
	│       ├── providers/
	│       │   └── medicine_provider.dart
	│       └── widgets/
	│           ├── alternative_card.dart
	│           ├── availability_tile.dart
	│           ├── medicine_card.dart
	│           ├── medicine_detail_view.dart
	│           └── medicine_search_bar.dart
	└── pharmacies/
		├── data/
		│   ├── datasources/
		│   │   └── pharmacy_remote_data_source.dart
		│   ├── models/
		│   │   └── pharmacy_model.dart
		│   └── repositories/
		│       └── pharmacy_repository_impl.dart
		├── domain/
		│   ├── entities/
		│   │   └── pharmacy.dart
		│   ├── repositories/
		│   │   └── pharmacy_repository.dart
		│   └── usecases/
		│       ├── get_on_duty_pharmacies_usecase.dart
		│       └── get_pharmacies_usecase.dart
		└── presentation/
			├── pages/
			│   ├── pharmacies_page.dart
			│   └── pharmacy_detail_page.dart
			├── providers/
			│   └── pharmacy_provider.dart
			└── widgets/
				├── map_view.dart
				└── pharmacy_card.dart
```

## Organisation

- `main.dart` : initialise dotenv, Firebase, les formats de date français et l'application Riverpod.
- `core/` : configuration réseau et Firebase, gestion des erreurs, thème, routage avec GoRouter et formatage des dates.
- `features/` : modules fonctionnels séparés en `data` (sources, modèles et implémentations), `domain` (entités, contrats et cas d'usage) et `presentation` (pages, providers et widgets).
- `features/pharmacies/` : recherche et détails des pharmacies, pharmacies de garde et widgets associés, dont une vue de carte.
- `features/map/` : structure dédiée aux emplacements et à leur affichage; son implémentation est actuellement en cours.
- `features/medicines/` : recherche de médicaments, équivalents, consultation des stocks et opérations d'inventaire.
- `features/ai_assistant/` : conversation avec l'assistant de santé.
- `features/auth/` : inscription, connexion et profil utilisateur.

## Technologies principales

Flutter et Dart, Firebase (authentification et Firestore), Riverpod, GoRouter, Dio, dotenv et `intl`.

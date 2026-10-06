import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_pharma/core/errors/exceptions.dart';
import 'package:find_pharma/features/pharmacies/data/models/pharmacy_model.dart';
import 'package:find_pharma/features/pharmacies/domain/entities/pharmacy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // L'identifiant n'est jamais dans les données : Firestore le porte à part.
  // Vérifier que le modèle le prend bien du document est l'un des buts ici.
  const String documentId = 'ph_akwa_001';

  // Instant de référence en UTC : le test doit donner le même résultat à
  // Douala (UTC+1) et sur le runner GitHub (UTC).
  final DateTime referenceInstant = DateTime.utc(2026, 9, 30, 14, 30);

  /// Document complet : tous les champs, y compris les optionnels.
  Map<String, dynamic> completeData() => <String, dynamic>{
    PharmacyFields.name: 'Pharmacie du Centre',
    PharmacyFields.district: 'Akwa',
    PharmacyFields.position: const GeoPoint(4.0511, 9.7085),
    PharmacyFields.phone: '+237690000001',
    PharmacyFields.email: 'contact@pharmacieducentre.cm',
    PharmacyFields.address: 'Rue Joss, face marché',
    PharmacyFields.secondaryPhone: '+237690000002',
    PharmacyFields.verifiedByPharmacy: true,
    PharmacyFields.updatedAt: Timestamp.fromDate(referenceInstant),
  };

  /// Document minimal : uniquement les champs obligatoires.
  Map<String, dynamic> minimalData() => <String, dynamic>{
    PharmacyFields.name: 'Pharmacie du Centre',
    PharmacyFields.district: 'Akwa',
    PharmacyFields.position: const GeoPoint(4.0511, 9.7085),
    PharmacyFields.phone: '+237690000001',
    PharmacyFields.email: 'contact@pharmacieducentre.cm',
  };

  group('PharmacyModel.fromFirestore', () {
    test('lit tous les champs d\'un document complet', () {
      final PharmacyModel model = PharmacyModel.fromFirestore(
        completeData(),
        documentId,
      );

      expect(model.id, documentId);
      expect(model.name, 'Pharmacie du Centre');
      expect(model.district, 'Akwa');
      expect(model.latitude, 4.0511);
      expect(model.longitude, 9.7085);
      expect(model.phone, '+237690000001');
      expect(model.email, 'contact@pharmacieducentre.cm');
      expect(model.address, 'Rue Joss, face marché');
      expect(model.secondaryPhone, '+237690000002');
      expect(model.verifiedByPharmacy, isTrue);
      expect(model.updatedAt, isNotNull);
      expect(model.updatedAt!.isAtSameMomentAs(referenceInstant), isTrue);
    });

    test('prend l\'identifiant du document, jamais celui des données', () {
      final Map<String, dynamic> data = completeData()..['id'] = 'valeur_piege';

      final PharmacyModel model = PharmacyModel.fromFirestore(data, documentId);

      expect(model.id, documentId);
    });

    test('applique les valeurs par défaut sur un document minimal', () {
      final PharmacyModel model = PharmacyModel.fromFirestore(
        minimalData(),
        documentId,
      );

      expect(model.address, isNull);
      expect(model.secondaryPhone, isNull);
      expect(model.updatedAt, isNull);
      expect(model.verifiedByPharmacy, isFalse);
    });

    test('lève une ValidationException quand un champ requis est absent', () {
      final Map<String, dynamic> data = completeData()
        ..remove(PharmacyFields.name);

      expect(
        () => PharmacyModel.fromFirestore(data, documentId),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lève une ValidationException quand un champ requis a le mauvais '
        'type', () {
      final Map<String, dynamic> data = completeData()
        ..[PharmacyFields.position] = '4.0511, 9.7085';

      expect(
        () => PharmacyModel.fromFirestore(data, documentId),
        throwsA(isA<ValidationException>()),
      );
    });

    test('nomme le document et le champ fautif dans le message', () {
      final Map<String, dynamic> data = completeData()
        ..remove(PharmacyFields.phone);

      expect(
        () => PharmacyModel.fromFirestore(data, documentId),
        throwsA(
          isA<ValidationException>().having(
            (ValidationException exception) => exception.message,
            'message',
            allOf(contains(documentId), contains(PharmacyFields.phone)),
          ),
        ),
      );
    });

    test('ignore un champ optionnel de type invalide au lieu d\'échouer', () {
      final Map<String, dynamic> data = completeData()
        ..[PharmacyFields.address] = 42;

      final PharmacyModel model = PharmacyModel.fromFirestore(data, documentId);

      expect(model.address, isNull);
      expect(model.name, 'Pharmacie du Centre');
    });
  });

  group('PharmacyModel.toFirestore', () {
    test('écrit la position sous forme de GeoPoint', () {
      final PharmacyModel model = PharmacyModel.fromFirestore(
        completeData(),
        documentId,
      );

      final Map<String, dynamic> written = model.toFirestore();

      expect(written[PharmacyFields.position], isA<GeoPoint>());
      final GeoPoint position = written[PharmacyFields.position] as GeoPoint;
      expect(position.latitude, 4.0511);
      expect(position.longitude, 9.7085);
    });

    test('ne sérialise pas l\'identifiant', () {
      final PharmacyModel model = PharmacyModel.fromFirestore(
        completeData(),
        documentId,
      );

      expect(model.toFirestore().containsKey('id'), isFalse);
    });

    test('délègue updatedAt à l\'horloge du serveur', () {
      final PharmacyModel model = PharmacyModel.fromFirestore(
        completeData(),
        documentId,
      );

      expect(model.toFirestore()[PharmacyFields.updatedAt], isA<FieldValue>());
    });

    test('n\'écrit pas de valeur pour un champ optionnel absent', () {
      final PharmacyModel model = PharmacyModel.fromFirestore(
        minimalData(),
        documentId,
      );

      final Map<String, dynamic> written = model.toFirestore();

      expect(written[PharmacyFields.address], isNull);
      expect(written[PharmacyFields.secondaryPhone], isNull);
    });

    test('un aller-retour Firestore conserve les données', () {
      final PharmacyModel original = PharmacyModel.fromFirestore(
        completeData(),
        documentId,
      );

      // Le serveur remplace le sentinel par un vrai Timestamp : on simule
      // ce que relirait l'application après l'écriture.
      final Map<String, dynamic> written = original.toFirestore()
        ..[PharmacyFields.updatedAt] = Timestamp.fromDate(referenceInstant);

      final PharmacyModel reread = PharmacyModel.fromFirestore(
        written,
        documentId,
      );

      expect(reread, equals(original));
    });
  });

  group('PharmacyModel.fromEntity', () {
    test('produit un modèle égal à l\'entité source', () {
      const Pharmacy entity = Pharmacy(
        id: 'ph_bonanjo_002',
        name: 'Pharmacie de Bonanjo',
        district: 'Bonanjo',
        latitude: 4.0469,
        longitude: 9.6900,
        phone: '+237690000003',
        email: 'bonanjo@findpharma.cm',
        address: 'Boulevard de la Liberté',
        verifiedByPharmacy: true,
      );

      final PharmacyModel model = PharmacyModel.fromEntity(entity);

      expect(model, equals(entity));
      expect(model.hashCode, entity.hashCode);
    });

    test('permet d\'écrire une entité du domaine dans Firestore', () {
      const Pharmacy entity = Pharmacy(
        id: 'ph_bonanjo_002',
        name: 'Pharmacie de Bonanjo',
        district: 'Bonanjo',
        latitude: 4.0469,
        longitude: 9.6900,
        email: 'bonanjo@findpharma.cm',
        phone: '+237690000003',
      );

      final Map<String, dynamic> written = PharmacyModel.fromEntity(
        entity,
      ).toFirestore();

      expect(written[PharmacyFields.name], 'Pharmacie de Bonanjo');
      expect(written[PharmacyFields.verifiedByPharmacy], isFalse);
    });
  });
}
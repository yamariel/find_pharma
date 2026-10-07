import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_pharma/core/errors/exceptions.dart';
import 'package:find_pharma/features/pharmacies/data/models/opening_hours_mapper.dart';
import 'package:find_pharma/features/pharmacies/domain/entities/opening_hours.dart';
import 'package:find_pharma/features/pharmacies/domain/entities/pharmacy.dart';

/// Noms des champs tels qu'ils existent dans Firestore.
///
/// Centralisés ici parce qu'ils servent à trois endroits : la lecture,
/// l'écriture, et plus tard les requêtes triées. Une chaîne mal orthographiée
/// ne produit aucune erreur de compilation — elle produit un `null` silencieux.
abstract final class PharmacyFields {
  static const String name = 'name';
  static const String district = 'district';
  static const String position = 'position';
  static const String phone = 'phone';
  static const String email = 'email';
  static const String address = 'address';
  static const String secondaryPhone = 'secondaryPhone';
  static const String openingHours = 'openingHours';
  static const String onDutyFrom = 'onDutyFrom';
  static const String onDutyUntil = 'onDutyUntil';
  static const String verifiedByPharmacy = 'verifiedByPharmacy';
  static const String updatedAt = 'updatedAt';
}

/// Traduction entre un document Firestore et l'entité [Pharmacy].
///
/// C'est la seule classe du projet autorisée à connaître [GeoPoint] et
/// [Timestamp] pour une pharmacie. Au-delà de cette frontière, le domaine ne
/// manipule que des `double` et des `DateTime`.
class PharmacyModel extends Pharmacy {
  const PharmacyModel({
    required super.id,
    required super.name,
    required super.district,
    required super.latitude,
    required super.longitude,
    required super.phone,
    required super.email,
    super.address,
    super.secondaryPhone,
    super.openingHours,
    super.onDutyFrom,
    super.onDutyUntil,
    super.verifiedByPharmacy,
    super.updatedAt,
  });

  /// Construit le modèle depuis les données d'un document Firestore.
  ///
  /// [data] est le contenu du document, [id] son identifiant — Firestore les
  /// expose séparément, l'identifiant n'étant pas un champ.
  ///
  /// Lève une [ValidationException] si un champ obligatoire manque ou n'a pas
  /// le bon type. On ne substitue jamais de valeur par défaut 
  factory PharmacyModel.fromFirestore(Map<String, dynamic> data, String id) {
    final GeoPoint position = _requireGeoPoint(data, PharmacyFields.position, id);

    return PharmacyModel(
      id: id,
      name: _requireString(data, PharmacyFields.name, id),
      district: _requireString(data, PharmacyFields.district, id),
      latitude: position.latitude,
      longitude: position.longitude,
      phone: _requireString(data, PharmacyFields.phone, id),
      email: _optionalString(data, PharmacyFields.email),
      address: _optionalString(data, PharmacyFields.address),
      secondaryPhone: _optionalString(data, PharmacyFields.secondaryPhone),
      openingHours: OpeningHoursMapper.fromFirestore(
        data[PharmacyFields.openingHours],
      ),
      onDutyFrom: _optionalDateTime(data, PharmacyFields.onDutyFrom),
      onDutyUntil: _optionalDateTime(data, PharmacyFields.onDutyUntil),
      verifiedByPharmacy: _optionalBool(data, PharmacyFields.verifiedByPharmacy),
      updatedAt: _optionalDateTime(data, PharmacyFields.updatedAt),
    );
  }

  /// Enveloppe une entité du domaine pour pouvoir la sérialiser.
  factory PharmacyModel.fromEntity(Pharmacy pharmacy) {
    return PharmacyModel(
      id: pharmacy.id,
      name: pharmacy.name,
      district: pharmacy.district,
      latitude: pharmacy.latitude,
      longitude: pharmacy.longitude,
      phone: pharmacy.phone,
      email: pharmacy.email,
      address: pharmacy.address,
      secondaryPhone: pharmacy.secondaryPhone,
      openingHours: pharmacy.openingHours,
      onDutyFrom: pharmacy.onDutyFrom,
      onDutyUntil: pharmacy.onDutyUntil,
      verifiedByPharmacy: pharmacy.verifiedByPharmacy,
      updatedAt: pharmacy.updatedAt,
    );
  }

  /// Produit le contenu du document Firestore.
  ///
  /// L'identifiant n'y figure pas : c'est la clé du document, pas un champ.
  ///
  /// `updatedAt` est écrit avec l'horodatage **du serveur** et non celui du
  /// téléphone. Deux appareils mal réglés produiraient sinon des dates
  /// incohérentes, et tout l'indicateur de fraîcheur deviendrait faux.
  Map<String, dynamic> toFirestore() {
    final OpeningHours? hours = openingHours;
    final DateTime? dutyFrom = onDutyFrom;
    final DateTime? dutyUntil = onDutyUntil;
    return <String, dynamic>{
      PharmacyFields.name: name,
      PharmacyFields.district: district,
      PharmacyFields.position: GeoPoint(latitude, longitude),
      PharmacyFields.phone: phone,
      PharmacyFields.email: email,
      PharmacyFields.address: address,
      PharmacyFields.secondaryPhone: secondaryPhone,
      if (hours != null)
        PharmacyFields.openingHours: OpeningHoursMapper.toFirestore(hours),
      if (dutyFrom != null)
        PharmacyFields.onDutyFrom: Timestamp.fromDate(dutyFrom),
      if (dutyUntil != null)
        PharmacyFields.onDutyUntil: Timestamp.fromDate(dutyUntil),
      PharmacyFields.verifiedByPharmacy: verifiedByPharmacy,
      PharmacyFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  // ---------------------------------------------------------------------
  // Lecture des champs
  // ---------------------------------------------------------------------

  static String _requireString(
    Map<String, dynamic> data,
    String field,
    String id,
  ) {
    final Object? value = data[field];
    if (value is! String || value.trim().isEmpty) {
      throw ValidationException(
        'Document pharmacie "$id" : champ "$field" absent, vide ou de type invalide.',
      );
    }
    return value.trim();
  }

  static GeoPoint _requireGeoPoint(
    Map<String, dynamic> data,
    String field,
    String id,
  ) {
    final Object? value = data[field];
    if (value is! GeoPoint) {
      throw ValidationException(
        'Document pharmacie "$id" : champ "$field" absent ou n\'est pas un GeoPoint.',
      );
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> data, String field) {
    final Object? value = data[field];
    if (value is! String) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _optionalBool(Map<String, dynamic> data, String field) {
    final Object? value = data[field];
    return value is bool ? value : false;
  }

  static DateTime? _optionalDateTime(Map<String, dynamic> data, String field) {
    final Object? value = data[field];
    return value is Timestamp ? value.toDate() : null;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryItemModel {
  static InventoryItem fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    // serverTimestamp peut être null un court instant avant confirmation serveur
    final ts = d['updatedAt'] as Timestamp?;
    return InventoryItem(
      pharmacyId: d['pharmacyId'] ?? '',
      medicineId: d['medicineId'] ?? doc.id,
      medicineName: d['medicineName'] ?? '',
      dci: d['dci'] ?? '',
      quantity: (d['quantity'] ?? 0) as int,
      price: (d['price'] ?? 0) as int,
      updatedAt: ts?.toDate() ?? DateTime.now(),
      updatedBy: d['updatedBy'] ?? '',
      pharmacyName: d['pharmacyName'] ?? '',
    );
  }
}

class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class InsufficientStockException extends AppException {
  const InsufficientStockException() : super('Stock insuffisant.');
}

class MedicineNotFoundException extends AppException {
  const MedicineNotFoundException() : super('Médicament introuvable.');
}

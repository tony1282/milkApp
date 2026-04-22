class MilkRecordModel {
// modelo para representar un registro de leche
  final String milkId;
  final double milkLiters;
  final DateTime milkDate;
// Constructor
  MilkRecordModel({
    required this.milkId,
    required this.milkLiters,
    required this.milkDate,
  });
// convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'milkId': milkId,
      'milkLiters': milkLiters,
      'milkDate': milkDate.toIso8601String(),
    };
  }
// Crear un MilkRecordModel a partir de un Map
  factory MilkRecordModel.fromMap(Map<String, dynamic> map) => MilkRecordModel(
    milkId: map['milkId'] ?? '',
    milkLiters: (map['milkLiters']?? 0).toDouble(),
    milkDate: DateTime.parse(map['milkDate']),
  );

}
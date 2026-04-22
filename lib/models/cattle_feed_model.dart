class CattleFeedModel {
// variables para almacenar la información de la familia
  final String cattleId;
  final String cattleName;
  final double cattlePrice;
  final DateTime cattleDate;
  

// Constructor
  CattleFeedModel({
    required this.cattleId,
    required this.cattleName,
    required this.cattlePrice,
    required this.cattleDate,
  });

// convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'cattleId': cattleId,
      'cattleName': cattleName,
      'cattlePrice': cattlePrice,
      'cattleDate': cattleDate.toIso8601String(),
    };
  }

// Crear un FamilyMilkModel a partir de un Map
  factory CattleFeedModel.fromMap(Map<String, dynamic> map) => CattleFeedModel(
        cattleId: map['cattleId'] ?? '',
        cattleName: map['cattleName'] ?? '',
        cattlePrice: map['cattlePrice'].toDouble() ?? 0.0,
        cattleDate: DateTime.parse(map['cattleDate'])
      );
}
class FamilyMilkModel {
// variables para almacenar la información de la familia
  final String familyId;
  final String familyName;

// Constructor
  FamilyMilkModel({
    required this.familyId,
    required this.familyName,
  });

// convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'familyName': familyName,
    };
  }

// Crear un FamilyMilkModel a partir de un Map
  factory FamilyMilkModel.fromMap(Map<String, dynamic> map) => FamilyMilkModel(
        familyId: map['familyId'] ?? '',
        familyName: map['familyName'] ?? '',
      );
}

class UserModel {

// variables para almacenar la información del usuario
  final String userId;
  final String userName;
  final String userEmail;

// Constructor
  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

// convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
    };
  }

// Crear un UserModel a partir de un Map
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
  );
}


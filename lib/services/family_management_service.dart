import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milk_app/models/family_milk_model.dart';

class FamilyService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// Método para obtener las familias del usuario
  Stream<List<FamilyMilkModel>> getFamily(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FamilyMilkModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addFamily(String userId, FamilyMilkModel family) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(family.familyId)
        .set(family.toMap());
  }

  Future<void> editFamily(String userId, FamilyMilkModel family) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(family.familyId)
        .update(family.toMap()); 
  }

  Future<void> deleteFamily(String userId, String familyId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .delete();
  }

  Future<List<FamilyMilkModel>> getFamiliesOnce(String userId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('families')
      .get();

  return snapshot.docs.map((doc) => FamilyMilkModel.fromMap(doc.data())).toList();
}

}

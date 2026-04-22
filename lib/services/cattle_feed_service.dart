import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milk_app/models/cattle_feed_model.dart';

class CattleFeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener registros de leche de una familia específica
  Stream<List<CattleFeedModel>> getCattleFeed(String userId, String familyId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('cattleFeed')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CattleFeedModel.fromMap(doc.data()))
            .toList());
  }

  // Agregar un registro a una familia
  Future<void> addCattleFeed(String userId, String familyId, CattleFeedModel record) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('cattleFeed')
        .doc(record.cattleId)
        .set(record.toMap());
  }

  // Actualizar un registro existente en una familia
  Future<void> updateCattleFeed(String userId, String familyId, CattleFeedModel record) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('cattleFeed')
        .doc(record.cattleId)
        .update(record.toMap());
  }

  // Eliminar un registro de una familia
  Future<void> deleteCattleFeed(String userId, String familyId, String cattleId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('cattleFeed')
        .doc(cattleId)
        .delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milk_app/models/milk_record_model.dart';

class MilkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener registros de leche de una familia específica
  Stream<List<MilkRecordModel>> getMilkRecords(String userId, String familyId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('milkRecords')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MilkRecordModel.fromMap(doc.data())).toList());
  }

  // Agregar un registro a una familia
  Future<void> addMilkRecord(String userId, String familyId, MilkRecordModel record) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('milkRecords')
        .doc(record.milkId)
        .set(record.toMap());
  }

  // Actualizar un registro existente en una familia
  Future<void> updateMilkRecord(String userId, String familyId, MilkRecordModel record) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('milkRecords')
        .doc(record.milkId)
        .update(record.toMap());
  }

  // Eliminar un registro de una familia
  Future<void> deleteMilkRecord(String userId, String familyId, String milkId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('milkRecords')
        .doc(milkId)
        .delete();
  }

  
}
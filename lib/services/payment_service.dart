import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milk_app/models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PaymentModel>> getPayments(String userId, String familyId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PaymentModel.fromMap(d.data())).toList());
  }

  Future<void> addPayment(
      String userId, String familyId, PaymentModel payment) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('payments')
        .doc(payment.paymentId)
        .set(payment.toMap());
  }

  Future<void> deletePayment(
      String userId, String familyId, String paymentId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('families')
        .doc(familyId)
        .collection('payments')
        .doc(paymentId)
        .delete();
  }
}
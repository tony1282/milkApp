import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:milk_app/models/user_model.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<UserModel?> signInWithGoogle() async {
    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final OAuthCredential credential =
        GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) return null;

      final userModel = UserModel(
        userId: user.uid,
        userName: user.displayName ?? '',
        userEmail: user.email ?? '',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap(), SetOptions(merge: true));
          return userModel;

  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }


}
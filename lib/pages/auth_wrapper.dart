import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/pages/login_page.dart';

import 'home_page.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override 
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {

      if( snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center (
            child: CircularProgressIndicator(),
          ),
        );
      }


      if (snapshot.hasData) {
        return const HomePage();
      }
        
      return LoginPage();
      


      },
    );
  }
}
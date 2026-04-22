import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'pages/auth_wrapper.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  await GoogleSignIn.instance.initialize(
  serverClientId: '595926242490-77c12bk3ul8cdhvmeaq49m5qkb6au4kf.apps.googleusercontent.com',
);


  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales:  const [
        Locale('en', ''),
        Locale('zh', ''),
        Locale('he', ''),
        Locale('es', ''),
        Locale('ru', ''),
        Locale('ko', ''),
        Locale('hi', ''),
      ],
      home: const AuthWrapper(),

    );
  }
}


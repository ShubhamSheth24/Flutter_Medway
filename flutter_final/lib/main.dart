import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/Screens/checkout_screen.dart';
import 'package:flutter_final/pharmacy.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_final/signup.dart';
import 'package:flutter_final/Screens/welcome_screen.dart';
import 'package:flutter_final/maps.dart';
import 'package:provider/provider.dart';
import 'cart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyC3ZTxN5FbvDigGHIsu6mxmnUCpO6Fv1Wo",
        authDomain: "final-fdbdf.firebaseapp.com",
        projectId: "final-fdbdf",
        storageBucket: "final-fdbdf.firebasestorage.app",
        messagingSenderId: "303329458389",
        appId: "1:303329458389:web:ddca75e80fa3b42d904a5c",
        measurementId: "G-CFWM391TRV",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()),
      ],
      child: MaterialApp(title: 'Sign Up App', home: WelcomeScreen()),
    );
  }
}

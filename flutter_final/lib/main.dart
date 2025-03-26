import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/Screens/checkout_screen.dart';
import 'package:flutter_final/models/qr_state.dart';
import 'package:flutter_final/models/report_filter_state';
import 'package:flutter_final/pharmacy.dart';
import 'package:flutter_final/signup.dart';
import 'package:flutter_final/Screens/welcome_screen.dart';
import 'package:flutter_final/maps.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/cart.dart';
import 'package:flutter_final/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/home_page.dart'; // Import HomePage


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeUserData(User user, UserModel userModel) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        userModel.updateProfileImage(doc['profileImageUrl'] ?? '');
        userModel.updateName(doc['name'] ?? 'User');
        userModel.setRole(doc['role'] ?? 'Patient');
      } else {
        // If no document exists, set defaults (optional)
        userModel.updateName('User');
        userModel.setRole('Patient');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      // Fallback defaults in case of error
      userModel.updateName('User');
      userModel.setRole('Patient');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(create: (_) => QRState()),
        ChangeNotifierProvider(
            create: (_) => ReportFilterState()), // Added this
      ],
      child: MaterialApp(
        title: 'Sign Up App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = snapshot.data;
            if (user != null) {
              // User is signed in, fetch data and go to HomePage
              final userModel = Provider.of<UserModel>(context, listen: false);
              return FutureBuilder<void>(
                future: _initializeUserData(user, userModel),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (futureSnapshot.hasError) {
                    if (kDebugMode) {
                      print('Error in future: ${futureSnapshot.error}');
                    }
                    // Fallback to WelcomeScreen on error
                    return const WelcomeScreen();
                  }
                  return HomePage(userName: userModel.name ?? 'User');
                },
              );
            }
            // No user signed in, show WelcomeScreen
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}

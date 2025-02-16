// import 'package:flutter/material.dart';
// import 'package:flutter_final/signup.dart';
// import 'package:flutter_final/home_page.dart'; // Replace with the actual page you want to navigate to

// class SignIn extends StatefulWidget {
//   const SignIn({super.key});

//   @override
//   _SignInState createState() => _SignInState();
// }

// class _SignInState extends State<SignIn> {
//   bool passwordVisible = false;
//   String email = '';
//   String password = '';

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   void handleSubmit() {
//     if (_formKey.currentState!.validate()) {
//       print('Sign In Successful!');
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()), // Replace 'YourNextPage' with your actual page
//       );
//     } else {
//       print("Please correct the errors in the form.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 50),
//               // Header
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   icon: const Icon(Icons.chevron_left, size: 30),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Sign In',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),

//               // Email Input
//               TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Enter your email',
//                   prefixIcon: const Icon(Icons.email, color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Email is required';
//                   } else if (!value.contains('@') || !value.endsWith('.com')) {
//                     return 'Enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Password Input
//               TextFormField(
//                 obscureText: !passwordVisible,
//                 decoration: InputDecoration(
//                   labelText: 'Enter your password',
//                   prefixIcon: const Icon(Icons.lock, color: Colors.grey),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       passwordVisible ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         passwordVisible = !passwordVisible;
//                       });
//                     },
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Password is required';
//                   } else if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),

//               // Forgot Password
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     print('Forgot Password clicked');
//                   },
//                   child: const Text(
//                     'Forgot password?',
//                     style: TextStyle(color: Color(0xFF407CE2)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Sign In Button
//               ElevatedButton(
//                 onPressed: handleSubmit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF407CE2),
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text(
//                   'Sign In',
//                   style: TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // Sign Up Link
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Don\'t have an account? ',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).push(
//                           MaterialPageRoute(builder: (context) => SignUp()));
//                     },
//                     child: const Text(
//                       'Sign up',
//                       style: TextStyle(
//                         color: Color(0xFF407CE2),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // Separator
//               const Row(
//                 children: [
//                   Expanded(child: Divider(color: Colors.grey)),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10.0),
//                     child: Text('OR', style: TextStyle(color: Colors.grey)),
//                   ),
//                   Expanded(child: Divider(color: Colors.grey)),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // Google Sign In
//               // ElevatedButton.icon(
//               //   onPressed: () => print('Google Sign In clicked'),
//               //   label: Row(
//               //     mainAxisAlignment: MainAxisAlignment.center,
//               //     children: [
//               //       Image.asset("assets/google.png", height: 20),
//               //       const Text('Sign in with Google'),
//               //     ],
//               //   ),
//               //   style: ElevatedButton.styleFrom(
//               //     backgroundColor: Colors.white,
//               //     foregroundColor: Colors.black,
//               //     side: const BorderSide(color: Colors.grey),
//               //     shape: RoundedRectangleBorder(
//               //       borderRadius: BorderRadius.circular(30),
//               //     ),
//               //     padding: const EdgeInsets.symmetric(vertical: 12),
//               //   ),
//               // ),
//               const SizedBox(height: 10),

//               // Facebook Sign In
//               // ElevatedButton.icon(
//               //   onPressed: () => print('Facebook Sign In clicked'),
//               //   icon: Image.asset('assets/facebook.png', height: 20),
//               //   label: const Text('Sign in with Facebook'),
//               //   style: ElevatedButton.styleFrom(
//               //     backgroundColor: Colors.white,
//               //     foregroundColor: Colors.black,
//               //     side: const BorderSide(color: Colors.grey),
//               //     shape: RoundedRectangleBorder(
//               //       borderRadius: BorderRadius.circular(30),
//               //     ),
//               //     padding: const EdgeInsets.symmetric(vertical: 12),
//               //   ),
//               // ),

//               const Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_final/signup.dart';
import 'package:flutter_final/home_page.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool passwordVisible = false;
  String email = '';
  String password = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      print('Sign In Successful!');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print("Please correct the errors in the form.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email is required';
                    } else if (!value.contains('@') || !value.endsWith('.com')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      print('Forgot Password clicked');
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Color(0xFF407CE2)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF407CE2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF407CE2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/7123025_logo_google_g_icon.png", height: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

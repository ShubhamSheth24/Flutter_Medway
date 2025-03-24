import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/signup.dart'; // Adjust path
import 'package:flutter_final/home_page.dart'; // Adjust path
import 'package:flutter_final/Services/forgot_password.dart'; // Adjust path

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  bool passwordVisible = false;
  String email = '';
  String password = '';
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String userName = '';
        String? userRole;
        if (userDoc.exists) {
          userName = userDoc['name'] ?? "No Name";
          userRole = userDoc['role'] ?? "Patient";
        } else {
          userName = user.displayName ?? "No Name";
          userRole = "Patient"; // Default role
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': userName,
            'email': user.email ?? "No Email",
            'role': userRole,
          }, SetOptions(merge: true));
        }

        Provider.of<UserModel>(context, listen: false)
            .setUser(userName, user.email ?? "No Email", userRole);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userName: userName)),
        );
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In Error: $e"),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      print("Starting email/password sign-in with email: $email");

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        User? user = userCredential.user;

        print("User signed in successfully: ${user?.uid}");

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          String userName = "No Name";
          String? userRole;
          if (userDoc.exists) {
            userName = userDoc['name'] ?? "No Name";
            userRole = userDoc['role'] ?? "Patient";
            print("User data found in Firestore: $userName, Role: $userRole");
          } else {
            print("No user data found in Firestore, creating new entry");
            userRole = "Patient"; // Default role
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'name': userName,
              'email': email,
              'role': userRole,
            }, SetOptions(merge: true));
          }

          Provider.of<UserModel>(context, listen: false)
              .setUser(userName, email, userRole);

          if (!mounted) return;
          print("Navigating to HomePage with userName: $userName");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userName: userName)),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Sign-in failed";
        if (e.code == 'user-not-found') {
          errorMessage = "No user found with this email";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password";
        }
        print("Sign-In Error: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        print("Unexpected Sign-In Error: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 30, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    centerTitle: true,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  prefixIcon: Icons.email,
                  labelText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email is required';
                    } else if (!value.contains('@') ||
                        !value.endsWith('.com')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() => email = value),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  prefixIcon: Icons.lock,
                  labelText: 'Enter your password',
                  obscureText: !passwordVisible,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() => password = value),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => passwordVisible = !passwordVisible),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      print("Forgot Password clicked");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPassword()),
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Color(0xFF407CE2),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF407CE2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const SignUp()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF407CE2),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('OR',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/7123025_logo_google_g_icon.png",
                            height: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData prefixIcon,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF407CE2), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
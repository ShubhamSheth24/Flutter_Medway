import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_final/sigin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool passwordVisible = false;
  bool isAgreed = false;
  String email = "";
  String password = "";
  String emailError = "";
  String passwordError = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void validateEmail() {
    setState(() {
      if (email.isEmpty) {
        emailError = "Email is required";
      } else if (!email.contains('@')) {
        emailError = "Email must contain '@'";
      } else if (!email.endsWith('.com')) {
        emailError = "Email must end with '.com'";
      } else {
        emailError = "";
      }
    });
  }

  void validatePassword() {
    setState(() {
      if (password.isEmpty) {
        passwordError = "Password is required";
      } else if (password.length < 6) {
        passwordError = "Password must be at least 6 characters";
      } else {
        passwordError = "";
      }
    });
  }

  void handleSubmit() {
    validateEmail();
    validatePassword();

    if (emailError.isEmpty && passwordError.isEmpty && isAgreed) {
      print("Sign Up Successful!");
    } else {
      if (!isAgreed) {
        print("You must agree to the terms and conditions");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Form Container
            const SizedBox(height: 30),
            Column(
              children: [
                // Name Input
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: "Enter your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (text) => setState(() => email = text),
                  onEditingComplete:
                      validateEmail, // Use onEditingComplete instead of onBlur
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: "Enter your email",
                    errorText: emailError.isEmpty ? null : emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  onChanged: (text) => setState(() => password = text),
                  onEditingComplete:
                      validatePassword, // Use onEditingComplete instead of onBlur
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: "Enter your password",
                    errorText: passwordError.isEmpty ? null : passwordError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Checkbox and Terms
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAgreed = !isAgreed;
                        });
                      },
                      child: Icon(
                        isAgreed
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isAgreed ? const Color(0xFF407CE2) : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        "I agree to the "
                        "Healthcare Terms of Service\nand Privacy Policy",
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF407CE2),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Sign Up Button
                GestureDetector(
                  onTap: handleSubmit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF407CE2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Footer with Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SignIn()));
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                            color: Color(0xFF407CE2),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignUp(),
    routes: {
      '/signIn': (context) =>
          SignInPage(), // Implement your SignInPage widget here.
    },
  ));
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: const Center(child: Text('Sign In Page')),
    );
  }
}

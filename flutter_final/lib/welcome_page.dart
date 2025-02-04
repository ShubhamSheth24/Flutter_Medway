import 'package:flutter/material.dart';
import 'package:flutter_final/sigin.dart';
import 'package:flutter_final/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Icon(
              Icons.health_and_safety,
              color: Colors.blue,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Healthcare",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Let’s get started!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Login to Stay healthy and fit",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            // Use Column to stack buttons vertically
            Column(
              children: [
                SizedBox(
                  width: 250, // Set the width to make buttons same size
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SignIn()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space between buttons
                SizedBox(
                  width: 250, // Set the width to make buttons same size
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SignUp()));
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

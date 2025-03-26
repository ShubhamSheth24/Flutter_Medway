import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/models/qr_state.dart'; // Adjust the import path if needed

class QRCodeGenerator extends StatefulWidget {
  final String userId;

  const QRCodeGenerator({super.key, required this.userId});

  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  Timer? _timer; // Timer to update the UI every second

  @override
  void initState() {
    super.initState();
    // Start a timer to refresh the UI every second for remaining time updates
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Trigger rebuild to update remaining time
      }
    });
    _validateUserRole(); // Validate that the user is a patient
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer
    super.dispose();
  }

  // Validate that the user is a patient before generating QR
  Future<void> _validateUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != widget.userId) {
      _showSnackBar('Please sign in to generate a QR code', Colors.red);
      if (mounted) Navigator.pop(context);
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (!userDoc.exists || userDoc['role'] != 'Patient') {
      _showSnackBar('Only patients can generate QR codes', Colors.red);
      if (mounted) Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QRState>(
      builder: (context, qrState, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.blueGrey[900],
            title: const Text(
              'Generate QR Code',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            color: Colors.grey[100],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Patient QR Code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Generate a secure QR code to link with your caretaker.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: qrState.qrData != null
                          ? QrImageView(
                              data: qrState.qrData!,
                              version: QrVersions.auto,
                              size: 250.0,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.blueGrey,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.blueGrey,
                              ),
                            )
                          : const Icon(
                              Icons.qr_code_2,
                              size: 250,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Time Remaining: ${qrState.getRemainingTime()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: qrState.isButtonEnabled
                          ? () => qrState.generateQR(widget.userId)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: qrState.isButtonEnabled
                            ? Colors.blueGrey[700]
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: qrState.isButtonEnabled ? 5 : 0,
                      ),
                      child: const Text(
                        'Generate QR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      qrState.isButtonEnabled
                          ? 'This QR code is valid for 5 minutes only.'
                          : 'New QR available after expiry.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

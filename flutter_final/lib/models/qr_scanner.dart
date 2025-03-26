import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  Future<void> _linkAccounts(String scannedUid) async {
    final caretakerUid = FirebaseAuth.instance.currentUser?.uid;
    if (caretakerUid == null) {
      _showSnackBar('Please sign in as a caretaker', Colors.red);
      return;
    }

    if (caretakerUid == scannedUid) {
      _showSnackBar('You cannot link to yourself', Colors.red);
      return;
    }

    try {
      // Fetch patient document to validate
      final patientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(scannedUid)
          .get();

      if (!patientDoc.exists) {
        _showSnackBar('Invalid patient UID', Colors.red);
        return;
      }

      if (patientDoc['role'] != 'Patient') {
        _showSnackBar('Scanned UID is not a patient', Colors.red);
        return;
      }

      if (patientDoc['linkedUid'] != null) {
        _showSnackBar(
            'This patient is already linked to another caretaker', Colors.red);
        return;
      }

      // Fetch caretaker document to ensure they are a caretaker
      final caretakerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(caretakerUid)
          .get();

      if (!caretakerDoc.exists || caretakerDoc['role'] != 'Caretaker') {
        _showSnackBar('You must be a caretaker to link patients', Colors.red);
        return;
      }

      // Perform the linking in a batch to ensure atomicity
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update patient’s linkedUid to point to the caretaker
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(scannedUid).update(),
       
      );

      // Add patient UID to caretaker’s patients array
      batch.set(
        FirebaseFirestore.instance.collection('users').doc(caretakerUid),
        {
          'patients': FieldValue.arrayUnion([scannedUid])
        },
        SetOptions(merge: true),
      );

      // Commit the batch
      await batch.commit();

      if (mounted) {
        Navigator.pop(context); // Return to ProfilePage
        _showSnackBar(
            'Linked successfully with patient UID: $scannedUid', Colors.teal);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error linking accounts: $e', Colors.red);
      }
    } finally {
      setState(() => _isScanning = true); // Re-enable scanning if needed
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
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              if (_isScanning) {
                final String? scannedUid = capture.barcodes.first.rawValue;
                if (scannedUid != null) {
                  setState(() => _isScanning = false);
                  _linkAccounts(scannedUid);
                }
              }
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.teal.withOpacity(0.3),
                  Colors.teal.withOpacity(0.1),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: Colors.black.withOpacity(0.2)),
                    const Icon(Icons.qr_code_scanner,
                        size: 50, color: Colors.teal),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Align the QR code within the frame',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => cameraController.toggleTorch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Toggle Flash'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

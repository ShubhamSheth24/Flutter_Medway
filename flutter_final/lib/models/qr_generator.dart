// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class QRCodeGenerator extends StatelessWidget {
//   final String userId;

//   const QRCodeGenerator({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.purple,
//         title: const Text(
//           'Generate QR Code',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.purple.shade50, Colors.white],
//           ),
//         ),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Your QR Code',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.purple,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.purple.withOpacity(0.2),
//                         spreadRadius: 2,
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: QrImageView(
//                     data: userId,
//                     version: QrVersions.auto,
//                     size: 250.0,
//                     backgroundColor: Colors.white,
//                     eyeStyle: const QrEyeStyle(
//                       eyeShape: QrEyeShape.circle,
//                       color: Colors.purple,
//                     ),
//                     dataModuleStyle: const QrDataModuleStyle(
//                       dataModuleShape: QrDataModuleShape.circle,
//                       color: Colors.purple,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Scan this QR code to link accounts',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('QR Code Generated!'),
//                         backgroundColor: Colors.purple,
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.check_circle, color: Colors.white),
//                   label: const Text('Done'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/models/qr_state.dart'; // Adjust the import path

class QRCodeGenerator extends StatefulWidget {
  final String userId;

  const QRCodeGenerator({super.key, required this.userId});

  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
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

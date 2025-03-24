// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_final/models/user_model.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';
// import 'package:provider/provider.dart';
// import 'package:flutter_final/models/qr_generator.dart';
// import 'package:flutter_final/models/qr_scanner.dart';
// import 'Screens/appointment_page.dart';
// import 'payment_method_page.dart';
// import 'faqs_page.dart';
// import 'Services/logout_page.dart';

// class ProfilePage extends StatefulWidget {
//   final String userName;
//   const ProfilePage({super.key, required this.userName});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage>
//     with SingleTickerProviderStateMixin {
//   File? _selectedImage;
//   bool _isLoading = false;
//   String? _userEmail;
//   String? _linkedUid;
//   final ImagePicker _picker = ImagePicker();

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     print("ProfilePage initState started");

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation =
//         CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     print("ProfilePage dispose called");
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to upload an image'),
//           backgroundColor: Colors.red.withOpacity(0.8),
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//       return;
//     }

//     final permissionStatus = await Permission.photos.request();
//     if (permissionStatus.isGranted) {
//       try {
//         final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//         if (pickedFile != null) {
//           setState(() => _selectedImage = File(pickedFile.path));
//           await _uploadImage();
//         } else {
//           print("No image selected");
//         }
//       } catch (e) {
//         print("Error picking image: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error picking image: $e'),
//             backgroundColor: Colors.red.withOpacity(0.8),
//             behavior: SnackBarBehavior.floating,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         );
//       }
//     } else {
//       print("Gallery permission denied");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Gallery permission denied'),
//           backgroundColor: Colors.red.withOpacity(0.8),
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_selectedImage == null) {
//       print("No image to upload");
//       return;
//     }

//     setState(() => _isLoading = true);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception('User not authenticated. Please sign in.');
//       }

//       print("Uploading image for user: ${user.uid}");
//       final storageRef = FirebaseStorage.instance.ref().child(
//           'profile_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
//       final uploadTask = storageRef.putFile(_selectedImage!);
//       final snapshot = await uploadTask;
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       print("Image uploaded. Download URL: $downloadUrl");

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));
//       print("Firestore updated with profileImageUrl: $downloadUrl");

//       final userModel = Provider.of<UserModel>(context, listen: false);
//       userModel.updateProfileImage(downloadUrl);
//       print("UserModel updated with new image URL");

//       setState(() {
//         _selectedImage = null;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Profile image uploaded successfully!'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     } catch (e) {
//       print("Error uploading image: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error uploading image: $e'),
//           backgroundColor: Colors.red.withOpacity(0.8),
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final userModel = Provider.of<UserModel>(context);
//     final isPatient = userModel.role == 'Patient';
//     final isCaretaker = userModel.role == 'Caretaker';

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: user == null
//           ? const Center(child: Text('Please sign in to view your profile'))
//           : StreamBuilder<DocumentSnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(user.uid)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   return const Center(
//                       child: Text('Profile data not found.'));
//                 }

//                 final data = snapshot.data!.data() as Map<String, dynamic>;
//                 _userEmail = user.email ?? 'No email available';
//                 _linkedUid = data['linkedUid'];
//                 final profileImageUrl = data['profileImageUrl'] as String?;

//                 // Update UserModel if different from Firestore
//                 if (profileImageUrl != null &&
//                     profileImageUrl != userModel.profileImageUrl) {
//                   userModel.updateProfileImage(profileImageUrl);
//                 }

//                 return SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
//                     child: Column(
//                       children: [
//                         Center(
//                           child: Column(
//                             children: [
//                               Stack(
//                                 alignment: Alignment.bottomRight,
//                                 children: [
//                                   FadeTransition(
//                                     opacity: _fadeAnimation,
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                             color: Colors.blueAccent
//                                                 .withOpacity(0.5),
//                                             width: 2),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color:
//                                                 Colors.grey.withOpacity(0.2),
//                                             spreadRadius: 2,
//                                             blurRadius: 6,
//                                             offset: const Offset(0, 2),
//                                           ),
//                                         ],
//                                       ),
//                                       child: CircleAvatar(
//                                         radius: 50,
//                                         backgroundImage: profileImageUrl != null
//                                             ? NetworkImage(profileImageUrl)
//                                             : const AssetImage(
//                                                     'assets/profile.jpg')
//                                                 as ImageProvider,
//                                         backgroundColor: Colors.grey[200],
//                                         onBackgroundImageError:
//                                             (exception, stackTrace) {
//                                           print(
//                                               "Error loading image: $exception");
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                   if (!_isLoading)
//                                     Positioned(
//                                       bottom: 0,
//                                       right: 0,
//                                       child: GestureDetector(
//                                         onTap: _pickImage,
//                                         child: CircleAvatar(
//                                           radius: 18,
//                                           backgroundColor: Colors.blueAccent,
//                                           child: const Icon(Icons.edit,
//                                               size: 20, color: Colors.white),
//                                         ),
//                                       ),
//                                     ),
//                                   if (_isLoading)
//                                     const Positioned(
//                                       bottom: 0,
//                                       right: 0,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.blueAccent,
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               FadeTransition(
//                                 opacity: _fadeAnimation,
//                                 child: Text(
//                                   widget.userName,
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               FadeTransition(
//                                 opacity: _fadeAnimation,
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       _userEmail ?? 'Loading...',
//                                       style: const TextStyle(
//                                           fontSize: 16, color: Colors.grey),
//                                     ),
//                                     if (_linkedUid != null) ...[
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         isPatient
//                                             ? 'Caretaker UID: $_linkedUid'
//                                             : 'Patient UID: $_linkedUid',
//                                         style: const TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.blueAccent),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   _buildHealthStat(
//                                       "Heart rate", "215bpm", Icons.favorite),
//                                   _buildHealthStat("Calories", "756cal",
//                                       Icons.local_fire_department),
//                                   _buildHealthStat(
//                                       "Weight", "103lbs", Icons.fitness_center),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                         _buildProfileOption(
//                           context,
//                           "Appointment",
//                           Icons.calendar_today,
//                           Colors.blueAccent,
//                           () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => AppointmentPage())),
//                         ),
//                         _buildProfileOption(
//                           context,
//                           "Payment Method",
//                           Icons.payment,
//                           Colors.green,
//                           () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => PaymentMethodPage())),
//                         ),
//                         _buildProfileOption(
//                           context,
//                           "FAQs",
//                           Icons.help_outline,
//                           Colors.orange,
//                           () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => FAQsPage())),
//                         ),
//                         if (isPatient)
//                           _buildProfileOption(
//                             context,
//                             "Generate QR Code",
//                             Icons.qr_code,
//                             Colors.purple,
//                             () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => QRCodeGenerator(
//                                         userId: FirebaseAuth
//                                             .instance.currentUser!.uid))),
//                           ),
//                         if (isCaretaker)
//                           _buildProfileOption(
//                             context,
//                             "Scan QR Code",
//                             Icons.qr_code_scanner,
//                             Colors.teal,
//                             () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         const QRCodeScanner())),
//                           ),
//                         _buildProfileOption(
//                           context,
//                           "Logout",
//                           Icons.exit_to_app,
//                           Colors.red,
//                           () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const LogoutPage())),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildHealthStat(String title, String value, IconData icon) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.blueAccent, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileOption(BuildContext context, String title, IconData icon,
//       Color color, VoidCallback onTap) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Card(
//         elevation: 2,
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         color: Colors.grey.shade50,
//         child: ListTile(
//           leading: Icon(icon, color: color, size: 24),
//           title: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           trailing:
//               const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_final/models/qr_generator.dart';
import 'package:flutter_final/models/qr_scanner.dart';
import 'Screens/appointment_page.dart';
import 'payment_method_page.dart';
import 'faqs_page.dart';
import 'Services/logout_page.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  const ProfilePage({super.key, required this.userName});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isLoading = false;
  String? _userEmail;
  String? _linkedUid;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print("ProfilePage initState started");

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    print("ProfilePage dispose called");
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to upload an image'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted) {
      try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() => _selectedImage = File(pickedFile.path));
          await _uploadImage();
        } else {
          print("No image selected");
        }
      } catch (e) {
        print("Error picking image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      print("Gallery permission denied");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gallery permission denied'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      print("No image to upload");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please sign in.');
      }

      print("Uploading image for user: ${user.uid}");
      final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded. Download URL: $downloadUrl");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));
      print("Firestore updated with profileImageUrl: $downloadUrl");

      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.updateProfileImage(downloadUrl);
      print("UserModel updated with new image URL");

      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile image uploaded successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userModel = Provider.of<UserModel>(context);

    // Ensure role is fetched and stable
    final isPatient = userModel.role == 'Patient';
    final isCaretaker = userModel.role == 'Caretaker';

    return Scaffold(
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: Text('Please sign in to view your profile'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Profile data not found.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                _userEmail = user.email ?? 'No email available';
                _linkedUid = data['linkedUid'];
                final profileImageUrl = data['profileImageUrl'] as String?;

                // Update UserModel if different from Firestore
                if (profileImageUrl != null &&
                    profileImageUrl != userModel.profileImageUrl) {
                  userModel.updateProfileImage(profileImageUrl);
                }
                // Ensure role is updated from Firestore if available
                if (data['role'] != null && data['role'] != userModel.role) {
                  userModel.updateRole(data['role']);
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    child: Column(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.blueAccent
                                                .withOpacity(0.5),
                                            width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: profileImageUrl != null
                                            ? NetworkImage(profileImageUrl)
                                            : const AssetImage(
                                                    'assets/profile.jpg')
                                                as ImageProvider,
                                        backgroundColor: Colors.grey[200],
                                        onBackgroundImageError:
                                            (exception, stackTrace) {
                                          print(
                                              "Error loading image: $exception");
                                        },
                                      ),
                                    ),
                                  ),
                                  if (!_isLoading)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.blueAccent,
                                          child: const Icon(Icons.edit,
                                              size: 20, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  if (_isLoading)
                                    const Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircularProgressIndicator(
                                        color: Colors.blueAccent,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  children: [
                                    Text(
                                      _userEmail ?? 'Loading...',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    if (_linkedUid != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        isPatient
                                            ? 'Caretaker UID: $_linkedUid'
                                            : 'Patient UID: $_linkedUid',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueAccent),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildHealthStat(
                                      "Heart rate", "215bpm", Icons.favorite),
                                  _buildHealthStat("Calories", "756cal",
                                      Icons.local_fire_department),
                                  _buildHealthStat(
                                      "Weight", "103lbs", Icons.fitness_center),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildProfileOption(
                          context,
                          "Appointment",
                          Icons.calendar_today,
                          Colors.blueAccent,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AppointmentPage())),
                        ),
                        _buildProfileOption(
                          context,
                          "Payment Method",
                          Icons.payment,
                          Colors.green,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentMethodPage())),
                        ),
                        _buildProfileOption(
                          context,
                          "FAQs",
                          Icons.help_outline,
                          Colors.orange,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FAQsPage())),
                        ),
                        if (isPatient) // Ensure this persists for patients
                          _buildProfileOption(
                            context,
                            "Generate QR Code",
                            Icons.qr_code,
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QRCodeGenerator(userId: user.uid),
                              ),
                            ),
                          ),
                        if (isCaretaker)
                          _buildProfileOption(
                            context,
                            "Scan QR Code",
                            Icons.qr_code_scanner,
                            Colors.teal,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const QRCodeScanner())),
                          ),
                        _buildProfileOption(
                          context,
                          "Logout",
                          Icons.exit_to_app,
                          Colors.red,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LogoutPage())),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHealthStat(String title, String value, IconData icon) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey.shade50,
        child: ListTile(
          leading: Icon(icon, color: color, size: 24),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}

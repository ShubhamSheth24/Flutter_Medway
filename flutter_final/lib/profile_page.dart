// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';
// import 'appointment_page.dart';
// import 'payment_method_page.dart';
// import 'faqs_page.dart';
// import 'Services/logout_page.dart';

// class ProfilePage extends StatefulWidget {
//   final String userName;
//   const ProfilePage({super.key, required this.userName});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
//   String? _profileImageUrl;
//   File? _selectedImage;
//   bool _isLoading = false;
//   String? _userEmail;
//   final ImagePicker _picker = ImagePicker();

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//     _loadUserData();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       debugPrint('Loading data for user: ${user.uid}');
//       try {
//         final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//         if (doc.exists) {
//           final data = doc.data();
//           if (data != null && data.containsKey('profileImageUrl')) {
//             setState(() {
//               _profileImageUrl = data['profileImageUrl'] as String?;
//             });
//           } else {
//             debugPrint('No profileImageUrl field found in document');
//           }
//         } else {
//           debugPrint('User document does not exist');
//         }
//         setState(() {
//           _userEmail = user.email ?? 'No email available';
//         });
//       } catch (e) {
//         debugPrint('Error loading user data: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading profile: $e')),
//         );
//       }
//     } else {
//       debugPrint('No user signed in');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please sign in to view profile data')),
//       );
//     }
//   }

//   Future<void> _pickImage() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to upload an image'),
//           backgroundColor: Colors.red.withOpacity(0.8),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//       return;
//     }

//     final permissionStatus = await Permission.photos.request();
//     if (permissionStatus.isGranted) {
//       try {
//         final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//         if (pickedFile != null) {
//           setState(() {
//             _selectedImage = File(pickedFile.path);
//           });
//           await _uploadImage();
//         }
//       } catch (e) {
//         debugPrint('Error picking image: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error picking image: $e'),
//             backgroundColor: Colors.red.withOpacity(0.8),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Gallery permission denied'),
//           backgroundColor: Colors.red.withOpacity(0.8),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_selectedImage == null) return;

//     setState(() => _isLoading = true);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception('User not authenticated. Please sign in.');
//       }
//       debugPrint('Uploading for user UID: ${user.uid}');

//       // Refresh auth token
//       final token = await user.getIdToken(true);
//       debugPrint('Auth token: $token');

//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
//       final uploadTask = storageRef.putFile(_selectedImage!);
//       final snapshot = await uploadTask.whenComplete(() => null);
//       final downloadUrl = await snapshot.ref.getDownloadURL();

//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'profileImageUrl': downloadUrl,
//       }, SetOptions(merge: true));

//       setState(() {
//         _profileImageUrl = downloadUrl;
//         _selectedImage = null;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Profile image uploaded successfully!'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     } catch (e) {
//       debugPrint("Error uploading image: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error uploading image: $e'),
//           backgroundColor: Colors.red.withOpacity(0.8),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
//           child: Column(
//             children: [
//               Center(
//                 child: Column(
//                   children: [
//                     Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: CircleAvatar(
//                             radius: 50,
//                             backgroundImage: _profileImageUrl != null
//                                 ? NetworkImage(_profileImageUrl!) as ImageProvider
//                                 : const AssetImage('assets/profile.jpg'),
//                             backgroundColor: Colors.grey[200],
//                           ),
//                         ),
//                         if (!_isLoading)
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: _pickImage,
//                               child: const CircleAvatar(
//                                 radius: 15,
//                                 backgroundColor: Color(0xFF407CE2),
//                                 child: Icon(Icons.edit, size: 15, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         if (_isLoading)
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: CircularProgressIndicator(
//                               color: const Color(0xFF407CE2),
//                               strokeWidth: 2,
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: Text(
//                         widget.userName,
//                         style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: Text(
//                         _userEmail ?? 'Loading...',
//                         style: const TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _buildHealthStat("Heart rate", "215bpm", Icons.favorite),
//                         _buildHealthStat("Calories", "756cal", Icons.local_fire_department),
//                         _buildHealthStat("Weight", "103lbs", Icons.fitness_center),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//               _buildProfileOption(context, "Appointment", Icons.calendar_today, Colors.blue, () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AppointmentPage()),
//                 );
//               }),
//               _buildProfileOption(context, "Payment Method", Icons.payment, Colors.green, () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => PaymentMethodPage()),
//                 );
//               }),
//               _buildProfileOption(context, "FAQs", Icons.help_outline, Colors.orange, () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => FAQsPage()),
//                 );
//               }),
//               _buildProfileOption(context, "Logout", Icons.exit_to_app, Colors.red, () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const LogoutPage()),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHealthStat(String title, String value, IconData icon) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.blue, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
//         child: ListTile(
//           leading: Icon(icon, color: color),
//           title: Text(title, style: const TextStyle(fontSize: 16)),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'appointment_page.dart';
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
  String? _profileImageUrl;
  File? _selectedImage;
  bool _isLoading = false;
  String? _userEmail;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _profileImageUrl = doc['profileImageUrl'] as String?;
            _userEmail = user.email ?? 'No email available';
          });
        } else {
          setState(() => _userEmail = user.email ?? 'No email available');
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view profile data')));
    }
  }

  Future<void> _pickImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Please sign in to upload an image'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
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
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error picking image: $e'),
              backgroundColor: Colors.red.withOpacity(0.8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Gallery permission denied'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null)
        throw Exception('User not authenticated. Please sign in.');

      final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));

      setState(() {
        _profileImageUrl = downloadUrl;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Profile image uploaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
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
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage('assets/profile.jpg')
                                    as ImageProvider,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        if (!_isLoading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Color(0xFF407CE2),
                                child: Icon(Icons.edit,
                                    size: 15, color: Colors.white),
                              ),
                            ),
                          ),
                        if (_isLoading)
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircularProgressIndicator(
                                  color: const Color(0xFF407CE2),
                                  strokeWidth: 2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(widget.userName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(_userEmail ?? 'Loading...',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey))),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHealthStat(
                            "Heart rate", "215bpm", Icons.favorite),
                        _buildHealthStat(
                            "Calories", "756cal", Icons.local_fire_department),
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
                  Colors.blue,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppointmentPage()))),
              _buildProfileOption(
                  context,
                  "Payment Method",
                  Icons.payment,
                  Colors.green,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentMethodPage()))),
              _buildProfileOption(
                  context,
                  "FAQs",
                  Icons.help_outline,
                  Colors.orange,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FAQsPage()))),
              _buildProfileOption(
                  context,
                  "Logout",
                  Icons.exit_to_app,
                  Colors.red,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LogoutPage()))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStat(String title, String value, IconData icon) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 32),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}

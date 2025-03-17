// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_final/models/reminder.dart';
// import 'package:intl/intl.dart';

// class NotificationsDashboard extends StatelessWidget {
//   const NotificationsDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return const Center(child: Text('Please log in to view the dashboard.'));
//     }
//     return _DashboardContent(user: user);
//   }
// }

// class _DashboardContent extends StatefulWidget {
//   final User user;

//   const _DashboardContent({required this.user});

//   @override
//   __DashboardContentState createState() => __DashboardContentState();
// }

// class __DashboardContentState extends State<_DashboardContent>
//     with SingleTickerProviderStateMixin {
//   String _filter = 'All';
//   bool _showDaily = true;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   String? _profileImageUrl;
//   String _weight = "Loading...";
//   String _bloodGroup = "Loading...";
//   String _userName = "User";

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation =
//         CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
//     _animationController.forward();
//     _loadUserData();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final profileDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.user.uid)
//           .get();
//       if (profileDoc.exists) {
//         setState(() {
//           _profileImageUrl = profileDoc['profileImageUrl'] as String?;
//           _userName = profileDoc['name'] ?? "User";
//         });
//       }

//       final healthDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.user.uid)
//           .collection('health_info')
//           .doc('data')
//           .get();
//       if (healthDoc.exists) {
//         setState(() {
//           _weight = healthDoc['weight'] ?? "103";
//           _bloodGroup = healthDoc['bloodGroup'] ?? "A+";
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error loading data: $e')));
//     }
//   }

//   Widget _buildFilterButton(String label) {
//     return GestureDetector(
//       onTap: () => setState(() => _filter = label),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: 100,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: _filter == label ? Colors.blueAccent : Colors.grey[200],
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: _filter == label
//               ? [
//                   BoxShadow(
//                       color: Colors.blueAccent.withOpacity(0.3), blurRadius: 5)
//                 ]
//               : [],
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: _filter == label ? Colors.white : Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildToggleSwitch() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.grey[200],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () => setState(() => _showDaily = true),
//             child: Container(
//               width: 100,
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: _showDaily ? Colors.blueAccent : Colors.grey[200],
//                 borderRadius:
//                     const BorderRadius.horizontal(left: Radius.circular(20)),
//               ),
//               child: Center(
//                 child: Text(
//                   'Daily',
//                   style: TextStyle(
//                     color: _showDaily ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => setState(() => _showDaily = false),
//             child: Container(
//               width: 100,
//               padding: const EdgeInsets.symmetric(vertical: 10), // Fixed here
//               decoration: BoxDecoration(
//                 color: !_showDaily ? Colors.blueAccent : Colors.grey[200],
//                 borderRadius:
//                     const BorderRadius.horizontal(right: Radius.circular(20)),
//               ),
//               child: Center(
//                 child: Text(
//                   'Weekly',
//                   style: TextStyle(
//                     color: !_showDaily ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final timeFrame = _showDaily
//         ? DateTime.now().subtract(const Duration(days: 1))
//         : DateTime.now().subtract(const Duration(days: 7));
//     final timestamp = Timestamp.fromDate(timeFrame);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         toolbarHeight: 56,
//         title: const Text(
//           'Medicine Dashboard',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blueAccent, Colors.lightBlueAccent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await _loadUserData();
//           setState(() {});
//           await Future.delayed(const Duration(milliseconds: 500));
//         },
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.grey.withOpacity(0.2), blurRadius: 5)
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 30,
//                           backgroundImage: _profileImageUrl != null
//                               ? NetworkImage(_profileImageUrl!)
//                               : const AssetImage('assets/profile.jpg')
//                                   as ImageProvider,
//                           backgroundColor: Colors.grey[200],
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Hello, $_userName!',
//                                 style: const TextStyle(
//                                     fontSize: 20, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.fitness_center,
//                                       size: 16, color: Colors.blueAccent),
//                                   const SizedBox(width: 4),
//                                   Text('Weight: $_weight lbs',
//                                       style: const TextStyle(
//                                           fontSize: 14, color: Colors.grey)),
//                                   const SizedBox(width: 16),
//                                   const Icon(Icons.bloodtype,
//                                       size: 16, color: Colors.redAccent),
//                                   const SizedBox(width: 4),
//                                   Text('Blood: $_bloodGroup',
//                                       style: const TextStyle(
//                                           fontSize: 14, color: Colors.grey)),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(child: _buildToggleSwitch()),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildFilterButton('All'),
//                       const SizedBox(width: 12),
//                       _buildFilterButton('Taken'),
//                       const SizedBox(width: 12),
//                       _buildFilterButton('Not Taken'),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     color: Colors.white,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Compliance Overview',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 10),
//                           StreamBuilder<QuerySnapshot>(
//                             stream: FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(widget.user.uid)
//                                 .collection('reminders')
//                                 .where('timestamp', isGreaterThan: timestamp)
//                                 .snapshots(),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const SizedBox.shrink();
//                               }
//                               if (!snapshot.hasData ||
//                                   snapshot.data!.docs.isEmpty) {
//                                 return const SizedBox.shrink();
//                               }
//                               final total = snapshot.data!.docs.length;
//                               final taken = snapshot.data!.docs
//                                   .where((doc) => doc['taken'] == true)
//                                   .length;
//                               final compliance = total > 0
//                                   ? (taken / total * 100).toStringAsFixed(1)
//                                   : '0';
//                               return Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '$compliance%',
//                                         style: const TextStyle(
//                                           fontSize: 32,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.blueAccent,
//                                         ),
//                                       ),
//                                       Text(
//                                         'Compliance Rate',
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey[600]),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '$taken/$total',
//                                         style: const TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green,
//                                         ),
//                                       ),
//                                       Text(
//                                         'Taken/Total',
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey[600]),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(widget.user.uid)
//                       .collection('reminders')
//                       .where('timestamp', isGreaterThan: timestamp)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.info_outline,
//                                 size: 80, color: Colors.grey[400]),
//                             const SizedBox(height: 16),
//                             Text(
//                               _showDaily
//                                   ? 'No reminders added today.'
//                                   : 'No reminders added in the past week.',
//                               style: TextStyle(
//                                   fontSize: 18, color: Colors.grey[600]),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     final reminders = snapshot.data!.docs.map((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       return Reminder(
//                         id: int.parse(doc.id),
//                         medicine: data['medicine'],
//                         dosage: data['dosage'],
//                         times: (data['times'] as List)
//                             .map((t) =>
//                                 TimeOfDay(hour: t['hour'], minute: t['minute']))
//                             .toList(),
//                         isDaily: data['isDaily'],
//                         timestamp: data['timestamp'] as Timestamp?,
//                       );
//                     }).toList();

//                     final filteredReminders = _filter == 'All'
//                         ? reminders
//                         : _filter == 'Taken'
//                             ? reminders.where((r) =>
//                                 snapshot.data!.docs.firstWhere((doc) =>
//                                     doc.id == r.id.toString())['taken'] ==
//                                 true)
//                             : reminders.where((r) =>
//                                 snapshot.data!.docs.firstWhere((doc) =>
//                                     doc.id == r.id.toString())['taken'] ==
//                                 false);

//                     final sortedReminders = filteredReminders.toList()
//                       ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

//                     return Column(
//                       children: sortedReminders.map((reminder) {
//                         final isTaken = snapshot.data!.docs.firstWhere((doc) =>
//                                     doc.id == reminder.id.toString())['taken']
//                                 as bool? ??
//                             false;
//                         final timestamp = reminder.timestamp?.toDate();
//                         final dateString = timestamp != null
//                             ? DateFormat('MMM d, h:mm a').format(timestamp)
//                             : 'N/A';

//                         return FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: GestureDetector(
//                             onTap: () => _showReminderDetails(
//                                 context, reminder, isTaken, dateString),
//                             child: Card(
//                               elevation: 5,
//                               margin: const EdgeInsets.symmetric(vertical: 8),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               color: Colors.white,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Row(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 25,
//                                       backgroundColor: isTaken
//                                           ? Colors.green[100]
//                                           : Colors.red[100],
//                                       child: Icon(
//                                         isTaken
//                                             ? Icons.check_circle
//                                             : Icons.warning,
//                                         color:
//                                             isTaken ? Colors.green : Colors.red,
//                                         size: 30,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             reminder.medicine,
//                                             style: const TextStyle(
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             '${reminder.dosage} • ${reminder.times.map((t) => t.format(context)).join(', ')}',
//                                             style: TextStyle(
//                                                 fontSize: 16,
//                                                 color: Colors.grey[700]),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             'Added: $dateString',
//                                             style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey[500]),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8, vertical: 4),
//                                             decoration: BoxDecoration(
//                                               color: isTaken
//                                                   ? Colors.green[50]
//                                                   : Colors.red[50],
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             child: Text(
//                                               isTaken ? 'Taken' : 'Not Taken',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: isTaken
//                                                     ? Colors.green
//                                                     : Colors.red,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showReminderDetails(BuildContext context, Reminder reminder,
//       bool isTaken, String dateString) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor:
//                         isTaken ? Colors.green[100] : Colors.red[100],
//                     child: Icon(
//                       isTaken ? Icons.check_circle : Icons.warning,
//                       color: isTaken ? Colors.green : Colors.red,
//                       size: 40,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       reminder.medicine,
//                       style: const TextStyle(
//                           fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text('Dosage: ${reminder.dosage}',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[800])),
//               const SizedBox(height: 8),
//               Text(
//                   'Times: ${reminder.times.map((t) => t.format(context)).join(', ')}',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[800])),
//               const SizedBox(height: 8),
//               Text('Frequency: ${reminder.isDaily ? 'Daily' : 'Weekly'}',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[800])),
//               const SizedBox(height: 8),
//               Text('Added: $dateString',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[800])),
//               const SizedBox(height: 8),
//               Text(
//                 'Status: ${isTaken ? 'Taken' : 'Not Taken'}',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: isTaken ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text('Close',
//                       style: TextStyle(fontSize: 16, color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/models/reminder.dart';
import 'package:intl/intl.dart';

class NotificationsDashboard extends StatelessWidget {
  const NotificationsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view the dashboard.'));
    }
    return _DashboardContent(user: user);
  }
}

class _DashboardContent extends StatefulWidget {
  final User user;

  const _DashboardContent({required this.user});

  @override
  __DashboardContentState createState() => __DashboardContentState();
}

class __DashboardContentState extends State<_DashboardContent>
    with SingleTickerProviderStateMixin {
  String _filter = 'All';
  bool _showDaily = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _profileImageUrl;
  String _weight = "Loading...";
  String _bloodGroup = "Loading...";
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      if (profileDoc.exists) {
        setState(() {
          _profileImageUrl = profileDoc['profileImageUrl'] as String?;
          _userName = profileDoc['name'] ?? "User";
        });
      }

      final healthDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('health_info')
          .doc('data')
          .get();
      if (healthDoc.exists) {
        setState(() {
          _weight = healthDoc['weight'] ?? "103";
          _bloodGroup = healthDoc['bloodGroup'] ?? "A+";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  Widget _buildFilterButton(String label) {
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 90, // Reduced from 100
        padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
        decoration: BoxDecoration(
          color: _filter == label ? Colors.blueAccent : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10), // Reduced from 12
          boxShadow: _filter == label
              ? [
                  BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3), blurRadius: 4)
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14, // Reduced from 16
              color: _filter == label ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Reduced from 12
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showDaily = true),
            child: Container(
              width: 90, // Reduced from 100
              padding:
                  const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
              decoration: BoxDecoration(
                color: _showDaily ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  'Daily',
                  style: TextStyle(
                    fontSize: 14, // Reduced from 16
                    color: _showDaily ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showDaily = false),
            child: Container(
              width: 90, // Reduced from 100
              padding:
                  const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
              decoration: BoxDecoration(
                color: !_showDaily ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  'Weekly',
                  style: TextStyle(
                    fontSize: 14, // Reduced from 16
                    color: !_showDaily ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFrame = _showDaily
        ? DateTime.now().subtract(const Duration(days: 1))
        : DateTime.now().subtract(const Duration(days: 7));
    final timestamp = Timestamp.fromDate(timeFrame);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 56, // Reduced from 60
        title: const Text(
          'Medicine Dashboard',
          style: TextStyle(
            fontSize: 22, // Reduced from 24
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Colors.white), // Reduced from 24
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced from 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(12), // Reduced from 16
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                          BorderRadius.circular(10), // Reduced from 12
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2), blurRadius: 4)
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36, // Reduced from 40
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/profile.jpg')
                                  as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 12), // Reduced from 16
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $_userName!',
                                style: const TextStyle(
                                  fontSize: 22, // Reduced from 24
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6), // Reduced from 8
                              Row(
                                children: [
                                  const Icon(Icons.fitness_center,
                                      size: 18,
                                      color:
                                          Colors.blueAccent), // Reduced from 20
                                  const SizedBox(width: 6), // Reduced from 8
                                  Text(
                                    'Weight: $_weight lbs',
                                    style: const TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12), // Reduced from 16
                                  const Icon(Icons.bloodtype,
                                      size: 18,
                                      color:
                                          Colors.redAccent), // Reduced from 20
                                  const SizedBox(width: 6), // Reduced from 8
                                  Text(
                                    'Blood: $_bloodGroup',
                                    style: const TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Reduced from 24
                Center(child: _buildToggleSwitch()),
                const SizedBox(height: 12), // Reduced from 16
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterButton('All'),
                      const SizedBox(width: 10), // Reduced from 12
                      _buildFilterButton('Taken'),
                      const SizedBox(width: 10), // Reduced from 12
                      _buildFilterButton('Not Taken'),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Reduced from 24
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)), // Reduced from 12
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12), // Reduced from 16
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Compliance Overview',
                            style: TextStyle(
                              fontSize: 18, // Reduced from 20
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8), // Reduced from 12
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.user.uid)
                                .collection('reminders')
                                .where('timestamp', isGreaterThan: timestamp)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final total = snapshot.data!.docs.length;
                              final taken = snapshot.data!.docs
                                  .where((doc) => doc['taken'] == true)
                                  .length;
                              final compliance = total > 0
                                  ? (taken / total * 100).toStringAsFixed(1)
                                  : '0';
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$compliance%',
                                        style: const TextStyle(
                                          fontSize: 28, // Reduced from 32
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const Text(
                                        'Compliance Rate',
                                        style: TextStyle(
                                          fontSize: 12, // Reduced from 14
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$taken/$total',
                                        style: const TextStyle(
                                          fontSize: 22, // Reduced from 24
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const Text(
                                        'Taken/Total',
                                        style: TextStyle(
                                          fontSize: 12, // Reduced from 14
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Reduced from 24
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.user.uid)
                      .collection('reminders')
                      .where('timestamp', isGreaterThan: timestamp)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 60,
                                color: Colors.grey[400]), // Reduced from 80
                            const SizedBox(height: 12), // Reduced from 16
                            Text(
                              _showDaily
                                  ? 'No reminders added today.'
                                  : 'No reminders added in the past week.',
                              style: const TextStyle(
                                fontSize: 14, // Reduced from 16
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final reminders = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Reminder(
                        id: int.parse(doc.id),
                        medicine: data['medicine'],
                        dosage: data['dosage'],
                        times: (data['times'] as List)
                            .map((t) =>
                                TimeOfDay(hour: t['hour'], minute: t['minute']))
                            .toList(),
                        isDaily: data['isDaily'],
                        timestamp: data['timestamp'] as Timestamp?,
                      );
                    }).toList();

                    final filteredReminders = _filter == 'All'
                        ? reminders
                        : _filter == 'Taken'
                            ? reminders.where((r) =>
                                snapshot.data!.docs.firstWhere((doc) =>
                                    doc.id == r.id.toString())['taken'] ==
                                true)
                            : reminders.where((r) =>
                                snapshot.data!.docs.firstWhere((doc) =>
                                    doc.id == r.id.toString())['taken'] ==
                                false);

                    final sortedReminders = filteredReminders.toList()
                      ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

                    return Column(
                      children: sortedReminders.map((reminder) {
                        final isTaken = snapshot.data!.docs.firstWhere((doc) =>
                                    doc.id == reminder.id.toString())['taken']
                                as bool? ??
                            false;
                        final timestamp = reminder.timestamp?.toDate();
                        final dateString = timestamp != null
                            ? DateFormat('MMM d, h:mm a').format(timestamp)
                            : 'N/A';

                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: GestureDetector(
                            onTap: () => _showReminderDetails(
                                context, reminder, isTaken, dateString),
                            child: Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6), // Reduced from 8
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10)), // Reduced from 12
                              color: Colors.grey.shade50,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(12), // Reduced from 16
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20, // Reduced from 24
                                      backgroundColor: isTaken
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      child: Icon(
                                        isTaken
                                            ? Icons.check_circle
                                            : Icons.warning,
                                        color:
                                            isTaken ? Colors.green : Colors.red,
                                        size: 24, // Reduced from 28
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 12), // Reduced from 16
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reminder.medicine,
                                            style: const TextStyle(
                                              fontSize: 18, // Reduced from 20
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 2), // Reduced from 4
                                          Text(
                                            '${reminder.dosage} • ${reminder.times.map((t) => t.format(context)).join(', ')}',
                                            style: const TextStyle(
                                              fontSize: 14, // Reduced from 16
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 2), // Reduced from 4
                                          Text(
                                            'Added: $dateString',
                                            style: const TextStyle(
                                              fontSize: 12, // Reduced from 14
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 6), // Reduced from 8
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical:
                                                    4), // Reduced from 12, 6
                                            decoration: BoxDecoration(
                                              color: isTaken
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      6), // Reduced from 8
                                            ),
                                            child: Text(
                                              isTaken ? 'Taken' : 'Not Taken',
                                              style: TextStyle(
                                                fontSize: 12, // Reduced from 14
                                                color: isTaken
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
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
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReminderDetails(BuildContext context, Reminder reminder,
      bool isTaken, String dateString) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)), // Reduced from 20
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12), // Reduced from 16
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26, // Reduced from 30
                    backgroundColor: isTaken
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    child: Icon(
                      isTaken ? Icons.check_circle : Icons.warning,
                      color: isTaken ? Colors.green : Colors.red,
                      size: 32, // Reduced from 36
                    ),
                  ),
                  const SizedBox(width: 12), // Reduced from 16
                  Expanded(
                    child: Text(
                      reminder.medicine,
                      style: const TextStyle(
                        fontSize: 22, // Reduced from 24
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Reduced from 16
              Text('Dosage: ${reminder.dosage}',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey)), // Reduced from 16
              const SizedBox(height: 6), // Reduced from 8
              Text(
                  'Times: ${reminder.times.map((t) => t.format(context)).join(', ')}',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey)), // Reduced from 16
              const SizedBox(height: 6), // Reduced from 8
              Text('Frequency: ${reminder.isDaily ? 'Daily' : 'Weekly'}',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey)), // Reduced from 16
              const SizedBox(height: 6), // Reduced from 8
              Text('Added: $dateString',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey)), // Reduced from 16
              const SizedBox(height: 6), // Reduced from 8
              Text(
                'Status: ${isTaken ? 'Taken' : 'Not Taken'}',
                style: TextStyle(
                  fontSize: 14, // Reduced from 16
                  color: isTaken ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20), // Reduced from 24
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14), // Reduced from 16
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)), // Reduced from 12
                    elevation: 2,
                  ),
                  child: const Text('Close',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white)), // Reduced from 16
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

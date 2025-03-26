// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import '../models/reminder.dart';
// import 'package:flutter_final/home_page.dart';

// class MedicineReminder extends StatefulWidget {
//   const MedicineReminder({super.key});

//   @override
//   _MedicineReminderState createState() => _MedicineReminderState();
// }

// class _MedicineReminderState extends State<MedicineReminder> {
//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   List<Reminder> _reminders = [];
//   final TextEditingController _medicineController = TextEditingController();
//   final TextEditingController _dosageController = TextEditingController();
//   List<TimeOfDay> _selectedTimes = [];
//   bool _isDaily = true;
//   Map<int, bool> _takenStatus = {};

//   @override
//   void initState() {
//     super.initState();
//     tz.initializeTimeZones();
//     _initializeNotifications();
//     _loadReminders();
//   }

//   Future<void> _initializeNotifications() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initSettings =
//         InitializationSettings(android: androidSettings);
//     await _notificationsPlugin.initialize(initSettings);
//   }

//   Future<void> _loadReminders() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('reminders')
//           .get();
//       setState(() {
//         _reminders = snapshot.docs.map((doc) {
//           final data = doc.data();
//           final reminder = Reminder(
//             id: int.parse(doc.id),
//             medicine: data['medicine'],
//             dosage: data['dosage'],
//             times: (data['times'] as List)
//                 .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
//                 .toList(),
//             isDaily: data['isDaily'],
//             timestamp: data['timestamp'],
//           );
//           _takenStatus[reminder.id] = data['taken'] ?? false;
//           return reminder;
//         }).toList();
//       });
//     }
//   }

//   Future<void> _saveReminder(Reminder reminder) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('reminders')
//           .doc(reminder.id.toString())
//           .set({
//         'medicine': reminder.medicine,
//         'dosage': reminder.dosage,
//         'times': reminder.times
//             .map((t) => {'hour': t.hour, 'minute': t.minute})
//             .toList(),
//         'isDaily': reminder.isDaily,
//         'taken': _takenStatus[reminder.id] ?? false,
//         'timestamp': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true)); // Use merge to preserve existing fields
//     }
//   }

//   Future<void> _deleteReminder(int id) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('reminders')
//           .doc(id.toString())
//           .delete();
//       await _notificationsPlugin.cancel(id);
//     }
//   }

//   Future<void> _scheduleNotification(Reminder reminder) async {
//     for (int i = 0; i < reminder.times.length; i++) {
//       final time = reminder.times[i];
//       final now = DateTime.now();
//       final scheduledDate =
//           DateTime(now.year, now.month, now.day, time.hour, time.minute)
//               .add(Duration(minutes: reminder.isDaily ? 0 : 1440));
//       await _notificationsPlugin.zonedSchedule(
//         reminder.id * 10 + i,
//         'Medicine Reminder: ${reminder.medicine}',
//         'Time to take ${reminder.dosage}',
//         tz.TZDateTime.from(scheduledDate, tz.local),
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'medicine_channel',
//             'Medicine Reminders',
//             channelDescription: 'Notifications for medicine reminders',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true,
//           ),
//         ),
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: reminder.isDaily
//             ? DateTimeComponents.time
//             : DateTimeComponents.dayOfWeekAndTime,
//       );
//     }
//   }

//   void _addReminder() {
//     if (_medicineController.text.isEmpty ||
//         _dosageController.text.isEmpty ||
//         _selectedTimes.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please fill all fields')));
//       return;
//     }

//     final reminder = Reminder(
//       id: _reminders.isEmpty ? 1 : _reminders.last.id + 1,
//       medicine: _medicineController.text,
//       dosage: _dosageController.text,
//       times: _selectedTimes,
//       isDaily: _isDaily,
//       timestamp: Timestamp.now(), // Set locally for immediate UI update
//     );

//     setState(() {
//       _reminders.add(reminder);
//       _takenStatus[reminder.id] = false;
//       _medicineController.clear();
//       _dosageController.clear();
//       _selectedTimes = [];
//       _isDaily = true;
//     });

//     _saveReminder(reminder);
//     _scheduleNotification(reminder);
//     Navigator.pop(context);
//   }

//   Future<void> _showAddReminderDialog() async {
//     await showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Text(
//             'Add Medicine Reminder',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _medicineController,
//                   decoration: InputDecoration(
//                     labelText: 'Medicine Name',
//                     labelStyle:
//                         const TextStyle(fontSize: 16, color: Colors.grey),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: Colors.grey.shade100,
//                   ),
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _dosageController,
//                   decoration: InputDecoration(
//                     labelText: 'Dosage (e.g., 1 pill)',
//                     labelStyle:
//                         const TextStyle(fontSize: 16, color: Colors.grey),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: Colors.grey.shade100,
//                   ),
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final time = await showTimePicker(
//                       context: context,
//                       initialTime: TimeOfDay.now(),
//                       builder: (context, child) => MediaQuery(
//                         data: MediaQuery.of(context)
//                             .copyWith(alwaysUse24HourFormat: false),
//                         child: child!,
//                       ),
//                     );
//                     if (time != null && !_selectedTimes.contains(time))
//                       setState(() => _selectedTimes.add(time));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 16, horizontal: 24),
//                     elevation: 2,
//                   ),
//                   child: const Text('Add Time',
//                       style: TextStyle(fontSize: 16, color: Colors.white)),
//                 ),
//                 const SizedBox(height: 12),
//                 Wrap(
//                   spacing: 8,
//                   children: _selectedTimes
//                       .map((time) => Chip(
//                             label: Text(time.format(context),
//                                 style: const TextStyle(fontSize: 14)),
//                             deleteIcon: const Icon(Icons.close, size: 18),
//                             onDeleted: () =>
//                                 setState(() => _selectedTimes.remove(time)),
//                             backgroundColor: Colors.blueAccent.withOpacity(0.1),
//                           ))
//                       .toList(),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Repeat Daily',
//                         style: TextStyle(fontSize: 16, color: Colors.black87)),
//                     Switch(
//                       value: _isDaily,
//                       onChanged: (value) => setState(() => _isDaily = value),
//                       activeColor: Colors.blueAccent,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel',
//                   style: TextStyle(fontSize: 16, color: Colors.grey)),
//             ),
//             ElevatedButton(
//               onPressed: _addReminder,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//                 elevation: 2,
//               ),
//               child: const Text('Save',
//                   style: TextStyle(fontSize: 16, color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> _onWillPop() async {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const HomePage(userName: '')),
//     );
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           toolbarHeight: 56,
//           title: const Text(
//             'Medicine Reminders',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blueAccent,
//           elevation: 0,
//           leading: IconButton(
//             icon:
//                 const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
//             onPressed: () {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                     builder: (context) => const HomePage(userName: '')),
//               );
//             },
//           ),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueAccent, Colors.lightBlueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: _reminders.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.medication_outlined,
//                           size: 80, color: Colors.grey[400]),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'No reminders set yet.\nTap + to add one!',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: _reminders.length,
//                   itemBuilder: (context, index) {
//                     final reminder = _reminders[index];
//                     return Card(
//                       elevation: 2,
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       color: Colors.grey.shade50,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Row(
//                           children: [
//                             Icon(Icons.medication,
//                                 size: 32, color: Colors.blueAccent),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     reminder.medicine,
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     '${reminder.dosage} • ${reminder.times.map((t) => t.format(context)).join(', ')}',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   Text(
//                                     '(${reminder.isDaily ? "Daily" : "Weekly"})',
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Checkbox(
//                                         value:
//                                             _takenStatus[reminder.id] ?? false,
//                                         onChanged: (bool? value) {
//                                           setState(() {
//                                             _takenStatus[reminder.id] =
//                                                 value ?? false;
//                                           });
//                                           _saveReminder(
//                                               reminder); // Save updated taken status
//                                         },
//                                         activeColor: Colors.green,
//                                       ),
//                                       const Text('Taken',
//                                           style: TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.black87)),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete,
//                                   color: Colors.red, size: 24),
//                               onPressed: () => setState(() {
//                                 _reminders.removeAt(index);
//                                 _takenStatus.remove(reminder.id);
//                                 _deleteReminder(reminder.id);
//                               }),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showAddReminderDialog,
//           backgroundColor: Colors.blueAccent,
//           child: const Icon(Icons.add, size: 28, color: Colors.white),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 2,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';
import 'package:flutter_final/home_page.dart';

class MedicineReminder extends StatefulWidget {
  const MedicineReminder({super.key});

  @override
  _MedicineReminderState createState() => _MedicineReminderState();
}

class _MedicineReminderState extends State<MedicineReminder> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Reminder> _reminders = [];
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  List<TimeOfDay> _selectedTimes = [];
  bool _isDaily = true;
  Map<int, bool> _takenStatus = {};
  String? _userRole; // "caretaker" or "patient"
  String? _linkedPatientId; // For caretakers only

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _checkUserRoleAndLoadReminders();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _checkUserRoleAndLoadReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userRole = userDoc['role'];
        if (_userRole == 'caretaker') {
          _linkedPatientId = userDoc['linkedPatientId'];
        }
      });
      _loadReminders();
    }
  }

  Future<void> _loadReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String collectionOwnerId =
          _userRole == 'caretaker' ? user.uid : (_linkedPatientId ?? user.uid);
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(collectionOwnerId)
          .collection('reminders')
          .get();
      setState(() {
        _reminders = snapshot.docs.map((doc) {
          final data = doc.data();
          final reminder = Reminder(
            id: int.parse(doc.id),
            medicine: data['medicine'],
            dosage: data['dosage'],
            times: (data['times'] as List)
                .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
                .toList(),
            isDaily: data['isDaily'],
            timestamp: data['timestamp'],
          );
          _takenStatus[reminder.id] = data['taken'] ?? false;
          return reminder;
        }).toList();
      });
    }
  }

  Future<void> _saveReminder(Reminder reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _userRole == 'caretaker' && _linkedPatientId != null) {
      // Save to caretaker's reminders
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(reminder.id.toString())
          .set({
        'medicine': reminder.medicine,
        'dosage': reminder.dosage,
        'times': reminder.times
            .map((t) => {'hour': t.hour, 'minute': t.minute})
            .toList(),
        'isDaily': reminder.isDaily,
        'taken': _takenStatus[reminder.id] ?? false,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sync to patient's reports
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_linkedPatientId)
          .collection('reports')
          .doc(reminder.id.toString())
          .set({
        'medicine': reminder.medicine,
        'dosage': reminder.dosage,
        'times': reminder.times
            .map((t) => {'hour': t.hour, 'minute': t.minute})
            .toList(),
        'isDaily': reminder.isDaily,
        'taken': _takenStatus[reminder.id] ?? false,
        'timestamp': FieldValue.serverTimestamp(),
        'addedBy': user.uid, // Track who added it
      }, SetOptions(merge: true));
    }
  }

  Future<void> _deleteReminder(int id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _userRole == 'caretaker' && _linkedPatientId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(id.toString())
          .delete();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_linkedPatientId)
          .collection('reports')
          .doc(id.toString())
          .delete();
      await _notificationsPlugin.cancel(id);
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    // Same as your original code
    for (int i = 0; i < reminder.times.length; i++) {
      final time = reminder.times[i];
      final now = DateTime.now();
      final scheduledDate =
          DateTime(now.year, now.month, now.day, time.hour, time.minute)
              .add(Duration(minutes: reminder.isDaily ? 0 : 1440));
      await _notificationsPlugin.zonedSchedule(
        reminder.id * 10 + i,
        'Medicine Reminder: ${reminder.medicine}',
        'Time to take ${reminder.dosage}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_channel',
            'Medicine Reminders',
            channelDescription: 'Notifications for medicine reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: reminder.isDaily
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  void _addReminder() {
    if (_medicineController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    if (_userRole != 'caretaker' || _linkedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Only caretakers with a linked patient can add reminders')));
      return;
    }

    final reminder = Reminder(
      id: _reminders.isEmpty ? 1 : _reminders.last.id + 1,
      medicine: _medicineController.text,
      dosage: _dosageController.text,
      times: _selectedTimes,
      isDaily: _isDaily,
      timestamp: Timestamp.now(),
    );

    setState(() {
      _reminders.add(reminder);
      _takenStatus[reminder.id] = false;
      _medicineController.clear();
      _dosageController.clear();
      _selectedTimes = [];
      _isDaily = true;
    });

    _saveReminder(reminder);
    _scheduleNotification(reminder);
    Navigator.pop(context);
  }

  Future<void> _showAddReminderDialog() async {
    if (_userRole != 'caretaker') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only caretakers can add reminders')));
      return;
    }
    if (_linkedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Link a patient first to add reminders')));
      return;
    }
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          // Same dialog content as your original code
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Medicine Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _medicineController,
                  decoration: InputDecoration(labelText: 'Medicine Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dosageController,
                  decoration:
                      InputDecoration(labelText: 'Dosage (e.g., 1 pill)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null && !_selectedTimes.contains(time))
                      setState(() => _selectedTimes.add(time));
                  },
                  child: const Text('Add Time'),
                ),
                Wrap(
                  children: _selectedTimes
                      .map((time) => Chip(
                            label: Text(time.format(context)),
                            onDeleted: () =>
                                setState(() => _selectedTimes.remove(time)),
                          ))
                      .toList(),
                ),
                Row(
                  children: [
                    const Text('Repeat Daily'),
                    Switch(
                      value: _isDaily,
                      onChanged: (value) => setState(() => _isDaily = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addReminder,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage(userName: '')),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medicine Reminders'),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const HomePage(userName: '')),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _reminders.isEmpty
              ? const Center(child: Text('No reminders set yet.'))
              : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.medication),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(reminder.medicine,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '${reminder.dosage} • ${reminder.times.map((t) => t.format(context)).join(', ')}'),
                                  Text(
                                      '(${reminder.isDaily ? "Daily" : "Weekly"})'),
                                  if (_userRole == 'caretaker')
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _takenStatus[reminder.id] ??
                                              false,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _takenStatus[reminder.id] =
                                                  value ?? false;
                                            });
                                            _saveReminder(reminder);
                                          },
                                        ),
                                        const Text('Taken'),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (_userRole == 'caretaker')
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() {
                                  _reminders.removeAt(index);
                                  _takenStatus.remove(reminder.id);
                                  _deleteReminder(reminder.id);
                                }),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        floatingActionButton: _userRole == 'caretaker'
            ? FloatingActionButton(
                onPressed: _showAddReminderDialog,
                child: const Icon(Icons.add),
              )
            : null, // Hide FAB for patients
      ),
    );
  }
}

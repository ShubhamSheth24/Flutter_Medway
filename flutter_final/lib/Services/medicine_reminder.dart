import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart'; // Updated import
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class MedicineReminder extends StatefulWidget {
  const MedicineReminder({super.key});

  @override
  _MedicineReminderState createState() => _MedicineReminderState();
}

class _MedicineReminderState extends State<MedicineReminder> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Telephony telephony = Telephony.instance;
  List<Reminder> _reminders = [];
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  List<TimeOfDay> _selectedTimes = [];
  bool _isDaily = true;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadReminders();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _loadReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .get();
      setState(() {
        _reminders = snapshot.docs.map((doc) {
          final data = doc.data();
          return Reminder(
            id: int.parse(doc.id),
            medicine: data['medicine'],
            dosage: data['dosage'],
            times: (data['times'] as List)
                .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
                .toList(),
            isDaily: data['isDaily'],
          );
        }).toList();
      });
    }
  }

  Future<void> _saveReminder(Reminder reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
      });
    }
  }

  Future<void> _deleteReminder(int id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(id.toString())
          .delete();
      await _notificationsPlugin.cancel(id);
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    for (int i = 0; i < reminder.times.length; i++) {
      final time = reminder.times[i];
      final now = DateTime.now();
      final scheduledDate =
          DateTime(now.year, now.month, now.day, time.hour, time.minute)
              .add(Duration(minutes: reminder.isDaily ? 0 : 1440));
      try {
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
              sound: RawResourceAndroidNotificationSound('custom_alert'),
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: reminder.isDaily
              ? DateTimeComponents.time
              : DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (e) {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Scheduled with default sound due to error: $e')));
      }
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

    final reminder = Reminder(
      id: _reminders.isEmpty ? 1 : _reminders.last.id + 1,
      medicine: _medicineController.text,
      dosage: _dosageController.text,
      times: _selectedTimes,
      isDaily: _isDaily,
    );

    setState(() {
      _reminders.add(reminder);
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
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medicine Reminder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _medicineController,
                    decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                        labelText: 'Dosage (e.g., 1 pill)',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: false),
                            child: child!));
                    if (time != null && !_selectedTimes.contains(time))
                      setState(() => _selectedTimes.add(time));
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20)),
                  child: const Text('Add Time', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    children: _selectedTimes
                        .map((time) => Chip(
                            label: Text(time.format(context),
                                style: const TextStyle(fontSize: 16)),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                setState(() => _selectedTimes.remove(time))))
                        .toList()),
                const SizedBox(height: 16),
                Row(children: [
                  const Text('Repeat Daily', style: TextStyle(fontSize: 18)),
                  Switch(
                      value: _isDaily,
                      onChanged: (value) => setState(() => _isDaily = value))
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 18))),
            ElevatedButton(
                onPressed: _addReminder,
                child: const Text('Save', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20))),
          ],
        ),
      ),
    );
  }

  Future<void> _showCaregiverAlertDialog(Reminder reminder) async {
    final TextEditingController phoneController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notify Caregiver', style: TextStyle(fontSize: 24)),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
              labelText: 'Caregiver Phone Number (e.g., +919876543210)',
              labelStyle: TextStyle(fontSize: 18),
              border: OutlineInputBorder()),
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 18))),
          ElevatedButton(
            onPressed: () async {
              String phoneNumber = phoneController.text.trim();
              if (phoneNumber.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter a phone number')));
                return;
              }
              if (!phoneNumber.startsWith('+')) phoneNumber = '+91$phoneNumber';
              String message =
                  "Reminder for ${reminder.medicine} at ${reminder.times.map((t) => t.format(context)).join(', ')}";

              if (Platform.isAndroid) {
                bool? permissionGranted = await telephony.requestSmsPermissions;
                if (permissionGranted == null || !permissionGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SMS permission denied')));
                  await openAppSettings();
                  return;
                }
                try {
                  await telephony.sendSms(to: phoneNumber, message: message);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SMS sent to caregiver!')));
                } catch (e) {
                  debugPrint('Error sending SMS: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sending SMS: $e')));
                }
              } else if (Platform.isIOS) {
                final Uri smsUri = Uri(
                    scheme: 'sms',  
                    path: phoneNumber,
                    queryParameters: {'body': message});
                if (await canLaunchUrl(smsUri)) {
                  await launchUrl(smsUri);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Opened Messages app for you to send the SMS')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Could not open Messages app')));
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Send SMS', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0).copyWith(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medicine Reminders',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: _reminders.isEmpty
                  ? const Center(
                      child: Text('No reminders set yet.\nTap + to add one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _reminders[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.medication,
                                size: 40, color: Colors.blue),
                            title: Text(reminder.medicine,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${reminder.dosage}\n${reminder.times.map((t) => t.format(context)).join(', ')} (${reminder.isDaily ? "Daily" : "Weekly"})',
                                style: const TextStyle(fontSize: 18)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.person_add,
                                        color: Colors.green),
                                    onPressed: () =>
                                        _showCaregiverAlertDialog(reminder),
                                    tooltip: 'Notify Caregiver'),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => setState(() => {
                                          _reminders.removeAt(index),
                                          _deleteReminder(reminder.id)
                                        }),
                                    tooltip: 'Delete Reminder'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddReminderDialog,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, size: 30),
          tooltip: 'Add Reminder',
          elevation: 6),
    );
  }
}

class Reminder {
  final int id;
  final String medicine;
  final String dosage;
  final List<TimeOfDay> times;
  final bool isDaily;

  Reminder(
      {required this.id,
      required this.medicine,
      required this.dosage,
      required this.times,
      required this.isDaily});
}

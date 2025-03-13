import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart'; // Assuming this exists

class NotificationsDashboard extends StatelessWidget {
  const NotificationsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view the dashboard.'));
    }

    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final lastWeekTimestamp = Timestamp.fromDate(lastWeek);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Weekly Medicine Report',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('reminders')
              .where('timestamp', isGreaterThan: lastWeekTimestamp)
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
                    Icon(Icons.info_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No reminders added in the past week.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                    .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
                    .toList(),
                isDaily: data['isDaily'],
                timestamp: data['timestamp'] as Timestamp?,
              );
            }).toList();

            return ListView(
              children: reminders.map((reminder) {
                final isTaken = snapshot.data!.docs.firstWhere(
                            (doc) => doc.id == reminder.id.toString())['taken']
                        as bool? ??
                    false;
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      isTaken ? Icons.check_circle : Icons.warning,
                      color: isTaken ? Colors.green : Colors.red,
                      size: 40,
                    ),
                    title: Text(
                      reminder.medicine,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${reminder.dosage} • ${reminder.times.map((t) => t.format(context)).join(', ')}\nStatus: ${isTaken ? "Taken" : "Not Taken"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

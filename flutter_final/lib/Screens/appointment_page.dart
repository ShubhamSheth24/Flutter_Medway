import 'package:flutter/material.dart';
import '../Services/book_appointment.dart'; // Import to access userAppointments

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  @override
  Widget build(BuildContext context) {
    // Sort appointments by date
    userAppointments.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: userAppointments.isEmpty
                  ? const Center(child: Text("No appointments scheduled"))
                  : ListView.builder(
                      itemCount: userAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = userAppointments[index];
                        final isPast =
                            appointment.date.isBefore(DateTime.now());

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              Icons.calendar_today,
                              color: isPast ? Colors.grey : Colors.blue,
                            ),
                            title: Text(
                                "${appointment.doctorName} - ${appointment.specialty}"),
                            subtitle: Text(
                                "${appointment.time}, ${appointment.date.toLocal().toString().split(' ')[0]}"),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isPast ? Colors.grey : Colors.black,
                            ),
                            onTap: () => _showAppointmentDetails(
                                context, appointment, index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetails(
      BuildContext context, Appointment appointment, int index) {
    final isPast = appointment.date.isBefore(DateTime.now());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Appointment Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Doctor: ${appointment.doctorName}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Specialty: ${appointment.specialty}"),
              const SizedBox(height: 8),
              Text(
                  "Date: ${appointment.date.toLocal().toString().split(' ')[0]}"),
              const SizedBox(height: 8),
              Text("Time: ${appointment.time}"),
              const SizedBox(height: 8),
              Text(
                "Status: ${isPast ? 'Past' : 'Upcoming'}",
                style: TextStyle(
                  color: isPast ? Colors.grey : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            if (!isPast) // Show Cancel button only for upcoming appointments
              TextButton(
                onPressed: () {
                  _cancelAppointment(index);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel Appointment",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(int index) {
    setState(() {
      userAppointments.removeAt(index); // Remove the appointment from the list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment canceled successfully")),
    );
  }
}

import 'package:flutter/material.dart';
import 'book_appointment.dart'; // Import to access userAppointments

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sort appointments by date
    userAppointments.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: userAppointments.isEmpty
                  ? Center(child: Text("No appointments scheduled"))
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
}

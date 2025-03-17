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
      backgroundColor: Colors.white, // Added white background
      appBar: AppBar(
        toolbarHeight: 50, // Reduced from default (~56)
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontSize: 20, // Reduced from default (~24)
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18, // Reduced from default (~24)
            color: Colors.white,
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(10), // Reduced from 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Appointments',
              style: TextStyle(
                fontSize: 22, // Reduced from 20
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            Expanded(
              child: userAppointments.isEmpty
                  ? const Center(
                      child: Text(
                        'No appointments scheduled',
                        style: TextStyle(fontSize: 14), // Reduced from default
                      ),
                    )
                  : ListView.builder(
                      itemCount: userAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = userAppointments[index];
                        final isPast =
                            appointment.date.isBefore(DateTime.now());

                        return Card(
                          elevation: 1, // Reduced from 2
                          margin: const EdgeInsets.symmetric(
                              vertical: 6), // Reduced from 8
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Reduced from default
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6), // Tightened
                            leading: Icon(
                              Icons.calendar_today,
                              color: isPast ? Colors.grey : Colors.blue,
                              size: 20, // Reduced from default (~24)
                            ),
                            title: Text(
                              '${appointment.doctorName} - ${appointment.specialty}',
                              style: const TextStyle(
                                fontSize: 16, // Reduced from default (~18)
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${appointment.time}, ${appointment.date.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(
                                  fontSize: 12), // Reduced from default (~14)
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14, // Reduced from 16
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Reduced from default
          ),
          title: const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 18, // Reduced from default (~20)
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor: ${appointment.doctorName}',
                style: const TextStyle(
                  fontSize: 14, // Reduced from default
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6), // Reduced from 8
              Text(
                'Specialty: ${appointment.specialty}',
                style: const TextStyle(fontSize: 12), // Reduced from default
              ),
              const SizedBox(height: 6), // Reduced from 8
              Text(
                'Date: ${appointment.date.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 12), // Reduced from default
              ),
              const SizedBox(height: 6), // Reduced from 8
              Text(
                'Time: ${appointment.time}',
                style: const TextStyle(fontSize: 12), // Reduced from default
              ),
              const SizedBox(height: 6), // Reduced from 8
              Text(
                'Status: ${isPast ? 'Past' : 'Upcoming'}',
                style: TextStyle(
                  fontSize: 12, // Reduced from default
                  color: isPast ? Colors.grey : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 12), // Reduced from default
              ),
            ),
            if (!isPast) // Show Cancel button only for upcoming appointments
              TextButton(
                onPressed: () {
                  _cancelAppointment(index);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel Appointment',
                  style: TextStyle(
                    fontSize: 12, // Reduced from default
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(int index) {
    setState(() {
      userAppointments.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Appointment canceled successfully',
          style: TextStyle(fontSize: 12), // Reduced from default
        ),
      ),
    );
  }
}

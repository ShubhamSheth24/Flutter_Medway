// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// // Appointment class defined here instead of separate file
// class Appointment {
//   final String doctorName;
//   final String specialty;
//   final DateTime date;
//   final String time;

//   Appointment({
//     required this.doctorName,
//     required this.specialty,
//     required this.date,
//     required this.time,
//   });
// }

// // Global list to store appointments
// List<Appointment> userAppointments = [];

// class BookAppointmentScreen extends StatefulWidget {
//   final Map<String, dynamic> doctor;

//   const BookAppointmentScreen({super.key, required this.doctor});

//   @override
//   _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
// }

// class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();

//   List<String> timeSlots = [
//     '8:00 AM',
//     '10:00 AM',
//     '11:00 AM',
//     '1:00 PM',
//     '2:00 PM',
//     '3:00 PM',
//     '4:00 PM',
//     '7:00 PM',
//     '8:00 PM'
//   ];

//   List<String> bookedSlots = ['10:00 AM', '3:00 PM', '7:00 PM'];
//   String? selectedTime;
//   bool _isLoading = false;

//   void _showConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Appointment'),
//           content: Text(
//               'Are you sure you want to book an appointment on ${_selectedDay.toLocal().toString().split(' ')[0]} at $selectedTime?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _bookAppointment();
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _bookAppointment() async {
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate a network call
//     await Future.delayed(const Duration(seconds: 2));

//     // Save the appointment
//     userAppointments.add(Appointment(
//       doctorName: widget.doctor['name'],
//       specialty: widget.doctor['specialty'],
//       date: _selectedDay,
//       time: selectedTime!,
//     ));

//     setState(() {
//       _isLoading = false;
//     });

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AppointmentConfirmationScreen(
//           doctor: widget.doctor,
//           time: selectedTime!,
//           date: _selectedDay,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text('Doctor Detail',
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(widget.doctor['name'],
//                               style: const TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(widget.doctor['specialty'],
//                               style: const TextStyle(color: Colors.grey)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               const Icon(Icons.star,
//                                   color: Colors.blue, size: 16),
//                               const SizedBox(width: 4),
//                               Text(widget.doctor['rating'].toString(),
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500)),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on,
//                                   color: Colors.grey, size: 16),
//                               const SizedBox(width: 4),
//                               Text(widget.doctor['distance'],
//                                   style: const TextStyle(
//                                       color: Colors.grey, fontSize: 14)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Select Appointment Date',
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 TableCalendar(
//                   firstDay: DateTime.now(),
//                   lastDay: DateTime.utc(2030, 12, 31),
//                   focusedDay: _focusedDay,
//                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDay = selectedDay;
//                       _focusedDay = focusedDay;
//                     });
//                   },
//                   calendarFormat: CalendarFormat.month,
//                   headerStyle: const HeaderStyle(
//                     formatButtonVisible: false,
//                     titleTextStyle:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     leftChevronIcon:
//                         Icon(Icons.chevron_left, color: Colors.blue),
//                     rightChevronIcon:
//                         Icon(Icons.chevron_right, color: Colors.blue),
//                   ),
//                   calendarStyle: CalendarStyle(
//                     selectedDecoration: const BoxDecoration(
//                       color: Colors.blue,
//                       shape: BoxShape.circle,
//                     ),
//                     todayDecoration: BoxDecoration(
//                       color: Colors.blue.shade100,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Select Time Slot',
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     mainAxisSpacing: 10,
//                     crossAxisSpacing: 10,
//                     childAspectRatio: 3,
//                   ),
//                   itemCount: timeSlots.length,
//                   itemBuilder: (context, index) {
//                     String slot = timeSlots[index];
//                     bool isBooked = bookedSlots.contains(slot);

//                     return GestureDetector(
//                       onTap: isBooked
//                           ? null
//                           : () {
//                               setState(() {
//                                 selectedTime = slot;
//                               });
//                             },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: isBooked
//                               ? Colors.grey.shade400
//                               : (selectedTime == slot
//                                   ? Colors.blue
//                                   : Colors.white),
//                           border: Border.all(color: Colors.blue),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           slot,
//                           style: TextStyle(
//                             color: isBooked ? Colors.black : Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: selectedTime != null && !_isLoading
//                         ? _showConfirmationDialog
//                         : null,
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text('Book Appointment'),
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

// class AppointmentConfirmationScreen extends StatelessWidget {
//   final Map<String, dynamic> doctor;
//   final String time;
//   final DateTime date;

//   const AppointmentConfirmationScreen({
//     super.key,
//     required this.doctor,
//     required this.time,
//     required this.date,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Appointment Confirmed'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 80),
//             const SizedBox(height: 20),
//             const Text('Your appointment has been successfully booked!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Doctor: ${doctor['name']}',
//                         style: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Text('Specialty: ${doctor['specialty']}',
//                         style:
//                             TextStyle(fontSize: 14, color: Colors.grey[700])),
//                     const SizedBox(height: 8),
//                     Text('Date: ${date.toLocal().toString().split(' ')[0]}',
//                         style:
//                             TextStyle(fontSize: 14, color: Colors.grey[700])),
//                     const SizedBox(height: 8),
//                     Text('Time: $time',
//                         style:
//                             TextStyle(fontSize: 14, color: Colors.grey[700])),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Back to Home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_final/home_page.dart'; // Import HomePage.dart (adjust path if needed)

// Appointment class defined here instead of separate file
class Appointment {
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String time;

  Appointment({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
  });
}

// Global list to store appointments
List<Appointment> userAppointments = [];

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<String> timeSlots = [
    '8:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '7:00 PM',
    '8:00 PM'
  ];

  List<String> bookedSlots = ['10:00 AM', '3:00 PM', '7:00 PM'];
  String? selectedTime;
  bool _isLoading = false;

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Text(
              'Are you sure you want to book an appointment on ${_selectedDay.toLocal().toString().split(' ')[0]} at $selectedTime?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _bookAppointment();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _bookAppointment() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network call
    await Future.delayed(const Duration(seconds: 2));

    // Save the appointment
    userAppointments.add(Appointment(
      doctorName: widget.doctor['name'],
      specialty: widget.doctor['specialty'],
      date: _selectedDay,
      time: selectedTime!,
    ));

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentConfirmationScreen(
          doctor: widget.doctor,
          time: selectedTime!,
          date: _selectedDay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Doctor Detail',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctor['name'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(widget.doctor['specialty'],
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.blue, size: 16),
                              const SizedBox(width: 4),
                              Text(widget.doctor['rating'].toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text(widget.doctor['distance'],
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Select Appointment Date',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.blue),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.blue),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Select Time Slot',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3,
                  ),
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    String slot = timeSlots[index];
                    bool isBooked = bookedSlots.contains(slot);

                    return GestureDetector(
                      onTap: isBooked
                          ? null
                          : () {
                              setState(() {
                                selectedTime = slot;
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.grey.shade400
                              : (selectedTime == slot
                                  ? Colors.blue
                                  : Colors.white),
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            color: isBooked ? Colors.black : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: selectedTime != null && !_isLoading
                        ? _showConfirmationDialog
                        : null,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Book Appointment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final String time;
  final DateTime date;

  const AppointmentConfirmationScreen({
    super.key,
    required this.doctor,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Confirmed'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text('Your appointment has been successfully booked!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doctor: ${doctor['name']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Specialty: ${doctor['specialty']}',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text('Date: ${date.toLocal().toString().split(' ')[0]}',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text('Time: $time',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to HomePage and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePage(
                            userName: '',
                          )),
                  (Route<dynamic> route) =>
                      false, // Removes all previous routes
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

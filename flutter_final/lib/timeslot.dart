import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DoctorDetailScreen(),
    );
  }
}

class DoctorDetailScreen extends StatefulWidget {
  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
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

  List<String> bookedSlots = [
    '10:00 AM',
    '3:00 PM',
    '7:00 PM'
  ]; // These slots cannot be selected
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Doctor Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. Rishi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cardiologist',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.blue, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.7',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.grey, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '800m away',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Select Appointment Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TableCalendar(
                  firstDay: DateTime.now(), // Restrict dates from today onwards
                  lastDay: DateTime.utc(2030, 12,
                      31), // The last selectable date remains the same
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(
                    formatButtonVisible:
                        false, // This removes the button that toggles between month and week views
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Select Time Slot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 slots per row
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio:
                        3, // Adjust this value to make buttons smaller
                  ),
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    String slot = timeSlots[index];
                    bool isBooked = bookedSlots.contains(slot);

                    return ElevatedButton(
                      onPressed: isBooked
                          ? null // Disable button if slot is booked
                          : () {
                              setState(() {
                                selectedTime = slot;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked
                            ? Colors.grey.shade400
                            : (selectedTime == slot
                                ? Colors.blue
                                : Colors.white),
                        foregroundColor: isBooked
                            ? Colors.black
                            : (selectedTime == slot
                                ? Colors.white
                                : Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: Text(slot),
                    );
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedTime != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BlankPage()),
                            );
                          }
                        : null, // Disable button if no time is selected
                    child: Text('Book Appointment'),
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

class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment Confirmed')),
      body: Center(child: Text('Your appointment has been booked.')),
    );
  }
}

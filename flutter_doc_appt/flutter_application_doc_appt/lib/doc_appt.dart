import 'package:flutter/material.dart';

class DoctorDetailPage extends StatefulWidget {
  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  int selectedDay = 2; // Default selected day (e.g., Wednesday)
  int selectedTime = 2; // Default selected time slot (e.g., 2:00 PM)

  final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final dates = [21, 22, 23, 24, 25, 26];
  final timeSlots = ["09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM", "07:00 PM", "08:00 PM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
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
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Text("Image"), // Replace with actual image
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr. Rishi",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text("Cardiologist", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        SizedBox(width: 4),
                        Text("4.7", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text("800m away", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 16),
            Text(
              "About",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(days.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDay = index;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedDay == index ? Colors.blue : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedDay == index ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          dates[index].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDay == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(timeSlots.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTime = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedTime == index ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      timeSlots[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedTime == index ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Book Appointment", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

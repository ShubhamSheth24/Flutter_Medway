import 'package:flutter/material.dart';

class DoctorListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Doctors'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildDoctorContainer(
                  context, "Dr. Rishi", "Cardiologist", "4.7", "600m away"),
              buildDoctorContainer(
                  context, "Dr. Vaamana", "Dentist", "4.7", "600m away"),
              buildDoctorContainer(
                  context, "Dr. Nallarasi", "Orthopedic", "4.7", "600m away"),
              buildDoctorContainer(
                  context, "Dr. Nihal", "Cardiologist", "4.7", "600m away"),
              buildDoctorContainer(
                  context, "Dr. Rishtia", "Dermatologist", "4.7", "560m away"),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDoctorContainer(
    BuildContext context,
    String name,
    String specialty,
    String rating,
    String distance,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to the blank page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlankPage(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(rating),
                      SizedBox(width: 8),
                      Text(distance, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blank Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'This is a blank page.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

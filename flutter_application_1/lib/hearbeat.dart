import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.deepPurple, // Highlighted color for the selected item
        unselectedItemColor: Colors.black54, // Color for unselected items
        backgroundColor: Colors.white, // Background color of the BottomNavigationBar
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Make the label bold for selected item
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: Heart rate alone - make it take full width
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Use Flexible to ensure it fills the available width
                Flexible(
                  child: InfoCard(
                    title: "Heart rate",
                    value: "97",
                    unit: "bpm",
                    icon: Icons.favorite,
                    color: Colors.blue.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Second row: Weight and Blood Group together
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: InfoCard(
                    title: "Weight",
                    value: "103",
                    unit: "lbs",
                    icon: Icons.fitness_center,
                    color: Colors.orange.shade100,
                  ),
                ),
                const SizedBox(width: 16), // Space between the cards
                Expanded(
                  child: InfoCard(
                    title: "Blood Group",
                    value: "A+",
                    unit: "",
                    icon: Icons.bloodtype,
                    color: Colors.pink.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Latest report",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const ReportCard(
              title: "General report",
              date: "Jul 10, 2023",
            ),
            const ReportCard(
              title: "General report",
              date: "Jul 9, 2023",
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (unit.isNotEmpty)
                Text(
                  " $unit",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String date;

  const ReportCard({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file, size: 32, color: Colors.blue),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}



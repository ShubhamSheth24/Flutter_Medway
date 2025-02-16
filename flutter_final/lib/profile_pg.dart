import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                  "https://example.com/profile.jpg"), // Replace with actual image URL
            ),
            SizedBox(height: 10),
            Text("Ruchita",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(height: 5),
                    Text("Heart Rate", style: TextStyle(fontSize: 14)),
                    Text("215bpm",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    SizedBox(height: 5),
                    Text("Calories", style: TextStyle(fontSize: 14)),
                    Text("756cal",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.blue),
                    SizedBox(height: 5),
                    Text("Weight", style: TextStyle(fontSize: 14)),
                    Text("103lbs",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ProfileOption(
              title: "My Saved",
              icon: Icons.favorite,
              onTap: () => _navigateTo(context, "My Saved"),
            ),
            ProfileOption(
              title: "Appointment",
              icon: Icons.calendar_today,
              onTap: () => _navigateTo(context, "Appointment"),
            ),
            ProfileOption(
              title: "Payment Method",
              icon: Icons.payment,
              onTap: () => _navigateTo(context, "Payment Method"),
            ),
            ProfileOption(
              title: "FAQs",
              icon: Icons.help_outline,
              onTap: () => _navigateTo(context, "FAQs"),
            ),
            ProfileOption(
              title: "Logout",
              icon: Icons.logout,
              onTap: () => _navigateTo(context, "Logout"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String pageTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceholderPage(title: pageTitle),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  ProfileOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 16)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("$title Page")),
    );
  }
}

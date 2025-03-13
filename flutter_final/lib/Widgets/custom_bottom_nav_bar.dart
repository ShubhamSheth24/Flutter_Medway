import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      iconSize: 28,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: AnimatedScale(
            scale: currentIndex == 0 ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.home),
          ),
          label: 'Home',
          tooltip: 'Home',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            scale: currentIndex == 1 ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.report),
          ),
          label: 'Reports',
          tooltip: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            scale: currentIndex == 2 ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.notifications),
          ),
          label: 'Notifications',
          tooltip: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            scale: currentIndex == 3 ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.medication),
          ),
          label: 'Reminders',
          tooltip: 'Medicine Reminders',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            scale: currentIndex == 4 ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.person),
          ),
          label: 'Profile',
          tooltip: 'Profile',
        ),
      ],
    );
  }
}

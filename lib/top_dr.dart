import 'package:flutter/material.dart';
import 'doctor_data.dart';
import 'book_appointment.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  String searchQuery = '';
  String? selectedSpecialty;

  List<String> getSpecialties() {
    return ['All'] + doctors.map((d) => d.specialty).toSet().toList()
      ..sort();
  }

  List<Doctor> getFilteredDoctors() {
    var filtered = doctors;
    if (selectedSpecialty != null && selectedSpecialty != 'All') {
      filtered =
          filtered.where((d) => d.specialty == selectedSpecialty).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((d) =>
              d.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              d.specialty.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filtered..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Doctors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search doctors...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedSpecialty ?? 'All',
                  items: getSpecialties()
                      .map((specialty) => DropdownMenuItem(
                            value: specialty,
                            child: Text(specialty),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedSpecialty = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: getFilteredDoctors().length,
              itemBuilder: (context, index) {
                return buildDoctorCard(context, getFilteredDoctors()[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDoctorCard(BuildContext context, Doctor doctor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(
          bottom: 10), // Fixed: Changed 'custom' to 'bottom'
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BookAppointmentScreen(doctor: doctor.toMap()),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on,
                            color: Colors.grey[600], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          doctor.distance,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

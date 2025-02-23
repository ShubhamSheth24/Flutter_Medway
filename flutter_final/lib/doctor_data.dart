class Doctor {
  final String name;
  final String specialty;
  final String rating; // Keeping as String to match original
  final String distance;

  Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'distance': distance,
    };
  }
}

List<Doctor> doctors = [
  Doctor(
      name: "Dr. Rishi",
      specialty: "Cardiologist",
      rating: "4.7",
      distance: "600m away"),
  Doctor(
      name: "Dr. Vaamana",
      specialty: "Dentist",
      rating: "4.7",
      distance: "600m away"),
  Doctor(
      name: "Dr. Nallarasi",
      specialty: "Orthopedic",
      rating: "4.7",
      distance: "600m away"),
  Doctor(
      name: "Dr. Nihal",
      specialty: "Cardiologist",
      rating: "4.7",
      distance: "600m away"),
  Doctor(
      name: "Dr. Rishtia",
      specialty: "Dermatologist",
      rating: "4.7",
      distance: "560m away"),
  Doctor(
      name: "Dr. Aditi",
      specialty: "Neurologist",
      rating: "4.8",
      distance: "700m away"),
  Doctor(
      name: "Dr. Raman",
      specialty: "Pediatrician",
      rating: "4.6",
      distance: "800m away"),
  Doctor(
      name: "Dr. Sneha",
      specialty: "General Physician",
      rating: "4.5",
      distance: "650m away"),
  Doctor(
      name: "Dr. Aryan",
      specialty: "ENT Specialist",
      rating: "4.7",
      distance: "720m away"),
  Doctor(
      name: "Dr. Meera",
      specialty: "Gynecologist",
      rating: "4.9",
      distance: "500m away"),
  Doctor(
      name: "Dr. Kabir",
      specialty: "Psychiatrist",
      rating: "4.6",
      distance: "900m away"),
  Doctor(
      name: "Dr. Ananya",
      specialty: "Oncologist",
      rating: "4.8",
      distance: "1.2km away"),
  Doctor(
      name: "Dr. Mohan",
      specialty: "Endocrinologist",
      rating: "4.5",
      distance: "850m away"),
  Doctor(
      name: "Dr. Kiran",
      specialty: "Urologist",
      rating: "4.7",
      distance: "950m away"),
  Doctor(
      name: "Dr. Pooja",
      specialty: "Dermatologist",
      rating: "4.8",
      distance: "600m away"),
  Doctor(
      name: "Dr. Surya",
      specialty: "Ophthalmologist",
      rating: "4.7",
      distance: "500m away"),
];

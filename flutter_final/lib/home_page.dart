import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/Services/medicine_reminder.dart';
import 'package:flutter_final/Widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_final/appointment_page.dart';
import 'package:flutter_final/book_appointment.dart';
import 'package:flutter_final/doctor_data.dart';
import 'package:flutter_final/health_info_form.dart';
import 'package:flutter_final/maps.dart';
import 'package:flutter_final/payment_method_page.dart';
import 'package:flutter_final/pharmacy.dart';
import 'package:flutter_final/products.dart';
import 'package:flutter_final/profile_page.dart';
import 'package:flutter_final/reports.dart';
import 'package:flutter_final/top_dr.dart';
import 'package:flutter_final/Screens/medicine_screen.dart';
import 'package:flutter_final/articles.dart';
import 'package:flutter_final/search.dart';
import 'package:flutter_final/widgets.dart';

defaultPadding() => const EdgeInsets.symmetric(horizontal: 20);

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String userName = "Loading...";
  int _currentIndex = 0;
  String _searchQuery = '';
  List<SearchItem> _filteredItems = [];
  bool _isLoading = true;
  String? _profileImageUrl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    _listenToUserData();
    _initializeFilteredItems();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _listenToUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            userName = snapshot['name'] ?? widget.userName;
            _profileImageUrl = snapshot['profileImageUrl'] as String?;
            _isLoading = false;
          });
        } else {
          setState(() {
            userName = widget.userName;
            _isLoading = false;
          });
        }
      }, onError: (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading user data: $e')));
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _initializeFilteredItems() {
    _filteredItems = [
      ...articles.map((article) => SearchItem(type: 'article', data: article)),
      ...doctors.map((doctor) => SearchItem(type: 'doctor', data: doctor)),
      ...products
          .where((p) => p['category'] == 'Medicines')
          .map((med) => SearchItem(type: 'medicine', data: med)),
      ...products
          .where((p) => p['category'] == 'Injections')
          .map((inj) => SearchItem(type: 'injection', data: inj)),
    ];
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _initializeFilteredItems();
      } else {
        _filteredItems = [
          ...articles
              .where((article) =>
                  article.title.toLowerCase().contains(query.toLowerCase()))
              .map((article) => SearchItem(type: 'article', data: article)),
          ...doctors
              .where((doctor) =>
                  doctor.name.toLowerCase().contains(query.toLowerCase()) ||
                  doctor.specialty.toLowerCase().contains(query.toLowerCase()))
              .map((doctor) => SearchItem(type: 'doctor', data: doctor)),
          ...products
              .where((product) =>
                  product['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  product['description']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .map((product) => SearchItem(
                  type: product['category'] == 'Medicines'
                      ? 'medicine'
                      : 'injection',
                  data: product)),
        ];
      }
    });
  }

  Widget _buildHomeView() {
    return RefreshIndicator(
      onRefresh: () async {
        _initializeFilteredItems();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
              ),
              child: Padding(
                padding: defaultPadding(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage('assets/user.jpg')
                                    as ImageProvider,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome!',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87)),
                            const SizedBox(height: 5),
                            FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(userName,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))),
                            const SizedBox(height: 5),
                            const Text('How is it going today?',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: defaultPadding().copyWith(top: 20.0),
              child: TextField(
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Search doctor, drugs, articles...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            Padding(
              padding: defaultPadding().copyWith(top: 20.0),
              child: _searchQuery.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Categories',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DoctorListScreen())),
                                child: const CategoryCard(
                                    icon: Icons.person, label: 'Top Doctors')),
                            GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PharmacyPage())),
                                child: const CategoryCard(
                                    icon: Icons.local_pharmacy,
                                    label: 'Pharmacy')),
                            GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AmbulanceBookingScreen())),
                                child: const CategoryCard(
                                    icon: Icons.local_hospital,
                                    label: 'Ambulance')),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Health Articles',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AllArticlesPage())),
                                      child: const Text('See all',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue))),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ...articles
                                  .take(3)
                                  .map((article) => GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ArticleDetailPage(
                                                        article: article))),
                                        child: HealthArticleCard(
                                          title: article.title,
                                          date: article.date,
                                          readTime: article.readTime,
                                          imagePath: article
                                              .imagePath, // Added imagePath
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _filteredItems.isEmpty
                      ? const Center(
                          child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No Results Found',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            switch (item.type) {
                              case 'article':
                                final article = item.data as Article;
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleDetailPage(
                                                  article: article))),
                                  child: HealthArticleCard(
                                    title: article.title,
                                    date: article.date,
                                    readTime: article.readTime,
                                    imagePath:
                                        article.imagePath, // Added imagePath
                                  ),
                                );
                              case 'doctor':
                                final doctor = item.data as Doctor;
                                return ListTile(
                                  leading: const Icon(Icons.person,
                                      color: Colors.blue),
                                  title: Text(doctor.name),
                                  subtitle: Text(doctor.specialty),
                                  trailing: Text(doctor.distance),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BookAppointmentScreen(doctor: {
                                                'name': doctor.name,
                                                'specialty': doctor.specialty,
                                                'rating':
                                                    doctor.rating.toString(),
                                                'distance': doctor.distance
                                              }))),
                                );
                              case 'medicine':
                              case 'injection':
                                final product =
                                    item.data as Map<String, dynamic>;
                                return ListTile(
                                  leading: const Icon(Icons.medical_services,
                                      color: Colors.green),
                                  title: Text(product['name']),
                                  subtitle: Text(
                                      '${product['quantity']} - \$${product['price']}'),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MedicineScreen(
                                              product: product))),
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsView() => ReportsContent(userName: userName);

  Widget _buildNotificationsView() => const Center(
      child: Text('Notifications Page', style: TextStyle(fontSize: 20)));

  Widget _buildRemindersView() => const MedicineReminder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeView(),
                    _buildReportsView(),
                    _buildNotificationsView(),
                    _buildRemindersView(),
                    ProfilePage(userName: userName),
                  ],
                ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
            if (_currentIndex == index && index == 0)
              _initializeFilteredItems();
            _currentIndex = index;
          }),
        ),
      ),
    );
  }
}

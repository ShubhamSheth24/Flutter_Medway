import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/Screens/medicine_reminder.dart';
import 'package:flutter_final/Widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_final/Screens/appointment_page.dart';
import 'package:flutter_final/Services/book_appointment.dart';
import 'package:flutter_final/doctor_data.dart';
import 'package:flutter_final/health_info_form.dart';
import 'package:flutter_final/maps.dart';
import 'package:flutter_final/payment_method_page.dart';
import 'package:flutter_final/pharmacy.dart';
import 'package:flutter_final/products.dart';
import 'package:flutter_final/profile_page.dart'
    as profile; // Alias for profile_page.dart
import 'package:flutter_final/reports.dart'; // Importing reports.dart
import 'package:flutter_final/top_dr.dart';
import 'package:flutter_final/Screens/medicine_screen.dart';
import 'package:flutter_final/articles.dart';
import 'package:flutter_final/utils/search.dart';
import 'package:flutter_final/Widgets/widgets.dart';
import 'package:flutter_final/notifications_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/models/user_model.dart';

const defaultPadding = EdgeInsets.symmetric(horizontal: 20);

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String userName = "";
  int _currentIndex = 0;
  String _searchQuery = '';
  List<SearchItem> _filteredItems = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print("HomePage initState started");

    userName = widget.userName;
    _isLoading = true;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  @override
  void dispose() {
    print("HomePage dispose called");
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    print("Loading initial data...");
    try {
      await Future.wait([
        _fetchUserData(),
        _initializeFilteredItemsAsync(),
      ]);
    } catch (e) {
      print("Error in _loadInitialData: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No authenticated user found");
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    print("Fetching user data for UID: ${user.uid}");
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists && mounted) {
        final userModel = Provider.of<UserModel>(context, listen: false);
        setState(() {
          userName = snapshot.data().toString().contains('name')
              ? snapshot.get('name')
              : widget.userName;
          _isLoading = false;
        });
        userModel.updateName(userName);
        final profileImageUrl =
            snapshot.data().toString().contains('profileImageUrl')
                ? snapshot.get('profileImageUrl') as String?
                : null;
        userModel.updateProfileImage(profileImageUrl ?? '');
        print(
            "HomePage - UserModel updated with profileImageUrl: $profileImageUrl");
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Firestore fetch error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeFilteredItemsAsync() async {
    print("Initializing filtered items...");
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
    print("Filtered items initialized: ${_filteredItems.length} items");
    if (mounted) setState(() => _isLoading = false);
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _initializeFilteredItemsAsync();
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _initializeFilteredItemsAsync();
        await _fetchUserData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: defaultPadding.copyWith(top: 40.0, bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            String? profileImageUrl;
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final data = snapshot.data!.data()
                                  as Map<String, dynamic>?;
                              profileImageUrl =
                                  data!.containsKey('profileImageUrl')
                                      ? data!['profileImageUrl'] as String?
                                      : null;
                              print(
                                  "HomePage - StreamBuilder fetched profileImageUrl: $profileImageUrl");
                            } else {
                              print(
                                  "HomePage - No data or document doesn’t exist");
                            }
                            return CircleAvatar(
                              radius: 40,
                              backgroundImage: profileImageUrl != null &&
                                      profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage('assets/user.jpg')
                                      as ImageProvider,
                              backgroundColor: Colors.grey[200],
                              onBackgroundImageError: (exception, stackTrace) {
                                print(
                                    "HomePage - Error loading profile image: $exception");
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'Welcome!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'How is it going today?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: defaultPadding.copyWith(top: 20.0),
              child: TextField(
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Search doctor, drugs, articles...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: defaultPadding.copyWith(top: 20.0),
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
                                        const DoctorListScreen()),
                              ),
                              child: const CategoryCard(
                                  icon: Icons.person, label: 'Top Doctors'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PharmacyPage()),
                              ),
                              child: const CategoryCard(
                                  icon: Icons.local_pharmacy,
                                  label: 'Pharmacy'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AmbulanceBookingScreen()),
                              ),
                              child: const CategoryCard(
                                  icon: Icons.map, label: 'Maps'),
                            ),
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
                                              const AllArticlesPage()),
                                    ),
                                    child: const Text('See all',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.blue)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ...articles.take(3).map(
                                    (article) => GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleDetailPage(
                                                  article: article),
                                        ),
                                      ),
                                      child: HealthArticleCard(
                                        title: article.title,
                                        date: article.date,
                                        readTime: article.readTime,
                                        imagePath: article.imagePath,
                                      ),
                                    ),
                                  ),
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
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        )
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
                                          ArticleDetailPage(article: article),
                                    ),
                                  ),
                                  child: HealthArticleCard(
                                    title: article.title,
                                    date: article.date,
                                    readTime: article.readTime,
                                    imagePath: article.imagePath,
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
                                          BookAppointmentScreen(
                                        doctor: {
                                          'name': doctor.name,
                                          'specialty': doctor.specialty,
                                          'rating': doctor.rating.toString(),
                                          'distance': doctor.distance,
                                        },
                                      ),
                                    ),
                                  ),
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
                                      builder: (context) =>
                                          MedicineScreen(product: product),
                                    ),
                                  ),
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

  Widget _buildReportsView() =>
      ReportsContents(userName: userName); // Updated to ReportsContents

  Widget _buildNotificationsView() => const NotificationsDashboard();

  Widget _buildRemindersView() => const MedicineReminder();

  @override
  Widget build(BuildContext context) {
    print("Building HomePage UI, _isLoading: $_isLoading");
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeView(),
                    _buildReportsView(),
                    _buildNotificationsView(),
                    _buildRemindersView(),
                    profile.ProfilePage(
                        userName:
                            userName), // Updated to profile.ReportsContent
                  ],
                ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            print("Nav bar tapped: $index");
            setState(() {
              if (_currentIndex == index && index == 0) {
                _initializeFilteredItemsAsync();
              }
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

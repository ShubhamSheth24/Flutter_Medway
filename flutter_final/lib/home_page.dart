import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/Widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_final/maps.dart';
import 'package:flutter_final/pharmacy.dart';
import 'package:flutter_final/top_dr.dart';
import 'package:flutter_final/appointment_page.dart';
import 'package:flutter_final/payment_method_page.dart';
import 'package:flutter_final/faqs_page.dart';
import 'package:flutter_final/Services/logout_page.dart';
import 'package:flutter_final/doctor_data.dart';
import 'package:flutter_final/products.dart';
import 'package:flutter_final/Screens/medicine_screen.dart';
import 'package:flutter_final/book_appointment.dart';
import 'package:flutter_final/profile_page.dart';
import 'package:flutter_final/health_info_form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

defaultPadding() => const EdgeInsets.symmetric(horizontal: 20);

class Article {
  final String title;
  final String date;
  final String readTime;
  final String content;

  Article({
    required this.title,
    required this.date,
    required this.readTime,
    required this.content,
  });
}

List<Article> articles = [
  Article(
    title: 'The 25 Healthiest Fruits You Can Eat, According to a Nutritionist',
    date: 'Jun 10, 2023',
    readTime: '5 min read',
    content:
        'Fruits are nature\'s wonderful gift to mankind; they are an absolute feast to our sight and provide numerous health benefits. This article explores 25 of the healthiest fruits recommended by nutritionists, including apples, bananas, berries, and more...',
  ),
  Article(
    title: 'The Impact of COVID-19 on Healthcare Systems',
    date: 'Jul 10, 2023',
    readTime: '5 min read',
    content:
        'The COVID-19 pandemic has dramatically altered healthcare systems worldwide. This article discusses the challenges faced, adaptations made, and long-term impacts on medical infrastructure and patient care...',
  ),
  Article(
    title: 'Understanding Mental Health: Breaking the Stigma',
    date: 'Aug 15, 2023',
    readTime: '6 min read',
    content:
        'Mental health is as important as physical health, yet it remains shrouded in stigma. This article delves into common mental health conditions, their symptoms, and ways to seek help while breaking down societal barriers...',
  ),
  Article(
    title: 'The Benefits of Regular Exercise on Heart Health',
    date: 'Sep 5, 2023',
    readTime: '4 min read',
    content:
        'Exercise is a cornerstone of a healthy lifestyle, especially for your heart. Learn how regular physical activity can reduce the risk of cardiovascular diseases, improve circulation, and boost overall well-being...',
  ),
  Article(
    title: 'Nutrition Tips for Managing Diabetes',
    date: 'Oct 20, 2023',
    readTime: '5 min read',
    content:
        'Managing diabetes effectively requires a balanced diet. This article provides practical nutrition tips, including the best foods to stabilize blood sugar, portion control strategies, and meal planning advice...',
  ),
  Article(
    title: 'Sleep and Its Impact on Your Immune System',
    date: 'Nov 12, 2023',
    readTime: '5 min read',
    content:
        'Quality sleep is crucial for a strong immune system. Discover how sleep affects your body\'s ability to fight infections, the science behind sleep cycles, and tips for improving your sleep hygiene...',
  ),
  Article(
    title: 'The Rise of Telemedicine: Healthcare in the Digital Age',
    date: 'Dec 1, 2023',
    readTime: '6 min read',
    content:
        'Telemedicine has transformed how we access healthcare. This article explores its growth, benefits like convenience and accessibility, and challenges such as technology barriers and privacy concerns...',
  ),
];

class SearchItem {
  final String type;
  final dynamic data;

  SearchItem({required this.type, required this.data});
}

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
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _fetchUserData();
    _initializeFilteredItems();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? widget.userName;
            _profileImageUrl = userDoc['profileImageUrl'] as String?;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
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
        await _fetchUserData();
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
                  bottomRight: Radius.circular(40),
                ),
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
                                    as ImageProvider
                                : const AssetImage('assets/user.jpg'),
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
                                      color: Colors.black)),
                            ),
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
                    borderSide: BorderSide.none,
                  ),
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
                                  icon: Icons.person, label: 'Top Doctors'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PharmacyPage())),
                              child: const CategoryCard(
                                  icon: Icons.local_pharmacy,
                                  label: 'Pharmacy'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AmbulanceBookingScreen())),
                              child: const CategoryCard(
                                  icon: Icons.local_hospital,
                                  label: 'Ambulance'),
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
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AllArticlesPage(),
                                        ),
                                      );
                                    },
                                    child: const Text('See all',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.blue)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ...articles
                                  .take(3)
                                  .map((article) => GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ArticleDetailPage(
                                                      article: article),
                                            ),
                                          );
                                        },
                                        child: HealthArticleCard(
                                          title: article.title,
                                          date: article.date,
                                          readTime: article.readTime,
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
                            child: Text(
                              'No Results Found',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ArticleDetailPage(article: article),
                                      ),
                                    );
                                  },
                                  child: HealthArticleCard(
                                    title: article.title,
                                    date: article.date,
                                    readTime: article.readTime,
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
                                  onTap: () {
                                    Navigator.push(
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
                                    );
                                  },
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MedicineScreen(product: product),
                                      ),
                                    );
                                  },
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentIndex == 3
                  ? ProfilePage(userName: userName)
                  : IndexedStack(
                      index: _currentIndex,
                      children: [
                        _buildHomeView(),
                        _buildReportsView(),
                        _buildNotificationsView(),
                      ],
                    ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              if (_currentIndex == index && index == 0) {
                _fetchUserData();
                _initializeFilteredItems();
              }
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class HealthArticleCard extends StatelessWidget {
  final String title;
  final String readTime;
  final String date;

  const HealthArticleCard({
    super.key,
    required this.title,
    required this.readTime,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                  image: AssetImage('assets/health_article.jpg'),
                  fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('$date • $readTime',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${article.date} • ${article.readTime}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage('assets/health_article.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                article.content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllArticlesPage extends StatelessWidget {
  const AllArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Health Articles'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailPage(article: article),
                  ),
                );
              },
              child: HealthArticleCard(
                title: article.title,
                date: article.date,
                readTime: article.readTime,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReportsContent extends StatefulWidget {
  final String userName;
  const ReportsContent({super.key, required this.userName});

  @override
  _ReportsContentState createState() => _ReportsContentState();
}

class _ReportsContentState extends State<ReportsContent> {
  String _heartRate = "97";
  String _weight = "103";
  String _bloodGroup = "A+";
  BluetoothDevice? _device;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    debugPrint("ReportsContent - STEP 1: Initializing...");
    _ensureUserAndLoadData();
    _startBluetoothScan();
  }

  Future<void> _ensureUserAndLoadData() async {
    debugPrint("ReportsContent - STEP 2: Ensuring user is logged in...");
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("No user logged in. Attempting anonymous sign-in...");
      try {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint("Anonymous sign-in successful: ${FirebaseAuth.instance.currentUser?.uid}");
      } catch (e) {
        debugPrint("Anonymous sign-in failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
        return;
      }
    } else {
      debugPrint("User already logged in: ${user.uid}");
    }
    await _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    debugPrint("ReportsContent - STEP 3: Loading health data...");
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint("ReportsContent - STEP 4: User authenticated: ${user.uid}");
      try {
        debugPrint("Fetching from path: users/${user.uid}/health_info/data");
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('health_info')
            .doc('data')
            .get();
        debugPrint("Firestore response - Exists: ${doc.exists}");
        if (doc.exists) {
          final data = doc.data();
          debugPrint("Raw Firestore data: $data");
          setState(() {
            _weight = data?['weight'] ?? "103";
            _bloodGroup = data?['bloodGroup'] ?? "A+";
            debugPrint("ReportsContent - STEP 5: Data loaded - Weight: $_weight, Blood Group: $_bloodGroup");
          });
        } else {
          debugPrint("No data found at path. Setting defaults.");
          setState(() {
            _weight = "103";
            _bloodGroup = "A+";
          });
        }
      } catch (e) {
        debugPrint("Error loading health data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } else {
      debugPrint("No authenticated user found after login attempt.");
    }
  }

  Future<void> _startBluetoothScan() async {
    debugPrint("Starting Bluetooth scan for CB-ARMOUR...");
    setState(() => _isFetching = true);

    if (!(await FlutterBluePlus.isOn)) {
      debugPrint("Bluetooth is off. Please turn it on.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please turn on Bluetooth')),
      );
      setState(() => _isFetching = false);
      return;
    }

    debugPrint("Bluetooth is on. Starting scan...");
    try {
      debugPrint("Current Bluetooth state: ${await FlutterBluePlus.adapterState.first}");
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      debugPrint("Scan started successfully at ${DateTime.now()}");

      FlutterBluePlus.scanResults.listen((results) async {
        debugPrint("Scan results received: ${results.length} devices found at ${DateTime.now()}");
        for (ScanResult r in results) {
          String name = r.device.name.isEmpty ? "Unnamed" : r.device.name;
          debugPrint("Device: $name (${r.device.id}), RSSI: ${r.rssi}");
          if (name.contains("CB-ARMOUR")) {
            debugPrint("Found CB-ARMOUR: $name (${r.device.id})");
            _device = r.device;
            await FlutterBluePlus.stopScan();
            await _connectToDevice();
            break;
          }
        }
      }, onError: (e) {
        debugPrint("Scan error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
        setState(() => _isFetching = false);
      }).onDone(() {
        debugPrint("Scan completed at ${DateTime.now()}");
        setState(() => _isFetching = false);
        if (_device == null) {
          debugPrint("CB-ARMOUR not found after scan.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CB-ARMOUR watch not found')),
          );
        } else {
          debugPrint("Device found: ${_device!.name}");
        }
      });
    } catch (e) {
      debugPrint("Scan failed to start: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth scan failed: $e')),
      );
      setState(() => _isFetching = false);
    }
  }

  Future<void> _connectToDevice() async {
    if (_device == null) return;
    debugPrint("Connecting to ${_device!.name}...");
    try {
      await _device!.connect();
      debugPrint("Connected to ${_device!.name}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${_device!.name}')),
      );
      await _discoverServices();
    } catch (e) {
      debugPrint("Connection failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
      setState(() => _isFetching = false);
    }
  }

  Future<void> _discoverServices() async {
    if (_device == null) return;
    debugPrint("Discovering services for ${_device!.name}...");
    try {
      List<BluetoothService> services = await _device!.discoverServices();
      debugPrint("Found ${services.length} services");
      for (BluetoothService service in services) {
        debugPrint("Service UUID: ${service.uuid}");
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          debugPrint("Characteristic UUID: ${characteristic.uuid}");
          if (characteristic.uuid.toString() == "00002a37-0000-1000-8000-00805f9b34fb") {
            debugPrint("Found heart rate characteristic: ${characteristic.uuid}");
            await characteristic.setNotifyValue(true);
            debugPrint("Subscribed to heart rate notifications");
            characteristic.value.listen((value) {
              if (value.isNotEmpty) {
                int hr = value[1]; // Heart rate is typically second byte
                setState(() {
                  _heartRate = hr.toString();
                  _isFetching = false;
                  debugPrint("Heart rate updated: $_heartRate at ${DateTime.now()}");
                });
              } else {
                debugPrint("Received empty heart rate value");
              }
            });
          }
        }
      }
      if (_isFetching) {
        debugPrint("No heart rate characteristic found after service discovery.");
        setState(() => _isFetching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Heart rate service not found on CB-ARMOUR')),
        );
      }
    } catch (e) {
      debugPrint("Service discovery failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service discovery failed: $e')),
      );
      setState(() => _isFetching = false);
    }
  }

  @override
  void dispose() {
    _device?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "ReportsContent - STEP 6: Building UI - Heart Rate: $_heartRate, Weight: $_weight, Blood Group: $_bloodGroup");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: "Heart Rate",
            value: _isFetching ? "Fetching..." : _heartRate,
            unit: "bpm",
            icon: Icons.favorite,
            color: Colors.blue.shade50,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: "Weight",
                  value: _weight,
                  unit: "lbs",
                  icon: Icons.fitness_center,
                  color: Colors.orange.shade50,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: InfoCard(
                  title: "Blood Group",
                  value: _bloodGroup,
                  unit: "",
                  icon: Icons.bloodtype,
                  color: Colors.pink.shade50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Latest Reports",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const ReportCard(title: "General Report", date: "Jul 10, 2023"),
          const ReportCard(title: "General Report", date: "Jul 9, 2023"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              debugPrint("ReportsContent - STEP 7: Navigating to HealthInfoForm...");
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthInfoForm(userName: widget.userName),
                ),
              );
              debugPrint("ReportsContent - STEP 8: Returned from HealthInfoForm. Reloading data...");
              await _loadHealthData();
            },
            child: const Text('Edit Health Info'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startBluetoothScan,
            child: const Text('Retry Bluetooth Scan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
        ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.black87),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
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
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.insert_drive_file,
                    size: 36, color: Colors.blue.shade400),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
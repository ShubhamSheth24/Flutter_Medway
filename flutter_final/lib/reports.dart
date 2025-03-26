import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_final/health_info_form.dart';
import 'package:flutter_final/Widgets/widgets.dart';
import 'package:flutter_final/models/reminder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/models/user_model.dart';

class ReportsContents extends StatefulWidget {
  final String userName;
  const ReportsContents({super.key, required this.userName});

  @override
  _ReportsContentsState createState() => _ReportsContentsState();
}

class _ReportsContentsState extends State<ReportsContents>
    with SingleTickerProviderStateMixin {
  String _heartRate = "97";
  String _weight = "103";
  String _bloodGroup = "A+";
  BluetoothDevice? _device;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    debugPrint("ReportsContents - STEP 1: Initializing...");
    _ensureUserAndLoadData();
    _startBluetoothScan();
  }

  @override
  void dispose() {
    _device?.disconnect();
    super.dispose();
  }

  Future<void> _ensureUserAndLoadData() async {
    debugPrint("ReportsContents - STEP 2: Ensuring user is logged in...");
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("No user logged in. Attempting anonymous sign-in...");
      try {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint(
            "Anonymous sign-in successful: ${FirebaseAuth.instance.currentUser?.uid}");
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
    debugPrint("ReportsContents - STEP 3: Loading health data...");
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint("ReportsContents - STEP 4: User authenticated: ${user.uid}");
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('health_info')
            .doc('data')
            .get();
        debugPrint("Firestore response - Exists: ${doc.exists}");
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _weight = data?['weight'] ?? "103";
            _bloodGroup = data?['bloodGroup'] ?? "A+";
            _heartRate = data?['heartRate'] ?? "97";
          });
        } else {
          debugPrint("No data found at path. Setting defaults.");
          setState(() {
            _weight = "103";
            _bloodGroup = "A+";
            _heartRate = "97";
          });
        }
      } catch (e) {
        debugPrint("Error loading health data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _startBluetoothScan() async {
    debugPrint("Starting Bluetooth scan for CB-ARMOUR...");
    setState(() => _isFetching = true);
    if (!(await FlutterBluePlus.isOn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please turn on Bluetooth')),
      );
      setState(() => _isFetching = false);
      return;
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          String name = r.device.name.isEmpty ? "Unnamed" : r.device.name;
          if (name.contains("CB-ARMOUR") ||
              r.device.id.toString() == "FF:AD:F0:01:EA:4B") {
            _device = r.device;
            await FlutterBluePlus.stopScan();
            await _connectToDevice();
            break;
          }
        }
      }, onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
        setState(() => _isFetching = false);
      }).onDone(() {
        setState(() => _isFetching = false);
        if (_device == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CB-ARMOUR watch not found')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth scan failed: $e')),
      );
      setState(() => _isFetching = false);
    }
  }

  Future<void> _connectToDevice() async {
    if (_device == null) return;
    try {
      await _device!.connect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${_device!.name}')),
      );
      await _discoverServices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
      setState(() => _isFetching = false);
    }
  }

  Future<void> _discoverServices() async {
    if (_device == null) return;
    try {
      List<BluetoothService> services = await _device!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() ==
                  "00002a37-0000-1000-8000-00805f9b34fb" &&
              characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              if (value.isNotEmpty) {
                int hr = value[1];
                setState(() {
                  _heartRate = hr.toString();
                  _isFetching = false;
                });
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('health_info')
                    .doc('data')
                    .set({'heartRate': _heartRate}, SetOptions(merge: true));
              }
            });
          } else if (characteristic.uuid.toString() ==
                  "0000ffd1-0000-1000-8000-00805f9b34fb" &&
              characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              if (value.isNotEmpty) {
                int hr = value[1];
                setState(() {
                  _heartRate = hr.toString();
                  _isFetching = false;
                });
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('health_info')
                    .doc('data')
                    .set({'heartRate': _heartRate}, SetOptions(merge: true));
              }
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service discovery failed: $e')),
      );
      setState(() => _isFetching = false);
    }
  }

  void _editHealthInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthInfoForm(userName: widget.userName),
      ),
    ).then((_) => _loadHealthData());
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view reports.'));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 56,
        title: const Text(
          'Health Reports',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Stack(
              children: [
                InfoCard(
                  title: "Heart Rate",
                  value: _isFetching ? "Fetching..." : _heartRate,
                  unit: "bpm",
                  icon: Icons.monitor_heart,
                  color: Colors.blue.shade100,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                    onPressed: _startBluetoothScan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: _editHealthInfo,
                    child: InfoCard(
                      title: "Weight",
                      value: _weight,
                      unit: "lbs",
                      icon: Icons.scale,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onLongPress: _editHealthInfo,
                    child: InfoCard(
                      title: "Blood Group",
                      value: _bloodGroup,
                      unit: "",
                      icon: Icons.water_drop,
                      color: Colors.red.shade200,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Latest Reports",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            _LatestReportsSection(user: user, userName: widget.userName),
          ],
        ),
      ),
    );
  }
}

class _LatestReportsSection extends StatefulWidget {
  final User user;
  final String userName;

  const _LatestReportsSection({required this.user, required this.userName});

  @override
  __LatestReportsSectionState createState() => __LatestReportsSectionState();
}

class __LatestReportsSectionState extends State<_LatestReportsSection>
    with SingleTickerProviderStateMixin {
  String _filter = 'All';
  bool _showDaily = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _linkedPatientUid;
  List<Reminder> _reminders = [];
  Map<int, bool> _takenStatus = {};
  bool _isLoading = true;
  late ScrollController _scrollController;
  Timestamp? _lastFetchedTimestamp;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    _scrollController = ScrollController();
    _loadUserData();
    _fetchReminders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      if (profileDoc.exists) {
        final data = profileDoc.data() as Map<String, dynamic>;
        setState(() {
          _linkedPatientUid =
              data.containsKey('linkedUid') ? data['linkedUid'] : null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
    }
  }

  Future<void> _fetchReminders() async {
    setState(() => _isLoading = true);
    try {
      final userModel = Provider.of<UserModel>(context, listen: false);
      final isCaretaker = userModel.role == 'Caretaker';
      final timeFrame = _showDaily
          ? DateTime.now().subtract(const Duration(days: 1))
          : DateTime.now().subtract(const Duration(days: 7));
      final timestamp = Timestamp.fromDate(timeFrame);

      if (_lastFetchedTimestamp == null ||
          _lastFetchedTimestamp!.seconds != timestamp.seconds) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(isCaretaker && _linkedPatientUid != null
                ? _linkedPatientUid
                : widget.user.uid)
            .collection('reminders')
            .where('timestamp', isGreaterThan: timestamp)
            .get();

        final reminders = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final reminder = Reminder(
            id: int.parse(doc.id),
            medicine: data['medicine'] ?? 'Unknown',
            dosage: data['dosage'] ?? 'N/A',
            times: (data['times'] as List? ?? [])
                .map((t) =>
                    TimeOfDay(hour: t['hour'] ?? 0, minute: t['minute'] ?? 0))
                .toList(),
            isDaily: data['isDaily'] ?? true,
            timestamp: data['timestamp'] as Timestamp?,
          );
          _takenStatus[reminder.id] = data['taken'] as bool? ?? false;
          return reminder;
        }).toList();

        setState(() {
          _reminders = reminders;
          _lastFetchedTimestamp = timestamp;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching reminders: $e')));
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFilterButton(String label) {
    return GestureDetector(
      onTap: () {
        setState(() => _filter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _filter == label ? Colors.blueAccent : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _filter == label
              ? [
                  BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3), blurRadius: 4)
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _filter == label ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (!_showDaily) {
                setState(() {
                  _showDaily = true;
                  _fetchReminders();
                });
              }
            },
            child: Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _showDaily ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  'Daily',
                  style: TextStyle(
                    fontSize: 14,
                    color: _showDaily ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_showDaily) {
                setState(() {
                  _showDaily = false;
                  _fetchReminders();
                });
              }
            },
            child: Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !_showDaily ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  'Weekly',
                  style: TextStyle(
                    fontSize: 14,
                    color: !_showDaily ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReminderDetails(
      BuildContext context, Reminder reminder, String dateString) {
    final isTaken = _takenStatus[reminder.id] ?? false;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: isTaken
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    child: Icon(
                      isTaken ? Icons.check_circle : Icons.warning,
                      color: isTaken ? Colors.green : Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reminder.medicine,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Dosage: ${reminder.dosage}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                  'Times: ${reminder.times.map((t) => t.format(context)).join(', ')}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 6),
              Text('Frequency: ${reminder.isDaily ? 'Daily' : 'Weekly'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 6),
              Text('Added: $dateString',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                'Status: ${isTaken ? 'Taken' : 'Not Taken'}',
                style: TextStyle(
                  fontSize: 14,
                  color: isTaken ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  child: const Text('Close',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildToggleSwitch()),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterButton('All'),
              const SizedBox(width: 10),
              _buildFilterButton('Taken'),
              const SizedBox(width: 10),
              _buildFilterButton('Not Taken'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compliance Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const SizedBox.shrink()
                  else if (_reminders.isEmpty)
                    const SizedBox.shrink()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_reminders.isNotEmpty ? (_reminders.where((r) => _takenStatus[r.id] ?? false).length / _reminders.length * 100).toStringAsFixed(1) : '0'}%',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const Text(
                              'Compliance Rate',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_reminders.where((r) => _takenStatus[r.id] ?? false).length}/${_reminders.length}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'Taken/Total',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reminders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          _showDaily
                              ? 'No reminders added today.'
                              : 'No reminders added in the past week.',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 300,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: () {
                          final filteredReminders = _filter == 'All'
                              ? _reminders
                              : _filter == 'Taken'
                                  ? _reminders
                                      .where((r) => _takenStatus[r.id] ?? false)
                                  : _reminders.where(
                                      (r) => !(_takenStatus[r.id] ?? false));

                          final sortedReminders = filteredReminders.toList()
                            ..sort(
                                (a, b) => b.timestamp!.compareTo(a.timestamp!));

                          return sortedReminders.map((reminder) {
                            final isTaken = _takenStatus[reminder.id] ?? false;
                            final timestamp = reminder.timestamp?.toDate();
                            final dateString = timestamp != null
                                ? DateFormat('MMM d, h:mm a').format(timestamp)
                                : 'N/A';

                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: GestureDetector(
                                onTap: () => _showReminderDetails(
                                    context, reminder, dateString),
                                child: Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Colors.grey.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isTaken
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          child: Icon(
                                            isTaken
                                                ? Icons.check_circle
                                                : Icons.warning,
                                            color: isTaken
                                                ? Colors.green
                                                : Colors.red,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                reminder.medicine,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${reminder.dosage} • ${reminder.times.map((t) => t.format(context)).join(', ')}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Added: $dateString',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isTaken
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.red
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isTaken
                                                      ? 'Taken'
                                                      : 'Not Taken',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isTaken
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontWeight: FontWeight.w600,
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
                              ),
                            );
                          }).toList();
                        }(),
                      ),
                    ),
                  ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_final/health_info_form.dart';
import 'package:flutter_final/Widgets/widgets.dart';

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
            _heartRate = data?['heartRate'] ?? "97";
            debugPrint(
                "ReportsContent - STEP 5: Data loaded - Weight: $_weight, Blood Group: $_bloodGroup, Heart Rate: $_heartRate");
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
      debugPrint(
          "Current Bluetooth state: ${await FlutterBluePlus.adapterState.first}");
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      debugPrint("Scan started successfully at ${DateTime.now()}");

      FlutterBluePlus.scanResults.listen((results) async {
        debugPrint(
            "Scan results received: ${results.length} devices found at ${DateTime.now()}");
        for (ScanResult r in results) {
          String name = r.device.name.isEmpty ? "Unnamed" : r.device.name;
          debugPrint("Device: $name (${r.device.id}), RSSI: ${r.rssi}");
          if (name.contains("CB-ARMOUR") ||
              r.device.id.toString() == "FF:AD:F0:01:EA:4B") {
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
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          debugPrint(
              "Characteristic UUID: ${characteristic.uuid}, Properties: notify=${characteristic.properties.notify}, read=${characteristic.properties.read}, write=${characteristic.properties.write}");
          if (characteristic.uuid.toString() ==
                  "00002a37-0000-1000-8000-00805f9b34fb" &&
              characteristic.properties.notify) {
            debugPrint(
                "Found standard heart rate characteristic: ${characteristic.uuid}");
            await characteristic.setNotifyValue(true);
            debugPrint("Subscribed to standard heart rate notifications");
            characteristic.value.listen((value) {
              if (value.isNotEmpty) {
                int hr = value[1];
                setState(() {
                  _heartRate = hr.toString();
                  _isFetching = false;
                  debugPrint(
                      "Heart rate updated (2a37): $_heartRate at ${DateTime.now()}");
                });
                // Save to Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('health_info')
                    .doc('data')
                    .set({'heartRate': _heartRate}, SetOptions(merge: true));
              } else {
                debugPrint("Received empty value from 2a37");
              }
            });
          } else if (characteristic.uuid.toString() ==
                  "0000ffd1-0000-1000-8000-00805f9b34fb" &&
              characteristic.properties.notify) {
            debugPrint(
                "Trying custom heart rate characteristic: ${characteristic.uuid}");
            await characteristic.setNotifyValue(true);
            debugPrint("Subscribed to custom notifications (ffd1)");
            characteristic.value.listen((value) {
              if (value.isNotEmpty) {
                int hr = value[1];
                setState(() {
                  _heartRate = hr.toString();
                  _isFetching = false;
                  debugPrint(
                      "Custom heart rate updated (ffd1): $_heartRate at ${DateTime.now()}");
                });
                // Save to Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('health_info')
                    .doc('data')
                    .set({'heartRate': _heartRate}, SetOptions(merge: true));
              } else {
                debugPrint("Received empty value from ffd1");
              }
            });
          }
        }
      }
      if (_isFetching) {
        debugPrint(
            "No heart rate characteristic found after service discovery.");
        setState(() => _isFetching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Heart rate service not found on CB-ARMOUR')),
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
              debugPrint(
                  "ReportsContent - STEP 7: Navigating to HealthInfoForm...");
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HealthInfoForm(userName: widget.userName),
                ),
              );
              debugPrint(
                  "ReportsContent - STEP 8: Returned from HealthInfoForm. Reloading data...");
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthInfoForm extends StatefulWidget {
  final String userName;
  const HealthInfoForm({super.key, required this.userName});

  @override
  _HealthInfoFormState createState() => _HealthInfoFormState();
}

class _HealthInfoFormState extends State<HealthInfoForm> {
  final _formKey = GlobalKey<FormState>();
  String? _weight;
  String? _bloodGroup;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint("HealthInfoForm - Loading data for UID: ${user.uid}");
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_info')
          .doc('data')
          .get();
      if (doc.exists) {
        setState(() {
          _weight = doc['weight'] as String?;
          _bloodGroup = doc['bloodGroup'] as String?;
          debugPrint(
              "HealthInfoForm - Loaded data: Weight: $_weight, Blood Group: $_bloodGroup");
        });
      } else {
        debugPrint("HealthInfoForm - No existing data found.");
      }
    } else {
      debugPrint("HealthInfoForm - No user logged in.");
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        debugPrint(
            "HealthInfoForm - Saving data for UID: ${user.uid}, Weight: $_weight, Blood Group: $_bloodGroup");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('health_info')
            .doc('data')
            .set({
          'weight': _weight,
          'bloodGroup': _bloodGroup,
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health info saved successfully!')),
        );
        Navigator.pop(context);
      } else {
        debugPrint("HealthInfoForm - No user logged in to save.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Health Info'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _weight,
                  decoration: const InputDecoration(
                    labelText: 'Weight (lbs)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter weight' : null,
                  onSaved: (value) => _weight = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _bloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter blood group' : null,
                  onSaved: (value) => _bloodGroup = value,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

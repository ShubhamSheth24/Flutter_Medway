import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reminder {
  final int id;
  final String medicine;
  final String dosage;
  final List<TimeOfDay> times;
  final bool isDaily;
  final Timestamp? timestamp;

  Reminder({
    required this.id,
    required this.medicine,
    required this.dosage,
    required this.times,
    required this.isDaily,
    this.timestamp,
  });
}

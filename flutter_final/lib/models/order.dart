import 'package:flutter_final/models/medicine.dart';

class Order {
  final String id;
  final double amount;
  final String status;
  final List<Medicine>? items;
  final String? paymentId;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.amount,
    this.status = "Pending",
    this.items,
    this.paymentId,
    this.createdAt,
  });
}
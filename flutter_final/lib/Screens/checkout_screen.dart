import 'package:flutter/material.dart';
import 'package:flutter_final/models/medicine.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Medicine> medicines;
  final double totalAmount;

  CheckoutScreen({required this.medicines, required this.totalAmount});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _paymentService.dispose(); // Ensure cleanup of Razorpay
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.medicines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.medicines[index].name),
                  subtitle: Text("₹${widget.medicines[index].price}"),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _paymentService.openCheckout(widget.totalAmount);
            },
            child: Text("Pay ₹${widget.totalAmount} with Razorpay"),
          ),
        ],
      ),
    );
  }
}

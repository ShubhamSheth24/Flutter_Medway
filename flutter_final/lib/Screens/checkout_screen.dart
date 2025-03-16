import 'package:flutter/material.dart';
import 'package:flutter_final/models/medicine.dart';
import 'package:flutter_final/models/order.dart';
import 'package:flutter_final/Services/payment_service.dart'; // Capital 'S'
import 'package:flutter_final/utils/constrants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/cart.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Medicine> medicines;
  final double totalAmount;

  const CheckoutScreen(
      {super.key, required this.medicines, required this.totalAmount});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late PaymentService _paymentService;
  bool isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.onPaymentSuccess = (response) {
      setState(() => isProcessingPayment = false);
      final order = Order(
        id: response.paymentId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        amount: widget.totalAmount,
        status: "Completed",
        items: widget.medicines,
        paymentId: response.paymentId,
        createdAt: DateTime.now(),
      );
      print('Payment successful: ${response.paymentId}'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment Successful: ${response.paymentId}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Provider.of<Cart>(context, listen: false).clearCart();
      Navigator.pop(context, true);
    };
    _paymentService.onPaymentError = (response) {
      setState(() => isProcessingPayment = false);
      print('Payment failed: ${response.message}'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment Failed: ${response.message}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    };
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    setState(() => isProcessingPayment = true);
    print('Starting payment for ₹${widget.totalAmount}'); // Debug
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      _paymentService.openCheckout(
        amount: widget.totalAmount,
        razorpayKey: razorpayKey,
      );
    } catch (e) {
      setState(() => isProcessingPayment = false);
      print('Error initiating payment: $e'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting payment: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = widget.medicines[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              medicine.imageUrl ?? 'assets/placeholder.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  size: 50),
                            ),
                          ),
                          title: Text(medicine.name),
                          subtitle:
                              Text("₹${medicine.price.toStringAsFixed(2)}"),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("₹${widget.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessingPayment ? null : _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: isProcessingPayment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            "Pay ₹${widget.totalAmount.toStringAsFixed(2)} with Razorpay",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (isProcessingPayment)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_final/models/medicine.dart';
// import 'package:flutter_final/services/payment_service.dart';
// import 'package:flutter_final/utils/constrants.dart'; // Import constants.dart for razorpayKey

// class CheckoutScreen extends StatefulWidget {
//   final List<Medicine> medicines;
//   final double totalAmount;

//   const CheckoutScreen({super.key, required this.medicines, required this.totalAmount});

//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late PaymentService _paymentService;
//   bool isProcessingPayment = false; // Flag to prevent multiple clicks and show loading

//   @override
//   void initState() {
//     super.initState();
//     _paymentService = PaymentService();
//     _paymentService.onPaymentSuccess = (response) {
//       setState(() => isProcessingPayment = false); // Reset loading state
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Payment Successful: ${response.paymentId}"),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//       Navigator.pop(context); // Return to CartScreen after success
//     };
//     _paymentService.onPaymentError = (response) {
//       setState(() => isProcessingPayment = false); // Reset loading state
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Payment Failed: ${response.message}"),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     };
//   }

//   @override
//   void dispose() {
//     _paymentService.dispose(); // Ensure cleanup of Razorpay
//     super.dispose();
//   }

//   Future<void> _startPayment() async {
//     setState(() => isProcessingPayment = true); // Show loading indicator
//     try {
//       await Future.delayed(const Duration(milliseconds: 100)); // Small delay to allow UI update
//       _paymentService.openCheckout(
//         amount: widget.totalAmount,
//         razorpayKey: razorpayKey, // Use key from constants.dart
//       );
//     } catch (e) {
//       setState(() => isProcessingPayment = false); // Reset on error
//       debugPrint('Error initiating payment: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error starting payment: $e'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Checkout")),
//       body: Stack( // Stack for loading overlay
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: widget.medicines.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(widget.medicines[index].name),
//                       subtitle: Text("₹${widget.medicines[index].price}"),
//                     );
//                   },
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: isProcessingPayment ? null : _startPayment, // Disable button while processing
//                 child: isProcessingPayment
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                       )
//                     : Text("Pay ₹${widget.totalAmount} with Razorpay"),
//               ),
//             ],
//           ),
//           if (isProcessingPayment)
//             Container( // Overlay for loading state
//               color: Colors.black.withOpacity(0.3),
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }
// }
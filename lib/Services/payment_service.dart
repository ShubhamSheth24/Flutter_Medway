// // import 'package:flutter/material.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';

// // class PaymentService {
// //   late Razorpay _razorpay;
// //   Function(PaymentSuccessResponse)? onPaymentSuccess;
// //   Function(PaymentFailureResponse)? onPaymentError;
// //   Function(ExternalWalletResponse)? onExternalWallet;

// //   PaymentService() {
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }

// //   void openCheckout({required double amount, required String razorpayKey}) {
// //     var options = {
// //       'key': razorpayKey,
// //       'amount': (amount * 100).toInt(),
// //       'name': 'Medicine Store',
// //       'description': 'Payment for your order',
// //       'prefill': {'contact': '1234567890', 'email': 'test@example.com'},
// //       'external': {'wallets': ['paytm']},
// //       'theme': {'color': '#2196F3'},
// //     };

// //     try {
// //       _razorpay.open(options);
// //     } catch (e) {
// //       debugPrint('Error opening Razorpay: $e');
// //     }
// //   }

// //   void _handlePaymentSuccess(PaymentSuccessResponse response) {
// //     debugPrint("Payment Successful: ${response.paymentId}");
// //     onPaymentSuccess?.call(response);
// //   }

// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     debugPrint("Payment Error: ${response.code} - ${response.message}");
// //     onPaymentError?.call(response);
// //   }

// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     debugPrint("External Wallet Selected: ${response.walletName}");
// //     onExternalWallet?.call(response);
// //   }

// //   void dispose() {
// //     _razorpay.clear();
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class PaymentService {
//   late Razorpay _razorpay;
//   Function(PaymentSuccessResponse)? onPaymentSuccess;
//   Function(PaymentFailureResponse)? onPaymentError;
//   Function(ExternalWalletResponse)? onExternalWallet;

//   PaymentService() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   void openCheckout({required double amount, required String razorpayKey}) {
//     var options = {
//       'key': razorpayKey,
//       'amount': (amount * 100).toInt(), // Convert to paise
//       'name': 'Medicine Store',
//       'description': 'Payment for your order',
//       'prefill': {'contact': '1234567890', 'email': 'test@example.com'},
//       'external': {'wallets': ['paytm']},
//     };

//     try {
//       _razorpay.open(options); // This runs on a separate thread via Razorpay SDK
//     } catch (e) {
//       debugPrint('Error opening Razorpay: $e');
//       throw e; // Re-throw to handle in caller
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     debugPrint("Payment Successful: ${response.paymentId}");
//     onPaymentSuccess?.call(response); // Call success callback
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     debugPrint("Payment Error: ${response.code} - ${response.message}");
//     onPaymentError?.call(response); // Call error callback
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     debugPrint("External Wallet Selected: ${response.walletName}");
//     onExternalWallet?.call(response);
//   }

//   void dispose() {
//     _razorpay.clear(); // Cleanup Razorpay instance
//   }
// }
// import 'package:flutter/material.dart';
// import 'checkout_screen.dart';

// class CartScreen extends StatelessWidget {
//   final double cartTotal = 500.0;
  
//   get selectedMedicines => null; // Example cart total amount

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Your Cart")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 // builder: (context) => CheckoutScreen(totalAmount: cartTotal, medicines: null,),
//                  builder: (context) => CheckoutScreen(
//       medicines: selectedMedicines, // Pass selected medicines list
//       totalAmount: cartTotal,
//     ),
//               ),
//             );
//           },
//           child: Text("Proceed to Payment"),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import '../models/medicine.dart';

class CartScreen extends StatelessWidget {
  final List<Medicine> selectedMedicines = [
    Medicine(name: "Paracetamol", price: 50.0),
    Medicine(name: "Cough Syrup", price: 150.0),
  ];

  @override
  Widget build(BuildContext context) {
    double cartTotal = selectedMedicines.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: Text("Your Cart")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutScreen(
                  medicines: selectedMedicines,
                  totalAmount: cartTotal,
                ),
              ),
            );
          },
          child: Text("Proceed to Payment"),
        ),
      ),
    );
  }
}

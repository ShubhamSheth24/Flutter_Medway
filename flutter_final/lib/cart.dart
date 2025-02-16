import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Cart item model
class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Subtotal calculation with price clean-up
  double get subtotal {
    return _items.fold(0, (total, item) {
      double price = double.tryParse(item.product['price'].toString()) ?? 0.0;
      return total + price * item.quantity;
    });
  }

  // Calculate taxes based on the product's tax percentage
  double get taxes {
    double totalTax = 0;
    for (var item in _items) {
      double price = double.tryParse(item.product['price'].toString()) ?? 0.0;
      double taxPercentage =
          double.tryParse(item.product['taxPercentage'].toString()) ?? 0.0;
      double itemTax = (price * taxPercentage / 100) * item.quantity;
      totalTax += itemTax;
    }
    return totalTax;
  }

  double get total => subtotal + taxes;

  void addToCart(Map<String, dynamic> product) {
    var existingItemIndex =
        _items.indexWhere((item) => item.product['id'] == product['id']);
    if (existingItemIndex != -1) {
      // Product already in the cart, increase quantity
      _items[existingItemIndex].quantity++;
    } else {
      // Add new product to cart
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> product) {
    var existingItemIndex =
        _items.indexWhere((item) => item.product['id'] == product['id']);
    if (existingItemIndex != -1) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
      } else {
        _items.removeAt(existingItemIndex);
      }
    }
    notifyListeners();
  }

  void deleteItem(Map<String, dynamic> product) {
    _items.removeWhere((item) => item.product['id'] == product['id']);
    notifyListeners();
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String paymentMethod = 'VISA'; // Default payment method
  bool isDropdownVisible = false; // To control dropdown visibility

  bool isHoveredVISA = false;
  bool isHoveredMasterCard = false;
  bool isHoveredCashOnDelivery = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My cart', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      double price =
                          double.tryParse(item.product['price'].toString()) ??
                              0.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              item.product['imageUrl'],
                              width: 50,
                              height: 50,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text(item.product['quantity'],
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove,
                                            color: Colors.grey),
                                        onPressed: () =>
                                            cart.removeFromCart(item.product),
                                      ),
                                      Text('${item.quantity}',
                                          style: const TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            cart.addToCart(item.product),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.grey),
                                  onPressed: () =>
                                      cart.deleteItem(item.product),
                                ),
                                // Add ₹ symbol explicitly when displaying the price
                                Text(
                                  '₹${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                const Text('Payment Detail',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                _buildPaymentDetailRow(
                    'Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
                _buildPaymentDetailRow(
                    'Taxes', '₹${cart.taxes.toStringAsFixed(2)}'),
                _buildPaymentDetailRow(
                    'Total', '₹${cart.total.toStringAsFixed(2)}',
                    isBold: true),
                const SizedBox(height: 20),
                const Text('Payment Method',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDropdownVisible = !isDropdownVisible;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(paymentMethod,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const Text('Change',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total ₹${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () {
                        // Handle checkout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isDropdownVisible)
            Positioned(
              top: 220, // Adjust this value based on the space available
              left: 16,
              right: 16,
              child: Material(
                color: Colors.white,
                elevation: 5,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            isHoveredVISA = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            isHoveredVISA = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isHoveredVISA ? Colors.blue : Colors.white,
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            border: Border.all(
                              color: isHoveredVISA
                                  ? Colors.blue
                                  : Colors
                                      .transparent, // Border color changes when hovered
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              'VISA',
                              style: TextStyle(
                                color:
                                    isHoveredVISA ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                paymentMethod = 'VISA';
                                isDropdownVisible = false;
                              });
                            },
                          ),
                        ),
                      ),
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            isHoveredMasterCard = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            isHoveredMasterCard = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isHoveredMasterCard
                                ? Colors.blue
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            border: Border.all(
                              color: isHoveredMasterCard
                                  ? Colors.blue
                                  : Colors
                                      .transparent, // Border color changes when hovered
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              'MasterCard',
                              style: TextStyle(
                                color: isHoveredMasterCard
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                paymentMethod = 'MasterCard';
                                isDropdownVisible = false;
                              });
                            },
                          ),
                        ),
                      ),
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            isHoveredCashOnDelivery = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            isHoveredCashOnDelivery = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isHoveredCashOnDelivery
                                ? Colors.blue
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            border: Border.all(
                              color: isHoveredCashOnDelivery
                                  ? Colors.blue
                                  : Colors
                                      .transparent, // Border color changes when hovered
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              'Cash on Delivery',
                              style: TextStyle(
                                color: isHoveredCashOnDelivery
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                paymentMethod = 'Cash on Delivery';
                                isDropdownVisible = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

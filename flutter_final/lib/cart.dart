import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/services/payment_service.dart';
import 'package:flutter_final/models/medicine.dart';
import 'package:flutter_final/utils/constrants.dart';
import 'package:flutter_final/Screens/checkout_screen.dart'; // Use single import

class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get subtotal => _items.fold(0, (total, item) {
        double price = double.tryParse(item.product['price'].toString()) ?? 0.0;
        return total + price * item.quantity;
      });

  double get taxes => _items.fold(0, (total, item) {
        double price = double.tryParse(item.product['price'].toString()) ?? 0.0;
        double taxPercentage =
            double.tryParse(item.product['taxPercentage'].toString()) ?? 0.0;
        return total + (price * taxPercentage / 100) * item.quantity;
      });

  double get total => subtotal + taxes;

  void addToCart(Map<String, dynamic> product) {
    final existingItemIndex =
        _items.indexWhere((item) => item.product['id'] == product['id']);
    final quantityToAdd = product['quantity'] is int
        ? product['quantity'] as int
        : 1; // Default to 1 if not int
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity += quantityToAdd;
    } else {
      _items.add(CartItem(product: product, quantity: quantityToAdd));
    }
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> product) {
    final existingItemIndex =
        _items.indexWhere((item) => item.product['id'] == product['id']);
    if (existingItemIndex != -1) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
      } else {
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  void deleteItem(Map<String, dynamic> product) {
    _items.removeWhere((item) => item.product['id'] == product['id']);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String paymentMethod = 'VISA';
  bool isDropdownVisible = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Cart',
          style: TextStyle(
              color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty!',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            final price = double.tryParse(
                                    item.product['price'].toString()) ??
                                0.0;
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        item.product['imageUrl'] ??
                                            'assets/placeholder.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                                Icons.image_not_supported,
                                                size: 60),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product['name'] ??
                                                'Unnamed Item',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Stock: ${item.product['quantity']?.toString() ?? 'N/A'}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildIconButton(
                                                icon: Icons.remove,
                                                onTap: () =>
                                                    cart.removeFromCart(
                                                        item.product),
                                              ),
                                              const SizedBox(width: 8),
                                              AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Text(
                                                  '${item.quantity}',
                                                  key: ValueKey(item.quantity),
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildIconButton(
                                                icon: Icons.add,
                                                color: Colors.blue,
                                                onTap: () => cart
                                                    .addToCart(item.product),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.redAccent),
                                          onPressed: () =>
                                              cart.deleteItem(item.product),
                                        ),
                                        Text(
                                          '₹${(price * item.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummarySection(cart),
                      const SizedBox(height: 16),
                      _buildPaymentMethodSection(),
                      const SizedBox(height: 20),
                      _buildCheckoutButton(cart),
                    ],
                  ),
                ),
                if (isDropdownVisible) _buildPaymentDropdown(),
              ],
            ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon,
      Color color = Colors.grey,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
          color: Colors.white,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildSummarySection(Cart cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text('Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Taxes', '₹${cart.taxes.toStringAsFixed(2)}'),
          const Divider(height: 20),
          _buildSummaryRow('Total', '₹${cart.total.toStringAsFixed(2)}',
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => isDropdownVisible = !isDropdownVisible),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      paymentMethod == 'VISA' || paymentMethod == 'MasterCard'
                          ? Icons.credit_card
                          : Icons.local_shipping,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(paymentMethod,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDropdown() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdownItem('VISA', Icons.credit_card),
              _buildDropdownItem('MasterCard', Icons.credit_card),
              _buildDropdownItem('Cash on Delivery', Icons.local_shipping),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() {
        paymentMethod = title;
        isDropdownVisible = false;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Text(title,
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(Cart cart) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (cart.items.isNotEmpty) {
            try {
              // Validate cart items before navigation
              final medicines = cart.items
                  .map((item) => Medicine(
                        name: item.product['name'] ?? 'Unnamed Item',
                        price: double.tryParse(item.product['price'].toString()) ??
                            0.0,
                        imageUrl: item.product['imageUrl'] ?? '',
                      ))
                  .where((medicine) =>
                      medicine.name.isNotEmpty && medicine.price >= 0)
                  .toList();

              if (medicines.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Invalid cart items. Please check your cart.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
                return;
              }

              // Log before navigation for debugging
              print('Navigating to CheckoutScreen with medicines: $medicines, total: ${cart.total}');

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => CheckoutScreen(
              //       medicines: medicines,
              //       totalAmount: cart.total,
              //     ),
              //   ),
              // ).then((value) {
              //   // Handle return from CheckoutScreen if needed (e.g., clear cart)
              //   print('Returned from CheckoutScreen: $value');
              // });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error navigating to checkout: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              print('Checkout error details: $e');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cart is empty! Add items to proceed.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: Text(
          'Checkout (₹${cart.total.toStringAsFixed(2)})',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
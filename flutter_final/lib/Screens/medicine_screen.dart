import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart.dart';

class MedicineScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const MedicineScreen({super.key, required this.product});

  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  int quantity = 1;

  int _parseQuantity(String? quantityStr) {
    if (quantityStr == null) return 0;
    return int.tryParse(quantityStr.split(' ')[0]) ?? 0;
  }

  void _addToCart() {
    final maxStock = _parseQuantity(widget.product["quantity"]);
    if (quantity > maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add more than available stock!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Provider.of<Cart>(context, listen: false).addToCart({
      'id': widget.product["id"] ?? UniqueKey().toString(),
      'name': widget.product["name"] ?? 'Unnamed Medicine',
      'price': widget.product["price"].toString().replaceAll('₹', ''),
      'imageUrl': widget.product["imageUrl"] ?? 'assets/placeholder.png',
      'quantity': quantity,
      'taxPercentage': widget.product["taxPercentage"] ?? '0',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('$quantity ${widget.product["name"]} added to cart'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double price = double.tryParse(
            widget.product["price"].toString().replaceAll('₹', '')) ??
        0.0;
    final maxStock = _parseQuantity(widget.product["quantity"]);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.product["name"] ?? 'Medicine',
          style: const TextStyle(
              color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.shopping_cart,
                    color: Colors.black87, size: 28),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Consumer<Cart>(
                    builder: (context, cart, child) {
                      int totalQuantity = cart.items
                          .fold(0, (sum, item) => sum + item.quantity);
                      return totalQuantity > 0
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle),
                              child: Text(
                                '$totalQuantity',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  widget.product["imageUrl"] ?? 'assets/placeholder.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported,
                        size: 80, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.product["name"] ?? 'Unnamed Medicine',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Available: ${widget.product["quantity"]?.toString() ?? 'N/A'}',
                    style: TextStyle(
                        fontSize: 16,
                        color: maxStock > 0 ? Colors.green : Colors.red),
                  ),
                  if (maxStock <= 5 && maxStock > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text('(Low Stock)',
                          style: TextStyle(fontSize: 14, color: Colors.orange)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                    5,
                    (index) => Icon(
                          index < (widget.product["rating"]?.toInt() ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 22,
                        )),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildIconButton(
                        icon: Icons.remove,
                        onTap: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Text(
                          '$quantity',
                          key: ValueKey(quantity),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildIconButton(
                        icon: Icons.add,
                        color: Colors.blue,
                        onTap: quantity < maxStock
                            ? () => setState(() => quantity++)
                            : null,
                      ),
                    ],
                  ),
                  Text(
                    '₹${(price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product["description"] ?? 'No description available.',
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[700], height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: maxStock > 0 ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maxStock > 0 ? Colors.blue : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon,
      Color color = Colors.grey,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          color: onTap != null ? Colors.white : Colors.grey[200],
        ),
        child: Icon(icon,
            color: onTap != null ? color : Colors.grey[400], size: 24),
      ),
    );
  }
}

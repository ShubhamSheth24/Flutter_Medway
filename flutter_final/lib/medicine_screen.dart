import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart.dart';

class MedicineScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const MedicineScreen({super.key, required this.product});

  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  int quantity = 1;
  bool isExpanded = false;

  void _addToCart() {
    Provider.of<Cart>(context, listen: false).addToCart({
      'name': widget.product["name"],
      'price': widget.product["price"],
      'imageUrl': widget.product["imageUrl"],
      'quantity': quantity,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${widget.product["name"]} added to the cart'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 14, color: Colors.grey[700]);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product["name"]),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Consumer<Cart>(
                    builder: (context, cart, child) {
                      int totalCartQuantity = cart.items
                          .fold(0, (total, item) => total + item.quantity);
                      return totalCartQuantity > 0
                          ? CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text(
                                '$totalCartQuantity',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            )
                          : Container();
                    },
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                widget.product["imageUrl"],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Text(
                widget.product["name"],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                widget.product["quantity"],
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.product["rating"].toInt()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.yellow[700],
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$quantity",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "₹${(double.parse(widget.product["price"].replaceAll('₹', '')) * quantity).toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                widget.product["description"],
                style: textStyle,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(0),
                color: Colors.white,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _addToCart,
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
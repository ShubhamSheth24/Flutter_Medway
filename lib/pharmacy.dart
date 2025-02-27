import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/medicine_screen.dart';
import 'products.dart';
import 'category_page.dart';
import 'cart.dart';

class PharmacyPage extends StatefulWidget {
  @override
  _PharmacyPageState createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredMedicines = [];
  List<Map<String, dynamic>> filteredInjections = [];
  List<Map<String, dynamic>> medicines = [];
  List<Map<String, dynamic>> injections = [];

  @override
  void initState() {
    super.initState();
    medicines = products
        .where((product) => product['category'] == 'Medicines')
        .toList();
    injections = products
        .where((product) => product['category'] == 'Injections')
        .toList();

    filteredMedicines = medicines;
    filteredInjections = injections;

    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredMedicines = medicines
          .where((product) => product["name"].toLowerCase().contains(query))
          .toList();
      filteredInjections = injections
          .where((product) => product["name"].toLowerCase().contains(query))
          .toList();
    });
  }

  void _addToCart(BuildContext context, Map<String, dynamic> product) {
    Provider.of<Cart>(context, listen: false).addToCart(product);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${product["name"]} added to the cart'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget buildProductCard(BuildContext context, Map<String, dynamic> product) {
    double price = double.tryParse(product["price"]) ?? 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineScreen(product: product),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(right: 12.0, bottom: 16.0),
        elevation: 0,
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          width: 140,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(product["imageUrl"]),
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product["name"],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product["quantity"],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Transform.translate(
                        offset: const Offset(-6.0, -9.0),
                        child: Transform.scale(
                          scale: 1.4,
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _addToCart(context, product),
                            icon: const Icon(Icons.add_circle,
                                color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // int totalCartQuantity = Provider.of<Cart>(context).items.fold(
    //   0,
    //   (total, item) => total + item.quantity,
    // );
    int totalCartQuantity = context.watch<Cart>().items.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Pharmacy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                if (totalCartQuantity > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$totalCartQuantity',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
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
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search drugs, category...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0F5FD),
                ),
              ),
              const SizedBox(height: 16),
              buildCategorySection(context, 'Medicines', filteredMedicines),
              const SizedBox(height: 16),
              buildCategorySection(context, 'Injections', filteredInjections),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategorySection(
      BuildContext context, String title, List<Map<String, dynamic>> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryPage(category: title, products: products),
                  ),
                );
              },
              child:
                  const Text('See all', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        products.isEmpty
            ? const Center(
                child: Text('No items found.',
                    style: TextStyle(color: Colors.grey)))
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return buildProductCard(context, products[index]);
                  },
                ),
              ),
      ],
    );
  }
}

class Medicine {
  final String name;
  final double price;
  final String? imageUrl; // Optional for UI flexibility

  Medicine({required this.name, required this.price, this.imageUrl});
}
class Order {
  final String id;
  final double amount;
  final String status;

  Order({required this.id, required this.amount, this.status = "Pending"});
}

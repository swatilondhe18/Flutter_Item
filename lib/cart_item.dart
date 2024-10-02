
// CartItem class to define the structure of each cart item
class CartItem {
  //final String id;

  final String name;
  final String company;
  final String openingStock;
  final double rate;
  final String imageUrl;
  int quantity;

  CartItem({
  //  required this.id,

    required this.name,
    required this.company,
    required this.openingStock,
    required this.rate,
    required this.imageUrl,
    required this.quantity,
  });
}

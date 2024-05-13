class Dish {
  final String id;
  final String name;
  final String image;
  final int price;
  int quantity;

  Dish({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }
}
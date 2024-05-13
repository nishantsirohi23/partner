
class Dishesss {
  late String id;
  late String name;
  late int price;
  late int restprice;
  late int review;
  late String image;
  late bool available;



  Dishesss({
    required this.id,
    required this.name,
    required this.image,
    required this.review,
    required this.price,
    required this.restprice,
    required this.available,



  });

  Dishesss.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    image = json['image'] ?? '';
    price = json['latitude'] ?? 0;
    review = json['longitude'] ?? 0;
    restprice = json['restprice'] ?? 0;
    available = json['available'] ?? true;



  }

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
      'image': image,
      'review': review,
      'restprice': restprice,
      'price': price,
      'available': available


    };


  }
}

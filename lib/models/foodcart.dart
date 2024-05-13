class FoodCart {
  FoodCart({

    required this.name,
    required this.restrauntID,
    required this.instructions,




  });
  late String restrauntID;
  late String instructions;
  late String name;







  FoodCart.fromJson(Map<String, dynamic> json) {
    restrauntID = json['restrauntID'] ?? '';
    instructions = json['instructions'] ?? '';
    name = json['name'] ?? '';




  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['restrauntID'] = restrauntID;
    data['name'] = name;
    data['instructions'] = instructions;





    return data;
  }
}

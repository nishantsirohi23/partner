
class Professional {
  late String id;
  late String name;
  late String biography;
  late String experience;
  late double pricePerHour;
  late String username;
  late String email;
  late String phoneNumber;
  late String aadharCardNumber;
  late List<String> specialities;
  late String profileImageUrl;
  late String rating;
  late String totalrating;
  late int workamount;
  late int mytips;
  late int walletamount;
  late bool bankadded;



  Professional({
    required this.id,
    required this.name,
    required this.biography,
    required this.experience,
    required this.pricePerHour,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.aadharCardNumber,
    required this.specialities,
    required this.profileImageUrl,
    required this.rating,
    required this.totalrating,
    required this.workamount,
    required this.mytips,
    required this.walletamount,
    required this.bankadded
  });

  Professional.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    biography = json['biography'] ?? '';
    experience = json['experience'] ?? '';
    pricePerHour = json['price_per_hour'] ?? 0.0;
    username = json['username'] ?? '';
    email = json['email'] ?? '';
    phoneNumber = json['phone_number'] ?? '';
    aadharCardNumber = json['aadhar_card_number'] ?? '';
    specialities = List<String>.from(json['specialities'] ?? []);
    profileImageUrl = json['profile_image_url'] ?? '';
    rating = json['rating'] ?? '';
    totalrating = json['totalrating'] ?? '';
    walletamount = json['totalrating'] ?? 0;
    workamount = json['totalrating'] ?? 0;
    mytips = json['totalrating'] ?? 0;
    bankadded = json['bankadded'] ?? false;


  }

  Map<String, dynamic> toMap() {

      return {
        'id': id,
        'name': name,
        'biography': biography,
        'experience': experience,
        'price_per_hour': pricePerHour,
        'username': username,
        'email': email,
        'phone_number': phoneNumber,
        'aadhar_card_number': aadharCardNumber,
        'specialities': specialities,
        'profile_image_url': profileImageUrl,
        'rating': rating,
        'totalrating': totalrating,
        'walletamount': walletamount,
        'workamount': walletamount,
        'tips': mytips,
        'bankadded': bankadded

      };


  }
}

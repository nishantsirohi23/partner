class Review {
  late String userId;
  late double star;
  late DateTime date;
  late String subject;
  late String profId;

  Review({
    required this.userId,
    required this.star,
    required this.date,
    required this.subject,
    required this.profId,
  });

  Review.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] ?? '';
    star = json['star'] ?? 0.0;
    date = DateTime.parse(json['date'] ?? '');
    subject = json['subject'] ?? '';
    profId = json['profId'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'star': star,
      'date': date.toIso8601String(),
      'subject': subject,
      'profId': profId,
    };
  }
}

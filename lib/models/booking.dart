class Booking {
  late String id; // Add id field
  late String workerId;
  late String type;
  late String hours;
  late String days;
  late String work;
  late DateTime fromDate;
  late DateTime toDate;
  late String fromTime; // New field
  late String toTime; // New field
  late String status;
  late String userId;
  late String lat;
  late String long;
  late String address;
  late bool payment;
  late int totalamount;
  late int grandtotal;
  late int tip;
  late bool reviewdone;
  late String createdAt;






  Booking({
    required this.id, // Update constructor to include id
    required this.workerId,
    required this.type,
    required this.hours,
    required this.days,
    required this.work,
    required this.fromDate,
    required this.toDate,
    required this.fromTime, // Include in constructor
    required this.toTime, // Include in constructor
    required this.status,
    required this.userId,
    required this.lat,
    required this.long,
    required this.address,
    required this.payment,
    required this.totalamount,
    required this.tip,
    required this.grandtotal,
    required this.reviewdone,
    required this.createdAt,




  });

  Booking.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '', // Parse id from JSON
        workerId = json['workerId'] ?? '',
        type = json['type'] ?? '',
        hours = json['hours'] ?? '',
        days = json['days'] ?? '',
        work = json['work'] ?? '',
        fromDate = DateTime.parse(json['fromDate'] ?? ''),
        toDate = DateTime.parse(json['toDate'] ?? ''),
        fromTime = json['fromTime'] ?? '', // Parse fromTime from JSON
        toTime = json['toTime'] ?? '', // Parse toTime from JSON
        status = json['status'] ?? '',
        userId = json['userId'] ?? '',
        lat = json['lat'] ?? '',
        long = json['long'] ?? '',
        address = json['address'] ?? '',
        payment = json['payment'] ?? '',
        tip = json['tip'] ?? '',
        reviewdone = json['reviewdone'] ?? false,
        grandtotal = json['grandtotal'] ?? '',
      totalamount = json['totalamount'] ?? '',
        createdAt = json['created_at'] ?? '';




  Map<String, dynamic> toMap() {
    return {
      'id': id, // Add id to map
      'workerId': workerId,
      'type': type,
      'hours': hours,
      'days': days,
      'work': work,
      'fromDate': fromDate,
      'toDate': toDate,
      'fromTime': fromTime, // Add fromTime to map
      'toTime': toTime, // Add toTime to map
      'status': status,
      'userId': userId,
      'lat': lat,
      'long': long,
      'address': address,
      'payment': payment,
      'tip': tip,
      'grandtotal': grandtotal,
      'totalamount': totalamount,
      'reviewdone': reviewdone,
      'created_at' : createdAt





  };
  }
}

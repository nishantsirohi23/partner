class Work {
  late String id;
  late String workBy;
  late String name;
  late String description;
  late DateTime dateTime;
  late double amount;
  late bool negotiable;
  late bool choose;
  late String priority;
  late String status;
  late String prof;
  late List<Map<String, String>> fileData; // List to store file URLs and types
  late double fromlongitude;
  late double fromlatitude;
  late String fromaddress;
  late double tolongitude;
  late double tolatitude;
  late String toaddress;
  late bool payment;
  late int tip;
  late int grandtotal;
  late bool reviewdone;
  late String createdAt;
  late String cod;
  late String category;
  late bool reached; // New property
  late bool picked; // New property

  Work({
    required this.id,
    required this.workBy,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.amount,
    required this.negotiable,
    required this.priority,
    required this.status,
    required this.prof,
    required this.fileData,
    required this.payment,
    required this.fromlongitude,
    required this.fromlatitude,
    required this.fromaddress,
    required this.tolongitude,
    required this.tolatitude,
    required this.toaddress,
    required this.tip,
    required this.grandtotal,
    required this.reviewdone,
    required this.cod,
    required this.choose,
    required this.category,
    required this.createdAt,
    this.reached = false, // Default value for picked

    this.picked = false, // Default value for picked
  });

  Map<String, dynamic> toMap() {
    return {
      'workBy': workBy,
      'name': name,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'amount': amount,
      'negotiable': negotiable,
      'priority': priority,
      'status': status,
      'prof': prof,
      'fileData': fileData,
      'fromlongitude': fromlongitude,
      'fromlatitude': fromlatitude,
      'fromaddress': fromaddress,
      'tolongitude': tolongitude,
      'tolatitude': tolatitude,
      'toaddress': toaddress,
      'tip': tip,
      'grandtotal': grandtotal,
      'payment': payment,
      'reviewdone': reviewdone,
      'cod': cod,
      'choose': choose,
      'category': category,
      'created_at': createdAt,
      'reached': reached, // Include picked in the map

      'picked': picked, // Include picked in the map
    };
  }
}

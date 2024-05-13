class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.type,
    required this.nmessage,
    required this.nnotiwork,
    required this.nnotibooking,
    required this.mobile,
    required this.freeplatform,
    required this.restid,
    required this.detailsdone,
    required this.bankadded,
    required this.isopen,
    required this.restaddress,
    required this.neworder,
    required this.completedorder,
    required this.pendingorder,
    required this.latitude,
    required this.longitude,
    required this.restname,
    required this.restimage,
    required this.restspecs,
  });

  late String image;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String type;
  late int nmessage;
  late int nnotiwork;
  late int nnotibooking;
  late String mobile;
  late int freeplatform;
  late int neworder;
  late int pendingorder;
  late int completedorder;
  late String restid;
  late String  restaddress;
  late bool detailsdone;
  late bool bankadded;
  late double latitude;
  late double longitude;
  late bool isopen;
  late String restspecs; // Super premium end date
  late String restname; // Super premium start date
  late String restimage; // Super premium end date

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    type = json['type'] ?? '';
    nmessage = json['nmessage'] ?? 0;
    nnotiwork = json['nnotiwork'] ?? 0;
    nnotibooking = json['nnotibooking'] ?? 0;
    mobile = json['mobile'] ?? '';
    freeplatform = json['freeplatform'] ?? 0;
    restid = json['restid'] ?? "";
    restimage = json['restimage'] ?? '';
    neworder = json['neworder'] ?? 0;
    pendingorder = json['pendingorder'] ?? 0;
    completedorder = json['completedorder'] ?? 0;
    detailsdone = json['detailsdone'] ?? false;
    bankadded = json['bankadded'] ?? false;
    isopen = json['isopen'] ?? false;
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
    restname = json['restname'] ?? '';
    restaddress = json['restaddress'] ?? '';
    restspecs = json['restspecs'] ?? '';

  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['type'] = type;
    data['nmessage'] = nmessage;
    data['nnotiwork'] = nnotiwork;
    data['nnotibooking'] = nnotibooking;
    data['mobile'] = mobile;
    data['freeplatform'] = freeplatform;
    data['restid'] = restid;
    data['detailsdone'] = detailsdone;
    data['bankadded'] = bankadded;
    data['isopen'] = isopen;
    data['restimage'] = restimage;
    data['neworder'] = neworder;
    data['pendingorder'] = pendingorder;
    data['completedorder'] = completedorder;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['restname'] = restname;
    data['restaddress'] = restaddress;
    data['restspecs'] = restspecs;

    return data;
  }
}

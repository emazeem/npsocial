// To parse this JSON data, do
//
//     final userNearme = userNearmeFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:np_social/res/constant.dart';

UserNearme userNearmeFromJson(String str) =>
    UserNearme.fromJson(json.decode(str));

String userNearmeToJson(UserNearme data) => json.encode(data.toJson());

class UserNearme {
  UserNearme({
    required this.message,
    required this.data,
  });

  String message;
  List<Datum> data;

  factory UserNearme.fromJson(Map<String, dynamic> json) => UserNearme(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.userId,
    required this.workplaceLongitude,
    required this.workplaceLatitude,
    required this.workplace,
    required this.user,
  });

  int id;
  int userId;
  String workplaceLongitude;
  String workplaceLatitude;
  String workplace;
  User user;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["user_id"],
        workplaceLongitude: json["workplace_longitude"],
        workplaceLatitude: json["workplace_latitude"],
        workplace: json["workplace"],
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "workplace_longitude": workplaceLongitude,
        "workplace_latitude": workplaceLatitude,
        "workplace": workplace,
        "user": user.toJson(),
      };
}

class User {
  User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.phone,
    required this.role,
    this.profile,
    this.uint8list,
  });

  int id;
  String fname;
  String lname;
  String email;
  String phone;
  String? profile;
  final int? role;
  Uint8List? uint8list;

  setImageBytes(User user) async {
    if (user.profile == null) {
      return uint8list = null;
    } else {
      final profileUrl =
          Constants.profileImage(user); // Assuming `user` is the user object
      print('profileUrl: $profileUrl');
      final response = await http.get(Uri.parse(profileUrl));

      uint8list = response.bodyBytes;
      print('uint8list: $uint8list');
    }
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fname: json["fname"],
        lname: json["lname"],
        email: json["email"],
        phone: json["phone"],
        profile: json["profile"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fname": fname,
        "lname": lname,
        "email": email,
        "phone": phone,
        "profile": profile,
        "role": role,
      };
}

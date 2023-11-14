import 'package:np_social/model/User.dart';

class Event {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? from_date;
  String? to_date;
  String? from_time;
  String? to_time;

  String? location;
  String? longitude;
  String? latitude;
  String? createdAt;
  User? user;
  Event(
      {this.id,
        this.userId,
        this.title,
        this.description,
        this.from_date,
        this.to_date,
        this.from_time,
        this.to_time,
        this.location,
        this.longitude,
        this.latitude,
        this.createdAt,
        this.user,
      });

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    from_date = json['from_date'];
    to_date = json['to_date'];
    from_time = json['from_time'];
    to_time = json['to_time'];

    location = json['location'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    createdAt = json['created_at'];
    user = User.fromJson(json['user']);
  }

}

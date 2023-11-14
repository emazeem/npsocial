import 'package:np_social/model/User.dart';

class Polls {
  int? id;
  int? userId;
  int? eventId;
  String? status;
  String? createdAt;
  String? updatedAt;
  User? user;

  Polls(
      {this.id,
        this.userId,
        this.eventId,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.user});

  Polls.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    eventId = json['event_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }
}
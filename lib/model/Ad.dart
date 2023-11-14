import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';

class Ad {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? type;
  String? image;
  String? video; 
  NpDateTime? createdAt;
  User? user;

  Ad(
      {this.id,
        this.userId,
        this.title,
        this.description,
        this.type,
        this.image,
        this.video, 
        this.createdAt,
        this.user
      });

  Ad.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    image = json['image'];
    video = json['video']; 
    createdAt = json['created_at'] != null ? new NpDateTime.fromJson(json['created_at']) : NpDateTime();
    user = json['user'] != null ? new User.fromJson(json['user']) : User();
  }

}



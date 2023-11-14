import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';

class CaseStudy {
  int? id;
  int? userId;
  String? title;
  String? pdf;
  String? image;
  String? body;
  NpDateTime? createdAt;
  User? user;

  CaseStudy({
    this.id,
    this.userId,
    this.title,
    this.pdf,
    this.image,
    this.body,
    this.createdAt,
    this.user,
  });

  factory CaseStudy.fromJson(Map<String, dynamic> json) => CaseStudy(
        id: json["id"] as int?,
        userId: json["user_id"] as int?,
        title: json["title"] as String?,
        pdf: json["pdf"] as String?,
        image: json["image"] as String?,
        body: json["body"] as String?,
        createdAt: json["created_at"] as NpDateTime?,
        user: json["user"]==null? User(): json["user"] as User,
      );
}


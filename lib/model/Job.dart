import 'package:np_social/model/User.dart';

class Job {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? location;
  String? skills;
  int? salary;
  int? yearsOfExperience; 
  bool? applied;
  List<User>? user;

  Job(
      {this.id,
      this.userId,
      this.title,
      this.description,
      this.location,
      this.skills,
      this.salary,
      this.yearsOfExperience, 
      this.applied,
      this.user});

  Job.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    location = json['location'];
    skills = json['skills'];
    salary = json['salary'];
    applied = json['applied'];
    yearsOfExperience = json['yearsOfExperience']; 
    if (json['user'] != null) {
      user = <User>[];
      json['user'].forEach((v) {
        user!.add(new User.fromJson(v));
      });
    }
  }}
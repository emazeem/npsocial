import 'package:np_social/model/User.dart';
class JobApplications {
  int? id;
  int? jobId;
  int? userId;
  String? cv;
  User? user;

  JobApplications(
      {this.id,
      this.jobId,
      this.userId,
      this.cv,
      this.user});

  JobApplications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jobId = json['job_id'];
    userId = json['user_id'];
    cv = json['cv']; 
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }
}
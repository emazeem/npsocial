
import 'package:np_social/model/User.dart';

class Speciality {
  final int? id;
  final int? status;
  final String? title;

  Speciality({
    this.id,
    this.status,
    this.title,
  });
  factory Speciality.fromJson(Map<String, dynamic> json) {
    return Speciality(
      id:json['id'] as int?,
      status:json['status'] as int?,
      title:json['title'] as String?,
    );
  }
}
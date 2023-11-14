import 'package:intl/intl.dart';

class License {
  final int? id;
  final int? auth_id;
  final int? user_id;
  final String? title;
  final String? number;
  final String? expiry_date;

  License({
    this.id,
    this.auth_id,
    this.user_id,
    this.title,
    this.number,
    this.expiry_date,
  });

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      id: json['id'] as int?,
      user_id: json['user_id'] as int,
      title: json['title'] as String?,
      number: json['number'] as String?,
      expiry_date: json['expiry'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id == null ? null : this.id.toString(),
      'auth_id': this.auth_id == null ? null : this.auth_id.toString(),
      'title': this.title,
      'number': this.number,
      'expiry': this.expiry_date,
    };
  }
}

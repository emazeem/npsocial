import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Speciality.dart';

class UserDetail {
  int? id;
  int? user_id;
  String? about;
  String? city;
  String? state;
  String? country;
  String? address;
  String? latitude;
  String? longitude;
  String? workplace_latitude;
  String? workplace_longitude;

  String? relationship;
  String? workplace;
  String? fax;
  String? hobbies;
  String? high_school;
  String? cover_photo;
  String? date_of_birth;
  String? npi;
  String? kyc_status;
  String? kyc_reject_reason;
  NpDateTime? created_at;
  Speciality? speciality;
  String? cp_name;
  String? cp_email;
  String? cp_phone;


  UserDetail(
      {this.id,
      this.user_id,
      this.about,
      this.city,
      this.state,
      this.country,
      this.address,
      this.longitude,
      this.latitude,
      this.workplace_longitude,
      this.workplace_latitude,

      this.relationship,
      this.workplace,
      this.fax,
      this.hobbies,
      this.high_school,
      this.cover_photo,
      this.date_of_birth,
      this.npi,
      this.kyc_status,
      this.kyc_reject_reason,
      this.created_at,
      this.speciality,


        this.cp_name,
        this.cp_email,
        this.cp_phone,


      });

  factory UserDetail.fromJson(Map<dynamic, dynamic> data) {
    return UserDetail(
      id: data['id'] as int?,
      user_id: data['user_id'] as int?,
      about: data['about'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      longitude: data['longitude'] as String?,
      latitude: data['latitude'] as String?,
      workplace_longitude: data['workplace_longitude'] as String?,
      workplace_latitude: data['workplace_latitude'] as String?,

      relationship: data['relationship'] as String?,
      high_school: data['high_school'] as String?,
      workplace: data['workplace'] as String?,
      fax: data['fax'] as String?,
      hobbies: data['hobbies'] as String?,
      cover_photo: data['cover_photo'] as String?,
      date_of_birth: data['date_of_birth'] as String?,
      npi: data['npi'] as String?,
      kyc_status: data['kyc_status'] as String?,
      kyc_reject_reason: data['kyc_reject_reason'] as String?,
      created_at: data['created_at'] as NpDateTime,
      speciality: data['speciality'] as Speciality?,
      address: data['address'] as String?,

      cp_name: data['cp_name'] as String?,
      cp_email: data['cp_email'] as String?,
      cp_phone: data['cp_phone'] as String?,
    );
  }
}

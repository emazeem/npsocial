class Privacy {
  String? email;
  String? phone;
  String? gender;
  String? fax;

  String? about;
  String? city;
  String? state;
  String? country;

  String? joining;
  String? workplace;
  String? university;
  String? hobbies;

  Privacy({
    this.email,
    this.phone,
    this.gender,
    this.fax,

    this.about,
    this.city,
    this.state,
    this.country,

    this.joining,
    this.workplace,
    this.university,
    this.hobbies,

  });

  factory Privacy.fromJson(Map<String, dynamic> json) {
    return Privacy(
      email : json['email']as String?,
      phone : json['phone']as String?,
      gender : json['gender']as String?,
      fax : json['fax']as String?,

      about :json['about']as String?,
      city: json['city']as String?,
      state : json['state']as String?,
      country : json['country']as String?,

      joining : json['joining']as String?,
      workplace : json['workplace']as String?,
      university : json['university']as String?,
      hobbies : json['hobbies']as String?,

    );
  }
}

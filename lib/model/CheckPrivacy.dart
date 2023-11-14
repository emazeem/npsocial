class CheckPrivacy {
  bool? email;
  bool? phone;
  bool? gender;
  bool? fax;

  bool? about;
  bool? city;
  bool? state;
  bool? country;

  bool? joining;
  bool? workplace;
  bool? university;
  bool? hobbies;


  CheckPrivacy({
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

  factory CheckPrivacy.fromJson(Map<String, dynamic> json) {
    return CheckPrivacy(

      email : json['email'] as bool?,
      phone : json['phone'] as bool?,
      gender : json['gender'] as bool?,
      fax : json['fax'] as bool?,

      about :json['about'] as bool?,
      city: json['city'] as bool?,
      state : json['state'] as bool?,
      country : json['country'] as bool?,

      joining : json['joining'] as bool?,
      workplace : json['workplace'] as bool?,
      university : json['university'] as bool?,
      hobbies : json['hobbies'] as bool?,

    );
  }
}

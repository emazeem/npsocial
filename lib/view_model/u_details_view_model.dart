import 'package:flutter/cupertino.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Speciality.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/directories/u_details_repo.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';

class UserDetailsViewModel extends ChangeNotifier {

  
  UserDetail? detailsResponse=UserDetail();
  UserDetailRepo _detailsRepo=UserDetailRepo();

  UserDetail? get getDetails => detailsResponse;
  void setDetailsResponse(UserDetail newDetails) {
    detailsResponse = newDetails;
    notifyListeners();
  }
  UserDetailsViewModel({this.detailsResponse});

  Future getUserDetails(dynamic data,String token) async {
    int role=await AppSharedPref.getAuthRole();
    try{
      dynamic response=await _detailsRepo.getUserDetailsApi(data,token);
      dynamic resp=response['data'];
      UserDetail? _userDetail=UserDetail();
      resp['created_at']=NpDateTime.fromJson(resp['created_at']);
      if(role==Role.User){
        if (resp['speciality'].toString() != '[]') {
          resp['speciality']=Speciality.fromJson(resp['speciality']);
        } else {
          resp['speciality']=Speciality();
        }
      }else{
        resp['speciality']=Speciality();
      }
      _userDetail=UserDetail.fromJson(resp);
      detailsResponse=_userDetail;
    }catch(e){
      print(e);
    }
    notifyListeners();
  }


  Future updateSocialInfo(dynamic data,String token) async {
    dynamic response=await _detailsRepo.updateSocialInfoApi(data,token);
    return response;
  }
  Future updateLocation(dynamic data,String token) async {
    dynamic response=await _detailsRepo.updateSocialInfoApi(data,token);
    return response;
  }



  Future updateSpeciality(dynamic data,String token) async {
    dynamic response=await _detailsRepo.updateSpecialityApi(data,token);
    return response;
  }

  List<Speciality>? specialities=[];
  List<Speciality>? get getSpecialities => specialities;
  void setSpecialities(List<Speciality>? data) {
    specialities = data;
    notifyListeners();
  }

  Future fetchSpecialities(dynamic data,String token) async {
    try{
      dynamic response=await _detailsRepo.getSpecialitiesApi(data,token);
      List<Speciality>? _specialities=[];
      response['data'].forEach((item) {
        _specialities.add(Speciality(id: item['id'],title: item['title']));
      });
      specialities=_specialities;
      notifyListeners();
    }catch(e){
      print(e);
      notifyListeners();
    }
  }

}

class OtherUserDetailsViewModel extends ChangeNotifier {


  UserDetail? otherDetailsResponse = UserDetail();
  UserDetailRepo _detailsRepo = UserDetailRepo();

  UserDetail? get getOtherUserDetails => otherDetailsResponse;

  void setDetailsResponse(UserDetail newDetails) {
    otherDetailsResponse = newDetails;
    notifyListeners();
  }

  Future getOtherUserDetail(dynamic data, String token) async {
    try {
      dynamic response = await _detailsRepo.getUserDetailsApi(data, token);
      dynamic resp = response['data'];
      UserDetail? _userDetail = UserDetail();

      resp['created_at'] = NpDateTime.fromJson(resp['created_at']);
      if(resp['speciality']==null){
        resp['speciality'] = Speciality();
      }else{
        if (resp['speciality'].toString() != '[]') {
          resp['speciality'] = Speciality.fromJson(resp['speciality']);
        } else {
          resp['speciality'] = Speciality();
        }
      }
      _userDetail = UserDetail.fromJson(resp);
      otherDetailsResponse = _userDetail;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }
}
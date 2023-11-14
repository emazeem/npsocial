import 'package:flutter/material.dart';
import 'package:np_social/model/CaseStudy.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/casestudy_repo.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/utils/utils.dart';

class CaseStudyViewModel extends ChangeNotifier {
  CaseStudy caseStudyResponse = CaseStudy();
  CaseStudyRepo _caseStudyRepo = CaseStudyRepo();

  ApiResponse _fetchCaseSudyStatus = ApiResponse();

  ApiResponse get getCaseStudyStatus => _fetchCaseSudyStatus;

  List<CaseStudy?> _allCaseStudies = [];

  List<CaseStudy?> get getallCaseStudies => _allCaseStudies;

  void setallcaseStudies(List<CaseStudy> _casestudies) {
    _allCaseStudies = _casestudies;
    notifyListeners();
  }

//Fetch Case Studies
  Future fetchCaseStudy(dynamic data, String token) async {
    _fetchCaseSudyStatus = ApiResponse.loading('Fetching Case Studies');
    try {
      final response = await _caseStudyRepo.getCaseStudy(data, token);

      List<CaseStudy?> myCaseStudies = [];

      response['data'].forEach((item) {
        print(item);
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        item['user'] = User.fromJson(item['user']);
        myCaseStudies.add(CaseStudy.fromJson(item));
      });

      _allCaseStudies = myCaseStudies;
      _fetchCaseSudyStatus = ApiResponse.completed(_allCaseStudies);
      notifyListeners();
    } catch (e) {
      print(e);
      _fetchCaseSudyStatus = ApiResponse.error('Please try again.!');
    }
  }

  bool _iscaseStudyLoading = false;

  //Store Case Study
  // Future storeCaseStudy(CaseStudy caseStudy, String token) async {
  //   setLoaderValue(value: true);
  //   final data = caseStudy.toMap();

  //   final response = await caseStudyRepo.storeCaseStudy(data, token);
  //   try {
  //     setLoaderValue();
  //     return response;
  //   } catch (e) {
  //     print(response);
  //     setLoaderValue();
  //     rethrow;
  //   }
  // }

    Future deleteCaseStudy(dynamic data, String token) async {
    dynamic response = await NetworkApiServices().getPostAuthApiResponse(AppUrl.deleteCaseStudy,data, token);
    try {
      Utils.toastMessage('Case Study Deleted');
    } catch (e) {
      Utils.toastMessage('${response['message']}');
    }
  }

  void setLoaderValue({bool value = false, String loader = 'store'}) {
    if (loader == 'store') {
      _iscaseStudyLoading = value;
    } else {
      _iscaseStudyLoading = value;
    }

    notifyListeners();
  }
}

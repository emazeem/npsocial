// import 'package:flutter/material.dart';
// import 'package:np_social/model/Ad.dart';
// import 'package:np_social/model/apis/api_response.dart';
// import 'package:np_social/model/services/BaseApiServices.dart';
// import 'package:np_social/res/app_url.dart';
// import 'package:np_social/shared_preference/app_shared_preference.dart';

// import '../model/services/NetworkApiServices.dart';
// import '../utils/Utils.dart';

// class AdViewMdoel extends ChangeNotifier {
//   Ad? adResponse = Ad();
//   BaseApiServices _apiServices = NetworkApiServices();

//   ApiResponse _fetchAdStatus = ApiResponse();

//   ApiResponse get getAdStatus => _fetchAdStatus;

 

//   //register ad visible
//   Future registerImpression(dynamic data) async {
//     print('registerImpression' + data.toString());
//     var  authToken = await AppSharedPref.getAuthToken();  
//     try {
//       final response = await _apiServices.getPostAuthApiResponse(AppUrl.registerImpression,data, authToken);
//       print(response);
//       return response;
//     }
//     catch (e) {
//       print(e);
//       Utils.toastMessage('Something went wrong');
//     }

     
//   }

 

 

 

 

 

// }
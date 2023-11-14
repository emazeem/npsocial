import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class CaseStudyRepo {
  BaseApiServices _apiServices = NetworkApiServices();

  //Store Case Study
  Future<dynamic> storeCaseStudy(data, token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.storeCaseStudy, data, token);
      Map res = {
        'sent': true,
        'message': response['message'],
        'data': response['data'],
      };

      return res;
    } catch (e) {
      Map res = {
        'sent': false,
        'message': e.toString(),
      };
      return res;
    }
  }

  //get Case Study
  Future<dynamic> getCaseStudy(data, token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.fetchCaseStudy, data, token);
      Map res = {
        'sent': true,
        'message': response['message'],
        'data': response['data']
      };

      return res;
    } catch (e) {
      Map res = {
        'sent': false,
        'message': e.toString(),
      };
      return res;
    }
  }
}

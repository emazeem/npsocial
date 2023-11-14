import 'package:flutter/material.dart';
import 'package:np_social/model/Job.dart';
import 'package:np_social/model/JobDetials.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';

class JobViewModel extends ChangeNotifier {
  NetworkApiServices _apiServices = NetworkApiServices();
  ApiResponse _status = ApiResponse();

  ApiResponse get status => _status;
  List<Job>? _jobsList = [];
  List<Job>? get getJobsList => _jobsList;  
  JobDetails? _jobDetails;
  JobDetails? get getJobDetails => _jobDetails;

  Future<bool> createJob(dynamic data) async {
    final authToken = await AppSharedPref.getAuthToken(); 
    try {
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.storeJob, data, authToken);
      if (response['data'] == true) {
        return true;
        
      }else{
        return false;
      }
      
    } catch (e) {
      return false;
    }
  }

  bool _noJob = false;
  bool get getNoJob => _noJob;

Future<bool> fetchJobdetails(dynamic data) async { 
  print ('data : ${data}');
      _jobDetails = null;
    final authToken = await AppSharedPref.getAuthToken(); 
    try {
      print ('working1 ');
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchJobDetails, data, authToken);

     
        if (response['data'] == null ){
          print(response['data'].toString());
        print ('working ');
        _noJob = true;
       
        notifyListeners();
        return true;
      }

      if (response['data'] != null) {
        _jobDetails = JobDetails.fromJson(response['data']);
      }
    
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<List<dynamic>> fetchJobs() async {
    _jobsList!.clear();
    final authToken = await AppSharedPref.getAuthToken();
    try {
      final response = await _apiServices.getPostAuthApiResponse( AppUrl.fetchJobs, null,authToken); 
      var allJobs = response['data'];
      for (var job in allJobs){
        _jobsList!.add(Job.fromJson(job));
      }

      return response;
    } catch (e) {
      return [];
    }
  }
  Future<bool> updateJob(dynamic data) async {
    final authToken = await AppSharedPref.getAuthToken(); 
    try {
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.updateJob, data, authToken); 
      if (response['data'] == true) {
        return true;
      }else{
        return false;
      }
    
    } catch (e) {
      return false;
    }
    }
    Future<bool> deleteJob(dynamic data) async {
    final authToken = await AppSharedPref.getAuthToken(); 
    try {
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.deleteJob, data, authToken);
      print(response);
      
      return true;
      } catch (e) {
        print (e);
        return false;
        }
    }

    
}

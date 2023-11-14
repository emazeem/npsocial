
import 'package:np_social/model/Job.dart';
import 'package:np_social/model/JobApplications.dart';

class JobDetails {
  Job? job;
  List<JobApplications>? applications;

  JobDetails({this.job, this.applications});

  JobDetails.fromJson(Map<String, dynamic> json) {
    job = json['job'] != null ? new Job.fromJson(json['job']) : null;
    if (json['applications'] != null) {
      applications = <JobApplications>[];
      json['applications'].forEach((v) {
        applications!.add(new JobApplications.fromJson(v));
      });
    }
  } 
  }
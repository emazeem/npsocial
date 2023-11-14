import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_social/model/JobApplications.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/view_model/user_view_model.dart'; 
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:np_social/res/app_url.dart';


import 'package:np_social/model/JobDetials.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/jobposting/show_jobs.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view_model/job_view_model.dart'; 
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../utils/Utils.dart';


class JobDetailScreen extends StatefulWidget {
  final int? jobId;


  const JobDetailScreen({ this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  var authToken;
  var authId;
  String? _selectedFileName;
  bool _isFileSelected = false;
  File? _selectedFile ;
  bool _isLoading = false;
  int _isUploading = 0;
  bool _isRecruiter = false;
  JobDetails? jobDetails;
  JobViewModel _jobViewModel = JobViewModel();
 bool _isJobempty = false;


  void _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','*'],
      
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      double temp = file.lengthSync() / (1024 * 1024);
      if (temp > 10) {
        Utils.toastMessage('File size should be less than 10 MB');
      } else if (file.path.split('.').last != 'pdf') {
          Utils.toastMessage('File type should be pdf');
        } 
        else {
        setState(() {
          _selectedFile = file;
          _isFileSelected = true;
          _selectedFileName = basename(file.path);
        });
    }} else {
      Utils.toastMessage('File not selected?');
    }
  }
  fetchData()async{
   
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId(); 
      Map data= { "id":widget.jobId.toString()};
      print ('data : ${data}');
        setState((){ 
          _isLoading = true;
          });
      await _jobViewModel.fetchJobdetails(data);
      _isJobempty = _jobViewModel.getNoJob;
      print ('isjobempty1 : ${_isJobempty}');
      jobDetails =  _jobViewModel.getJobDetails;

   
      setState(() {
        _isRecruiter = authId == jobDetails?.job?.userId ? true : false;
      });
      setState(() {
        _isLoading = false;
      });
    
  }
  @override
  void initState() {
  
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await fetchData();
      });
  super.initState();
  }
  retriveSkills(String skills){
    // ignore: unnecessary_null_comparison
    if (skills == null) {
      return [];
    }else if (skills.contains(',')) {
      return skills.split(',');
    }else{
      return [skills];
    }

  
  }

  @override
Widget build(BuildContext context) {
List<String> jobskills = retriveSkills( jobDetails?.job?.skills ?? ''); 


   setState(() {
        _isJobempty = _jobViewModel.getNoJob;
        print ('isjobempty : ${_isJobempty}');
      
      });
      
  return   Scaffold(
      appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      title: Constants.titleImage(),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
    ),
    body:
         _isLoading == true
        ? Utils.LoadingIndictorWidtet()
        :_isJobempty== true?Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.network(
                  '${Constants.noPostImage}',
                  width: 200,
                  height: 200,
                )
              ),
            ),
           
            Text('This post is no longer available. ',style: TextStyle(fontSize: 20,color: Colors.black45),
            ),
          ],
        ): SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                  Container(
                    height: MediaQuery.of(context).size.height * 0.44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Constants.np_yellow, Constants.np_yellow],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.6,
                          child: Image.asset(
                            'assets/images/hiring.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text( 
                                '${jobDetails?.job?.title}' ,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                               InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> OtherProfileScreen(jobDetails?.job?.user!.first.id )));
                                  },
                                 child: Text( 
                                  '${jobDetails?.job?.user?.first.fname} ${jobDetails?.job?.user?.first.lname}' ,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  ),
                               ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  SizedBox(width: 1),
                                  Text(
                                    '${jobDetails?.job?.location}' ,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
               
                
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${jobDetails?.job?.description}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Salary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "USD " +   NumberFormat('#,##0').format(jobDetails?.job?.salary) ,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Experience",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${jobDetails?.job?.yearsOfExperience?.toString()}' + " years",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Skills",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8), 
                        Container(
                          height: 40,
                          child: ListView.builder(
                            itemCount: jobskills.length,
                            shrinkWrap: true,
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              if (jobskills[index].isEmpty) {
                                return Container();
                              }
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding:EdgeInsets.only(
                                    right: 8,
                                  ),
                                  child: Chip(
                                    label: Text(
                                      jobskills[index].trim(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ), 
                                    backgroundColor: Constants.np_yellow,
                                  ),
                                ),
                              );
                            },
                          
                          ),
                        ),
                        SizedBox(height: 8),
                        if (_isFileSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedFileName ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isFileSelected = false;
                                      _selectedFileName = null;
                                    });
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 16),
                        _isRecruiter == true ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Applicants:", style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                ),
                                Text('No of Applicants: '+'${jobDetails?.applications?.length.toString()}',style: TextStyle(fontSize: 16, color: Colors.black,),),
                              ],
                            ),
                            Container(height: 10,),
                            jobDetails!.applications!.length> 0 ?
                             Container(
                              height: MediaQuery.of(context).size.height*0.4,
                              child: ListView.builder(itemCount: jobDetails?.applications?.length,
                                itemBuilder: (BuildContext context, int index) {
                                return JobApplicantCard(jobApplicant: jobDetails?.applications?[index],);},
                              ),
                             ) : Text('No Applicant',style: TextStyle(fontSize: 16, color: Colors.grey[700],),),
                          ],
                        ):
                        Align(
                          alignment: Alignment.centerRight,
                          child: _isUploading == 0
                              ?jobDetails?.job?.applied == true  ?
                               Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('Applied!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),),
                                   SizedBox(width: 4,),
                                Icon(Icons.check,color: Colors.green,),
                                
                                ],
                              ): ElevatedButton(
                                  onPressed: () {
                                    if (_isFileSelected) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      uploadFile(context);
                                    } else {
                                      _pickPdfFile();
                                    }
                                  },
                                  child:  Text(
                                    _isFileSelected ? 'Apply Now' : 'Upload CV',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constants.np_yellow,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                     vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
  );
}



Dio dio = new Dio();
  uploadFile(context) async {
    String uploadUrl = AppUrl.applyJob;
    var formData;
    if(_selectedFileName != null){
      setState(() {
        _isUploading = 1;
      }); 
      formData = FormData.fromMap(
        { 
          'job_id':  jobDetails?.job?.id,
          'user_id': authId,
          'cv':  await MultipartFile.fromFile(_selectedFile!.path,filename: basename(_selectedFile!.path)),
        },
        
      );
    } else {
      Utils.toastMessage('Please select pdf');
      return;
      }

    Response response = await dio.post(
      uploadUrl,
      data: formData,
      options: Options(
        headers: {
          "Accept": "application/json",
          'Authorization': "Bearer " + authToken
        },
        receiveTimeout: 200000,
        sendTimeout: 200000,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    setState(() {
      _isUploading = 0;
    });
    if (response.statusCode == 200) {
      Utils.toastMessage('Applied successfully');
      setState(() {
        _selectedFile = null;
        _selectedFileName = null;
        _isFileSelected = false;
        _isLoading = false;
        
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ShowJobsScreen()));
    } else { 
      Utils.toastMessage('Error during connection to server.');
    }
  }
 }

class JobApplicantCard extends StatelessWidget {
  const JobApplicantCard({
    super.key,
    required this.jobApplicant,
  });

  final JobApplications? jobApplicant;
Future<void> _launchInBrowser(Uri url) async {
    if (Platform.isAndroid) {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    } else {
      
      final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
      if (await launcher.canLaunch(url.toString())) {
        await launcher.launch(
          url.toString(),
          useSafariVC: true,
          useWebView: true,
          enableJavaScript: true,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: <String, String>{'my_header_key': 'my_header_value'},
        );
      } else {
        throw 'Could not launch $url';
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          border:Border(
            bottom: BorderSide(color: Colors.grey.shade400)
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherProfileScreen(
                        jobApplicant?.user?.id,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      Utils.LoadingIndictorWidtet(),
                  errorWidget: (context, url, error) => Constants.defaultImage(40.0),
                  imageUrl: "${Constants.profileImage( jobApplicant!.user)}",
                  imageBuilder: (context, imageProvider) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.0),
              Text(
                '${jobApplicant?.user?.fname?.toString()}.' + " " + '${jobApplicant?.user?.lname?.toString()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  _launchInBrowser(Uri.parse(AppUrl.url +'/storage/job-cv/' + jobApplicant!.cv!));
                },
                child: Icon(
                  Icons.picture_as_pdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


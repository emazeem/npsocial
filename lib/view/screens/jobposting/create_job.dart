import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/job_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class CreateJobScreen extends StatefulWidget {
  @override
  _CreateJobScreenState createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  var authToken;
  var authId;

  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _jobLocationController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _jobDescriptionController = TextEditingController();
  TextEditingController _yearsOfExperienceController = TextEditingController();
  TextEditingController _skillsController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();
  bool _isLoading = false; 
  bool _isJobPostButtonClicked = false;
  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobLocationController.dispose();
    _companyNameController.dispose();
    _jobDescriptionController.dispose();
    _yearsOfExperienceController.dispose();
    _skillsController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _isLoading = true;
      });
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Provider.of<UserViewModel>(context, listen: false).setUser(User());
      Map data = {'id': '$authId'};
      await Provider.of<UserViewModel>(context, listen: false)
          .getUserDetails(data, '$authToken');
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);
    User? user = userViewModel.getUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Constants.titleImage(),leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: _isLoading
          ? Utils.LoadingIndictorWidtet()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                        Row(
                      children: [
                         Constants.defaultImage(40.0),
                        SizedBox(width: 16.0),
                        user != null
                            ? Text(
                               user.fname == null ? "" :  user.fname.toString() + " " ,
                                style: TextStyle(fontSize: 16.0),
                              )
                            : SizedBox.shrink(), 
                            user?.role == Role.User
                            ? Text(
                               user?.lname == null ? "" :  user!.lname.toString() ,
                                style: TextStyle(fontSize: 16.0),
                              )
                            : SizedBox.shrink(), 
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Divider(height: 1, color: Colors.grey),
                      ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _jobTitleController,
                      keyboardType: TextInputType.text,
                      maxLength: 50, 
                      decoration: InputDecoration(
                        labelText: 'Job Title',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _jobDescriptionController,
                      maxLines: 10,
                      minLines: 1,
                      maxLength: 5000, 
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Job Description',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _jobLocationController,
                      keyboardType: TextInputType.text,
                      maxLength: 50, 
                      decoration: InputDecoration(
                        labelText: 'Job Location',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _yearsOfExperienceController,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Years of Experience',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _skillsController,
                      maxLength: 200,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Skills Required (must be Comma Separated)',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Salary',
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _isJobPostButtonClicked ==false ?
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text('Post Job'),
                          onPressed: () async {
                              setState(() {
                                _isJobPostButtonClicked = true;
                              });
                            if (_jobTitleController.text.isEmpty) {
                              Utils.toastMessage("Please enter job title");
                              setState(() {
                              _isJobPostButtonClicked = false;
                            });
                            return;
                            }  else if (_jobDescriptionController.text.isEmpty) {
                              Utils.toastMessage("Please enter job description");
                              setState(() {
                              _isJobPostButtonClicked = false;
                            });
                            return;
                            }else if (_jobLocationController.text.isEmpty) {
                              Utils.toastMessage("Please enter job location");
                              setState(() {
                              _isJobPostButtonClicked = false;
                            });
                            return;
                            } else if (_yearsOfExperienceController.text.isEmpty) {
                              Utils.toastMessage("Please enter years of experience");
                              setState(() {
                              _isJobPostButtonClicked = false;
                            });
                            return;
                            } else if (_skillsController.text.isEmpty) {
                              Utils.toastMessage("Please enter skills");
                              setState(() {
                              _isJobPostButtonClicked = false;
                            });
                            return;
                            } else if (_salaryController.text.isEmpty) {
                              Utils.toastMessage("Please enter salary");
                              setState(() {
                              _isJobPostButtonClicked = false;
                            });
                            return;
                            } else {
                              Map data = {
                                'title': _jobTitleController.text,
                                'location': _jobLocationController.text,
                                'company_name': user?.fname ?? '',
                                'description': _jobDescriptionController.text,
                                'yearsOfExperience': _yearsOfExperienceController.text,
                                'skills': _skillsController.text,
                                'salary': _salaryController.text,
                              };
                            
                              var storeJob = await Provider.of<JobViewModel>(
                                context,
                                listen: false,
                              ).createJob(data);
                              if (storeJob == true) {
                                Utils.toastMessage("Job posted successfully");
                                Navigator.pop(context);
                              } else {
                                Utils.toastMessage("Something went wrong");
                                setState(() {
                                  _isJobPostButtonClicked = false;
                                });
                              }
                            }
                          },
                        ):Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            width: 30,
                            child: Utils.LoadingIndictorWidtet(),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

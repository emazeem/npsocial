import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:np_social/model/Job.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/job_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../../model/User.dart';

class EditJobScreen extends StatefulWidget {
  final Job job;
  

  EditJobScreen({required this.job});

  @override
  _EditJobScreenState createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _jobLocationController = TextEditingController();
  TextEditingController _jobDescriptionController = TextEditingController();
  TextEditingController _yearsOfExperienceController = TextEditingController();
  TextEditingController _skillsController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();
  bool _isLoading = false;
  var authToken;
  var authId;
  User? authUser;
  bool _isJobPostButtonClicked = false;


  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobLocationController.dispose();
    _jobDescriptionController.dispose();
    _yearsOfExperienceController.dispose();
    _skillsController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async { 
      authToken = await AppSharedPref.getAuthToken(); 
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};
      Provider.of<UserViewModel>(context, listen: false)
          .getUserDetails(data, '${authToken}');
    });
     _jobTitleController.text = widget.job.title?? '';
    _jobLocationController.text = widget.job.location ?? '';
    _jobDescriptionController.text = widget.job.description ?? '';
    _yearsOfExperienceController.text = widget.job.yearsOfExperience.toString();
    _skillsController.text = widget.job.skills ?? '';
    _salaryController.text = widget.job.salary.toString();
    super.initState();
    
   
  }

  @override
  Widget build(BuildContext context) {
    JobViewModel jobViewModel = Provider.of<JobViewModel>(context);
   authUser = Provider.of<UserViewModel>(context).getUser;
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
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                         Constants.defaultImage(40.0),
                        SizedBox(width: 16.0),
                        widget.job.user != null
                            ? Text(
                                authUser!.fname! + ' ' + authUser!.lname!
                                ,style: TextStyle(fontSize: 16.0),
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
                      maxLength: 500, 
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
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
                        labelText: 'Skills Required (must be Comma Separated))',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 8,
                      decoration: InputDecoration(
                        labelText: 'Salary',
                      ),
                    ),
                    SizedBox(height: 24.0),
                    _isJobPostButtonClicked == false ?ElevatedButton(
                      child: Text('Save Changes',
                       style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, 
                       color: Constants.np_yellow,),
                       textAlign: TextAlign.center,
                       ),
                      style:
                      ElevatedButton.styleFrom( backgroundColor: Colors.black, padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      onPressed: () async {
                       setState(() {
                                _isJobPostButtonClicked = true;
                              });
                        // Validate input fields
                        if (_jobTitleController.text.isEmpty) {
                          Utils.toastMessage("Please enter job title");
                          setState(() {
                            _isJobPostButtonClicked = false;
                            });
                          return;
                        }
                        if (_jobLocationController.text.isEmpty) {
                          Utils.toastMessage("Please enter job location");
                          setState(() {
                            _isJobPostButtonClicked = false;
                            });
                          return;
                        }
                        if (_jobDescriptionController.text.isEmpty) {
                          Utils.toastMessage("Please enter job description");
                          setState(() {
                              _isJobPostButtonClicked = false;
                            });
                          return;
                        }
                        if (_yearsOfExperienceController.text.isEmpty) {
                          Utils.toastMessage("Please enter years of experience");
                          setState(() {
                              _isJobPostButtonClicked = false;
                            });
                          return;
                        }
                        if (_skillsController.text.isEmpty) {
                          Utils.toastMessage("Please enter skills");
                          setState(() {
                              _isJobPostButtonClicked = false;
                            });
                          return;
                        }
                        if (_salaryController.text.isEmpty) {
                          Utils.toastMessage("Please enter salary");
                          setState(() {
                              _isJobPostButtonClicked = false;
                            });
                          return;
                        } 
                    
                        // Create updated job object
                         Map data = {
                                'id': widget.job.id.toString(),
                                'title': _jobTitleController.text,
                                'location': _jobLocationController.text,
                                'company_name': authUser?.fname ?? '',
                                'description': _jobDescriptionController.text,
                                'yearsOfExperience': _yearsOfExperienceController.text,
                                'skills': _skillsController.text,
                                'salary': _salaryController.text,
                              };

                        // Save the changes or update the job
                        setState(() {
                          _isLoading = true;
                        });
                     

                        bool success =await  jobViewModel.updateJob(data);

                        setState(() {
                          _isLoading = false;
                        });

                        if (success) {
                          Utils.toastMessage("Job updated successfully");
                          Navigator.pop(context);
                        } else {
                          Utils.toastMessage("Failed to update job");
                           setState(() {
                          _isJobPostButtonClicked = true;
                        });
                        }
                      },
                    ):Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            width: 30,
                            child: Utils.LoadingIndictorWidtet(),
                          ),
                        ),
                  ],
                ),
              ),
            ),
    );
  }
}

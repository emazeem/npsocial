// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:np_social/model/Job.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/jobposting/create_job.dart';
import 'package:np_social/view/screens/jobposting/edit_job.dart';
import 'package:np_social/view/screens/jobposting/job_detail.dart';
import 'package:np_social/view/screens/other_profile.dart'; 
import 'package:np_social/view_model/job_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart'; 
import '../../../shared_preference/app_shared_preference.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';



class ShowJobsScreen extends StatefulWidget {
  ShowJobsScreen({Key? key}) : super(key: key);

  @override
  State<ShowJobsScreen> createState() => _ShowJobsScreenState();
}

class _ShowJobsScreenState extends State<ShowJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Job>? allJobs = [];
  List<Job>? myJobs = [];
  var authToken;
  var authId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    authToken = await AppSharedPref.getAuthToken();
    authId = await AppSharedPref.getAuthId();
    await Provider.of<JobViewModel>(context, listen: false).fetchJobs();
    allJobs = Provider.of<JobViewModel>(context, listen: false).getJobsList;
    setState(() {
      
      myJobs = allJobs!.where((job) => job.userId == authId).toList();
      _isLoading = false;
    });
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        bottom: TabBar(
          indicatorColor: Constants.np_yellow,
          indicatorWeight: 2.5,
          controller: _tabController,
          labelColor: Colors.black,
          tabs: [
            Tab(text: 'All Jobs',),
            Tab(text: 'My Jobs'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Utils.LoadingIndictorWidtet(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                buildJobsList(allJobs),
                buildJobsList(myJobs), 
                ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push( context,MaterialPageRoute(builder: (context) => CreateJobScreen(),),
          ).then((value) => refreshData());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5.0,
      ),
    );
  }

  Widget buildJobsList(List<Job>? jobs) {
    return jobs!.isEmpty
        ? Center(
            child: Text('No jobs found!'),
          )
        : SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[jobs.length - 1 - index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailScreen(
                                jobId: job.id!, 
                              ),
                            ),
                          ).then((value) => refreshData());
                        },
                        child: JobShowWidget(
                          job: job,
                          authId: authId,
                          onDelete: () => refreshData(),
                          token: authToken,
                        ),
                      );
                    },
                  ),
              ),
              Container(height: MediaQuery.of(context).size.height * 0.1,color: Colors.transparent,)

            ],
          ),
        );
  }
}

String retriveSkills(String skills){ 
  String skill = '';
  List<String> skillsList = skills.split(',');
  for(int i = 0; i < skillsList.length; i++){
    if (i == skillsList.length - 1) skill += skillsList[i].trim() + '';
    else
    skill += skillsList[i].trim() + ','; 
  
  }
  return skill;
}

class JobShowWidget extends StatefulWidget {

  Job job ;
  var authId;
  var token;
  final VoidCallback onDelete;
  JobShowWidget({required this.job,required this.authId,  required this.onDelete,required this.token}); 

  @override
  State<JobShowWidget> createState() => _JobShowWidgetState();
}


class _JobShowWidgetState extends State<JobShowWidget> {
 @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    Map data = {'id': '${widget.job.userId}'};
   
   await Provider.of<UserViewModel>(context,listen: false).getUserDetails(data, widget.token);
    super.initState();
  }
  );
  }
 
  @override
  Widget build(BuildContext context) {
    String jobskills = retriveSkills( widget.job.skills ?? ''); 
    JobViewModel jobViewModel = Provider.of<JobViewModel>(context);
   
    _showDeleteDialog(Job job,BuildContext context1,) {
    showAnimatedDialog(
      context: context1,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClassicGeneralDialogWidget(
          positiveText: 'Delete',
          negativeText: 'Cancel',
          titleText: 'Warning',
          contentText: 'Are you sure you want to delete this job?',
          onPositiveClick: () async {

            Map data = {
              'id': job.id.toString(),
            };
             await jobViewModel.deleteJob(data);
              widget.onDelete(); // Call the onDelete callback to refresh the screen
              Navigator.of(context).pop();
            
          },
          onNegativeClick: () {
            Navigator.of(context).pop();
          },
        );
      },
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1), );
}
    return Card(
  elevation: 4,
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              placeholder: (context, url) => Utils.LoadingIndictorWidtet(),
              errorWidget: (context, url, error) => Constants.defaultImage(40.0),
              imageUrl: "${Constants.profileImage(widget.job.user!.first)}",
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
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherProfileScreen(
                             widget.job.userId!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                     '${widget.job.user!.first.fname} ${widget.job.user!.first.lname} ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.job.description!,
                    maxLines: 3 ,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],

                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                      SizedBox(width: 4),
                      Text(
                        widget.job.location!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ), //add Salary
      Row( 
        crossAxisAlignment: CrossAxisAlignment.end ,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "Salary:",
                          style: TextStyle(
                            fontSize: 15, 
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(" \$" +NumberFormat('#,##0').format(widget.job.salary!), 
                          style: TextStyle(
                            fontSize: 15, 
                            color: Colors.black,
                            
                          ),
                        ),
                      ],
                    ),
                  ),
                      
                   Padding(
                     padding: const EdgeInsets.only(
                        top: 8.0,
                     ),
                     child: Row(
                       children: [
                         Text(
                          "Experience: ",
                          style: TextStyle(
                            fontSize: 15, 
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                          Text(
                            widget.job.yearsOfExperience!.toString()+" year",
                            style: TextStyle(
                              fontSize: 15, 
                              color: Colors.black,
                            ),
                          ),
                       ],
                     ),
                   ),
                   SizedBox(
                      height: 8,
                    
                   ),
                  Text(
                    'Skills:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                Text(
                      jobskills,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                  SizedBox(height: 13),
                ],
              ),
            ),
          ), 
          Expanded(
            flex: 1,
                child: Padding(
                  padding:  EdgeInsets.only(
                   left: 16.0,
                   bottom: 10, 
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      widget.job.userId == widget.authId
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditJobScreen(job: widget.job),
                                  ),
                                ).then((value) => {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowJobsScreen(),
                                    ),
                                  ),
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Constants.np_yellow,
                                  ),
                                ),
                              ),
                              
                            )
                          : Container(),
                      SizedBox(width: 8),
                      widget.job.userId == widget.authId
                          ? InkWell(
                              onTap: () {
                                _showDeleteDialog(widget.job, context);
                               
                              },
                              child:  Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "Delete",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Constants.np_yellow,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      widget.job.userId == widget.authId
                          ? Container()
                          : widget.job.applied ==true ?Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Text('Applied',
                                    style:TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],

                                    )
                                ),
                                SizedBox(width: 4,),
                            
                                Icon(Icons.check,color: Colors.green,),
                              ],
                            )
                          ):
                          widget.job.userId == widget.authId
                          ?
                          Container(): TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobDetailScreen(jobId: widget.job.id!),
                                  ),
                                );
                              },
                              child: Text(
                                "Apply",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    ],
  ),
)
;
  }
}
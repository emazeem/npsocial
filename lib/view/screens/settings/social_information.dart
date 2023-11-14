import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/utils.dart';
import 'package:np_social/view/screens/settings/home_location.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SocialInformationScreen extends StatefulWidget {
  const SocialInformationScreen({Key? key}) : super(key: key);

  @override
  State<SocialInformationScreen> createState() => _SocialInformationScreenState();
}

class _SocialInformationScreenState extends State<SocialInformationScreen> {
  var authToken;
  var authId;



  final _aboutController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _faxController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _highSchoolController = TextEditingController();
  final _mobileController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<UserViewModel>(context, listen: false).setUser(User());
      Provider.of<UserDetailsViewModel>(context, listen: false).setDetailsResponse(UserDetail());

      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};
      Provider.of<UserViewModel>(context, listen: false).getUserDetails(data, '${authToken}');
      Provider.of<UserDetailsViewModel>(context, listen: false).getUserDetails(data, '${authToken}');

    });
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _faxController.dispose();
    _hobbiesController.dispose();
    _highSchoolController.dispose();
    _mobileController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);
    var userDetailViewModel =
    Provider.of<UserDetailsViewModel>(context, listen: false);
    User? user = userViewModel.getUser;
    UserDetail? userDetail =
        Provider.of<UserDetailsViewModel>(context, listen: false).getDetails;

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
      ),
      body: Container(
          color: Constants.np_bg_clr,
          child: Padding(
            padding: EdgeInsets.only(
                left: Constants.np_padding_only,
                right: Constants.np_padding_only,
                top: Constants.np_padding_only),
            child: ListView(
              children: [
                Card(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          EdgeInsets.only(left: 20, top: 20, bottom: 10),
                          child: Text(
                            'Edit Social Information',
                            style: Constants().np_heading,
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(user!.fname!=null)...[
                                inputWidget('First Name', _firstNameController, '${user!.fname}',30),
                                inputWidget('Last Name', _lastNameController, user!.lname,30),

                                inputWidget('About', _aboutController, (userDetail!.about.toString() != null) ? userDetail!.about : '',null),
                                phoneWidget('Fax', _faxController, '${userDetail.fax}',false),
                                phoneWidget('Phone', _mobileController, '${user.phone}',true),
                                inputWidget('University', _highSchoolController, '${userDetail.high_school}',null),
                                inputWidget('Hobbies', _hobbiesController, '${userDetail.hobbies}',null),

                              ]else...[
                                Utils.LoadingIndictorWidtet(size: 30.0),
                              ],

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      height: 50,
                                      padding: EdgeInsets.only(top: 10),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.black,
                                        ),
                                        child: const Text('Update'),
                                        onPressed: () async {
                                          if (_firstNameController.text.isEmpty) {
                                            Utils.toastMessage('First name is required');
                                          } else if (_lastNameController.text.isEmpty) {
                                            Utils.toastMessage('Last name is required');
                                          } else if (_mobileController.text.isEmpty) {
                                            Utils.toastMessage('Phone number is required');
                                          } else {
                                            Map data = {
                                              'id': '${user.id}',
                                              'fname':
                                              '${_firstNameController.text}',
                                              'lname':
                                              '${_lastNameController.text}',
                                              'about':
                                              '${_aboutController.text}',
                                              'city': '${_cityController.text}',
                                              'state':
                                              '${_stateController.text}',
                                              'country':
                                              '${_countryController.text}',
                                              'hobbies':
                                              '${_hobbiesController.text}',
                                              'fax':
                                              '${_faxController.text}',
                                              'high_school':
                                              '${_highSchoolController.text}',
                                              'phone':
                                              '${_mobileController.text}',
                                            };
                                            dynamic response = await userDetailViewModel.updateSocialInfo(data, '${authToken}');
                                            if (response['success'] == true) {
                                              Utils.toastMessage('${response['message']}');
                                              Navigator.of(context).pop();
                                            } else {
                                              Utils.toastMessage('${response['message']}');
                                            }
                                          }
                                        },
                                      )
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          EdgeInsets.only(left: 20, top: 20, bottom: 10,right: 20),
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Home location',style: Constants().np_heading,),
                                Icon(Icons.edit),
                              ],
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeLocationScreen())).then((value) {
                                Map data = {'id': '${authId}'};
                                Provider.of<UserViewModel>(context, listen: false).getUserDetails(data, '${authToken}');
                                Provider.of<UserDetailsViewModel>(context, listen: false).getUserDetails(data, '${authToken}');
                              });
                            },
                          ),
                        ),
                        Divider(),
                    if(userDetail?.city!=null)...[

      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                    Text('City',style: TextStyle(color: Colors.grey),),
                                    fakeInput('${userDetail?.city}'),

                                    Text('State',style: TextStyle(color: Colors.grey),),

                                    fakeInput('${userDetail?.state}'),

                                    Text('Country',style: TextStyle(color: Colors.grey),),
                                    fakeInput('${userDetail?.country}'),



                                ],
                              ),

                            ],
                          ),
                        )
                    ]

                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10,)
              ],
            ),
          )),
      backgroundColor: Colors.white,
    );
  }

  Widget fakeInput(String title){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade500
        ),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Text(title,style: TextStyle(fontSize: 17),),
    );
  }
  Widget inputWidget(label, TextEditingController _controller, value,maxLength) {
    setState(() {
      if (value != null && value != 'null') {
        _controller.text = value;
      }
    });
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: TextField(
        maxLength:maxLength ?? null,
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
  Widget phoneWidget(String label, TextEditingController _controller, value,showPrefix) {
    setState(() {
      if (value != null && value != 'null') {
        _controller.text = value;
      }
    });
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration:
        showPrefix==true ?
        InputDecoration(
          border: OutlineInputBorder(),
          labelText:'${label}',
          prefixIcon:Icon(Icons.plus_one),
        ) :
        InputDecoration(
          border: OutlineInputBorder(),
          labelText:'${label}',
        ),
      ),
    );
  }
}

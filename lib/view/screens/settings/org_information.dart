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

class OrgInformationScreen extends StatefulWidget {
  const OrgInformationScreen({Key? key}) : super(key: key);

  @override
  State<OrgInformationScreen> createState() => _OrgInformationScreenState();
}

class _OrgInformationScreenState extends State<OrgInformationScreen> {
  var authToken;
  var authId;



  final _aboutController = TextEditingController();
  final _organaizationNameController = TextEditingController();
  final _organaizationController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _faxController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _organaizationEmail = TextEditingController();
  final _organaizationMobileController = TextEditingController();
  final _contactPerson= TextEditingController();
  final _contactPersonEmail= TextEditingController();
  final _contactPersonPhone= TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();


      Provider.of<UserViewModel>(context, listen: false).setUser(User());
      Provider.of<UserDetailsViewModel>(context, listen: false).setDetailsResponse(UserDetail());


      Map data = {'id': '${authId}'};
      Provider.of<UserViewModel>(context, listen: false).getUserDetails(data, '${authToken}');
      Provider.of<UserDetailsViewModel>(context, listen: false).getUserDetails(data, '${authToken}');

    });
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _organaizationNameController.dispose();
    _organaizationController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _faxController.dispose();
    _hobbiesController.dispose();
    _organaizationEmail.dispose();
    _organaizationMobileController.dispose();
    _countryController.dispose();
    
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);
    var userDetailViewModel = Provider.of<UserDetailsViewModel>(context, listen: false); 
    print('get user ${userViewModel.getUser}');
    User? user = userViewModel.getUser;
    UserDetail? userDetail = Provider.of<UserDetailsViewModel>(context, listen: false).getDetails;
    print('user ${user?.fname}');
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
                            'Edit Organization Information',
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
                                inputWidget('Organization Name', _organaizationNameController, _organaizationController.text == '' ? '${user.fname}' : _organaizationNameController.text,60),
                                inputWidget('EIN', _organaizationController,_organaizationController.text == '' ? '${user.username}' : _organaizationController.text,null),
                                inputWidget('About', _aboutController,_aboutController.text == '' ? '${userDetail!.about}' : _aboutController.text,null),
                                phoneWidget('Fax', _faxController, '${userDetail!.fax}',false),
                                phoneWidget('Phone', _organaizationMobileController, '${user.phone}',true),
                                
                                Container(
                                  padding:EdgeInsets.only(top:12, bottom:12),
                                  child: Text('Contact Person Information', style: TextStyle(fontSize: 18),),
                                ),
                                inputWidget('Name', _contactPerson,userDetail.cp_name,null),
                                phoneWidget('Phone', _contactPersonPhone, '${userDetail.cp_phone}',true),
                                inputWidget('Email', _contactPersonEmail,userDetail.cp_email,null),
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

                                          if (_organaizationNameController.text.isEmpty  ) {
                                            Utils.toastMessage('First name is required');
                                          } else if (_organaizationController.text.isEmpty) {
                                            Utils.toastMessage('Last name is required');
                                          } else if (_organaizationMobileController.text.isEmpty) {
                                            Utils.toastMessage('Phone number is required');
                                          }  else if (_organaizationNameController.text.length>59 || _contactPerson.text.length>59) {
                                            Utils.toastMessage('Name chrachters must be less than 60');
                                          }else {
                                            Map data = {
                                              'id': '${user.id}',
                                              'fname':'${_organaizationNameController.text}',
                                              'username':'${_organaizationController.text}',
                                              'about':'${_aboutController.text}',
                                              'fax':'${_faxController.text}',
                                              'phone':'${_organaizationMobileController.text}',
                                              'cp_name':'${_contactPerson.text}',
                                              'cp_email':'${_contactPersonEmail.text}',
                                              'cp_phone':'${_contactPersonPhone.text}',
                                              
                                            };
                                            print(data);
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
        maxLength: maxLength ?? null,
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
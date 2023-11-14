import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/utils.dart';
import 'package:np_social/view/screens/settingsBackup.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/UserDeviceViewModel.dart';
import 'package:np_social/view_model/auth_token_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var authToken;
  var authId;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

   
  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;
  bool _passwordVisible3 = true;
 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};
      Provider.of<UserDetailsViewModel>(context, listen: false)
          .getUserDetails(data, '${authToken}');
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                            'Change Password',
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
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: TextField(
                                  obscureText: _passwordVisible1,
                                  controller: _currentPasswordController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Current Password',
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _passwordVisible1 =
                                          !_passwordVisible1;
                                        });
                                      },
                                      child: new Icon(_passwordVisible1
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: TextField(
                                  obscureText: _passwordVisible2,
                                  controller: _newPasswordController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'New Password',
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _passwordVisible2 =
                                          !_passwordVisible2;
                                        });
                                      },
                                      child: new Icon(_passwordVisible2
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: TextField(
                                  obscureText: _passwordVisible3,
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Confirm New Password',
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _passwordVisible3 =
                                          !_passwordVisible3;
                                        });
                                      },
                                      child: new Icon(_passwordVisible3
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                  ),
                                ),
                              ),
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
                                        child: const Text('Change'),
                                        onPressed: () async {
                                          if (_currentPasswordController
                                              .text.isEmpty) {
                                            Utils.toastMessage(
                                                'Current password is required');
                                          } else if (_newPasswordController
                                              .text.isEmpty) {
                                            Utils.toastMessage(
                                                'New Password is required');
                                          } else if (_confirmPasswordController
                                              .text.isEmpty) {
                                            Utils.toastMessage(
                                                'Current Password is required');
                                          } else if (_confirmPasswordController
                                              .text !=
                                              _newPasswordController.text) {
                                            Utils.toastMessage(
                                                'Confirm password does not match');
                                          } else {
                                            Map data = {
                                              'id': '${user!.id}',
                                              'current_password':
                                              _currentPasswordController
                                                  .text,
                                              'new_password':
                                              _newPasswordController.text,
                                              'confirm_password':
                                              _confirmPasswordController
                                                  .text,
                                            };
                                            String? response =
                                            await userViewModel
                                                .changePassword(
                                                data, '${authToken}');
                                            Utils.toastMessage('${response}');
                                          }
                                        },
                                      )),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
      backgroundColor: Colors.white,
    );
  }
}

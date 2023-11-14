import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/utils.dart';
import 'package:np_social/view/screens/block_list.dart';
import 'package:np_social/view/screens/settings/change_password.dart';
import 'package:np_social/view/screens/settings/org_information.dart';
import 'package:np_social/view/screens/settings/practice_location.dart';
import 'package:np_social/view/screens/settings/privacy_management.dart';
import 'package:np_social/view/screens/settings/social_information.dart';
import 'package:np_social/view_model/UserDeviceViewModel.dart';
import 'package:np_social/view_model/auth_token_view_model.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  var authToken;
  var authId;


  final _usernameConfirmationController = TextEditingController();


  Future<void> _deleteAccount(ctx) async {
    bool isOnline = await Utils.hasNetwork();
    if (isOnline) {
      Map userDeviceParams = {'user_id': '${authId}'};
      await Provider.of<UserDeviceViewModel>(context, listen: false)
          .removeDeviceId(userDeviceParams, '${authToken}');
      await Provider.of<UserViewModel>(context, listen: false)
          .deleteAccount({'id': '${authId}'}, '${authToken}');
      AppSharedPref.logout(context);
    } else {
      Utils.toastMessage('No internet connection!');
    }
  }

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
    _usernameConfirmationController.dispose();
    super.dispose();
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
                Text('Settings',style: Constants().np_heading,),
                Divider(),
                context.watch<RoleViewModel>().getAuthRole== Role.User?
                InkWell(
                    child: navBtn(Colors.white,Icons.edit_note,'Edit Social Information'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SocialInformationScreen()));
                    }):Container(),
                context.watch<RoleViewModel>().getAuthRole== Role.Organization?
                InkWell(
                    child: navBtn(Colors.white,Icons.edit_note,'Edit Organization Information'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrgInformationScreen()));
                    }):Container(),

                context.watch<RoleViewModel>().getAuthRole== Role.User?
                InkWell(
                    child: navBtn(Colors.white,Icons.edit_note,'Edit Workplace Information'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeLocationScreen()));
                    }):Container(),
                context.watch<RoleViewModel>().getAuthRole== Role.Organization?
                InkWell(
                    child: navBtn(Colors.white,Icons.edit_note,'Edit Organization Location'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeLocationScreen()));
                    }):Container(),



                InkWell(
                    child: navBtn(Colors.white,Icons.lock_outline,'Change Password'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
                    }),

                context.watch<RoleViewModel>().getAuthRole== Role.User?
                InkWell(
                    child: navBtn(Colors.white,Icons.remove_red_eye_outlined,'Privacy Management'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyManagementScreen()));
                    }):Container(),



                context.watch<RoleViewModel>().getAuthRole== Role.User?
                InkWell(
                    child: navBtn(Colors.white,Icons.filter_list_off,'Block list'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BlockScreen()));
                    }):Container(),

                InkWell(
                    child: navBtn(Colors.red,Icons.delete_outline,'Delete Account'),
                    onTap: (){
                      showAccountDeleteConfirmation(context, user!);
                    }),


              ],
            ),
          )),
      backgroundColor: Colors.white,
    );
  }

  Widget navBtn(Color colors,IconData iconData,String title){
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: colors,
        borderRadius: new BorderRadius.all(Radius.circular(5)),
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 15),
      child:Row(
        children: [
          Text('${title}', style: TextStyle(color: Colors.black,fontSize: 20)),
          Expanded(child: Container(width: double.infinity,),),
          Icon(iconData,color: Colors.black,size: 20,),
        ],
      )
    );
  }
  Widget? showAccountDeleteConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String message = '';
        return AlertDialog(
          alignment: Alignment.centerLeft,
          title: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: 170,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Are you sure to delete your account? If yes, please type your username(${user.username}) below:",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: TextField(
                          controller: _usernameConfirmationController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          ),
                          style: TextStyle(fontSize: 15, height: 1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${message}',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Container(
                              width: 70,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius:
                                new BorderRadius.all(Radius.circular(3)),
                                color: Colors.grey,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                message = '';
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                              width: 70,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius:
                                new BorderRadius.all(Radius.circular(3)),
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            onTap: () {
                              if (_usernameConfirmationController.text == '') {
                                setState(() {
                                  message = 'Please type your username';
                                });
                              } else if (_usernameConfirmationController.text !=
                                  user.username) {
                                setState(() {
                                  message = 'Please type correct username';
                                });
                              } else if (_usernameConfirmationController.text ==
                                  user.username) {
                                setState(() {
                                  message = '';
                                });
                                _deleteAccount(context);
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }),
        );
      },
    );
  }
}

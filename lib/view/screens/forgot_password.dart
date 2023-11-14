import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indexed/indexed.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/home.dart';
import 'package:np_social/view/screens/new_password.dart';
import 'package:np_social/view_model/auth_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:np_social/utils/utils.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading=false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Constants.checkToken(context);
    });
  }


  Widget build(BuildContext context) {
    final _emailTextController = TextEditingController();

    final authViewModel=Provider.of<AuthViewModel>(context);
    final userViewModel=Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),

      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Container(
                  color:  Constants.np_bg_clr,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Indexer(
                          children: [
                            Indexed(
                              index: 2,
                              child: Center(
                                child: Container(
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.all(
                                        const Radius.circular(120)),
                                    color: Colors.white,
                                  ),
                                  transform:
                                  Matrix4.translationValues(0.0, -40, 0.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Image(
                                          width: 130,
                                          image: AssetImage('assets/images/logo.png'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Indexed(
                                index: 1,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 40, 10, 0),
                                  child: Column(
                                    children: [
                                      Card(
                                        color: Colors.white,
                                        child: SizedBox(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(20, 100, 20, 50),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child:Text('Forgot Password',style: TextStyle(fontWeight: FontWeight.w400,fontSize:20),),
                                                    ),
                                                    Container(
                                                        padding: const EdgeInsets.all(10),
                                                        child:Text('Enter your email address to receive a password reset link.')
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      child: TextFormField(
                                                        controller: _emailTextController,
                                                        decoration: const InputDecoration(
                                                          border: OutlineInputBorder(),
                                                          labelText: 'Enter your email',
                                                        ),
                                                        keyboardType: TextInputType.emailAddress,

                                                      ),
                                                    ),
                                                    Container(
                                                        width:MediaQuery.of(context).size.width * 1,
                                                        height: 50,
                                                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Colors.black,
                                                          ),
                                                          child:(_isLoading == true) ? Utils.LoadingIndictorWidtet() : Text('Send Email'),
                                                          onPressed: () async {
                                                            if(_emailTextController.text.isEmpty){
                                                              Utils.toastMessage('Email is required');
                                                            }else {
                                                              Map data={
                                                                'email':_emailTextController.text,
                                                              };
                                                              setState(() {
                                                                _isLoading=true;
                                                              });
                                                              Map response=await userViewModel.forgetPasswordEmail(data);
                                                              setState(() {
                                                                _isLoading=false;
                                                              });
                                                              if(response['success']==true){

                                                                Utils.toastMessage(response['message']);
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNewPasswordScreen(_emailTextController.text)));

                                                              }else{

                                                                Utils.toastMessage(response['message']);
                                                              }
                                                            }
                                                          },
                                                        )),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

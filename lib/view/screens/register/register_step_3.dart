import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/account_verification.dart';
import 'package:np_social/view/screens/home.dart';
import 'package:np_social/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class RegisterStep3Screen extends StatefulWidget {
  
  final Map data;
  const RegisterStep3Screen(this.data,{Key? key}) : super(key: key);

  @override
  State<RegisterStep3Screen> createState() => RegiserStep3ScreenState();
}

class RegiserStep3ScreenState extends State<RegisterStep3Screen> {

  final _phoneController = TextEditingController();
  final _npiController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _faxController = TextEditingController();
  final _contactPersonNameController = TextEditingController();
  final _contactPersonEmailController = TextEditingController();
  final _contactPersonPhoneController = TextEditingController();

  bool _isOrganization = false;


  Future<void>? _launched;
  Future<void> _launchInBrowser(Uri url) async {
    if(Platform.isAndroid){
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    }else{
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


  bool _passwordVisible1=true;
  bool _passwordVisible2=true;

  DateTime? _selectedDate;
  String? gender = 'Male';

  bool _isLoading=false;
  bool? _isChecked = false;

  var inputFormat = DateFormat('MM-dd-yyyy');


  var profileSelected=false;

  //Method for showing the date picker
  void _pickDateDialog() {
     final currentDate = DateTime.now();
     final eighteenYearsAgo = currentDate.subtract(Duration(days: 365 * 18));
    showDatePicker(
        context: context,
        initialDate: eighteenYearsAgo,
        //which date will display when user open the picker
        firstDate:DateTime(1950) ,
        //what will be the previous supported year in picker
        lastDate:eighteenYearsAgo)
        .then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        //for rebuilding the ui
        _selectedDate = pickedDate;
      });
    });
  }



  @override
  void initState() {
    super.initState();
    if (widget.data['role']==Role.Organization.toString()){
      _isOrganization = true;
    }
    Constants.checkToken(context);
  }


  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
              left: Constants.np_padding_only,
              right: Constants.np_padding_only,
              top: 20),
          child: Card(
            shadowColor: Colors.black12,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListView(
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Registering as ${Role.getTitle(int.parse(widget.data['role']))}',
                    style: Constants().np_heading,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Continue to register using this email : ${widget.data['email']}'),
                ),
               _isOrganization == false?
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.plus_one),
                      ),
                      keyboardType: TextInputType.phone
                  ),
                ):Container(),
              
              _isOrganization == false?
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _npiController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'NPI Number',
                    ),
                    inputFormatters:<TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ):Container(),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _faxController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fax',
                    ),
                    inputFormatters:<TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),

                      FilteringTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ),
                
               
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: _passwordVisible1,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: GestureDetector(
                        onTap: (){
                          setState(() {
                            _passwordVisible1 = !_passwordVisible1;
                          });
                        },
                        child: new Icon(_passwordVisible1 ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: _passwordVisible2,
                    controller: _confirmpasswordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                      suffixIcon: GestureDetector(
                        onTap: (){
                          setState(() {
                            _passwordVisible2 = !_passwordVisible2;
                          });
                        },
                        child: new Icon(_passwordVisible2 ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                ),
                _isOrganization == true?
                Padding(
                  padding: EdgeInsets.only(
                      left: Constants.np_padding_only,
                      right: Constants.np_padding_only,
                      top: 20
                  ),
                  child: Text('Contact Person',style: TextStyle(fontSize: 18,color: Colors.black),),
                ):SizedBox(),
                _isOrganization == true?
                Divider(
                
                ):SizedBox(),
                _isOrganization == true?
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _contactPersonNameController,
                    inputFormatters:<TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(), 
                      labelText: 'Name',
                    ),
                    
                    keyboardType: TextInputType.name,
                  ),
                ):Container(),
                _isOrganization == true?
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _contactPersonEmailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    
                    keyboardType: TextInputType.emailAddress,
                  ),
                ):Container(),
                _isOrganization == true?
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _contactPersonPhoneController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone',
                    ), 
                    keyboardType: TextInputType.number,
                  ),
                ):Container(), 
                _isOrganization == false?
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(3),),
                      side: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gender'),
                          Row(
                            children: [
                              Text(gender!),
                              PopupMenuButton<String>(
                                position:PopupMenuPosition.under,
                                  color: Colors.white,
                                  icon: Icon(Icons.arrow_drop_down),
                                  // Callback that sets the selected popup menu item.
                                  onSelected: (String pri) {
                                    setState(() {
                                      gender = pri;
                                    });
                                  },
                                  itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'Male',
                                      child: Text('Male'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'Female',
                                      child: Text('Female'),
                                    ),
                                  ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ):Container(),
                _isOrganization == false?
                Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(3),),
                        side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      shadowColor: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                child:Text('Date of Birth'),
                                onTap: _pickDateDialog
                            ),
                            InkWell(
                                child:(_selectedDate!=null)
                                    ? Text('${inputFormat.format(_selectedDate!)}')
                                    : Text('No Date Selected'),
                                onTap: _pickDateDialog
                            ),

                          ],
                        ),
                      ),
                    )
                ):Container(),
                Container(
              child: Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value;
                      });
                    },
                  ),
                  InkWell(
                    child: Text(
                      'I agree to the terms and conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: (){
                      setState(() {
                        _launched = _launchInBrowser(Uri.parse('https://thenpsocial.com/privacy-policy'));
                      });
                      FutureBuilder<void>(future: _launched, builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const Text('');
                        }
                      });
                    },
                  ),

                ],
              ),
            ), Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width * 1,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: _isLoading ? Utils.LoadingIndictorWidtet() : Text('Sign Up'),

                      onPressed: () async {
                        if (_faxController.text.isEmpty) {
                          Utils.toastMessage('Fax is required');
                          return;
                        }else if (_passwordController.text.isEmpty) {
                          Utils.toastMessage('Password is required.');
                          return;
                        } else if (_confirmpasswordController.text.isEmpty) {
                          Utils.toastMessage('Confirm Password is required.');
                          return;
                        } else if (_confirmpasswordController.text != _passwordController.text) {
                          Utils.toastMessage('Confirm password doesn\'t matched.');
                          return;
                        }  
                        if (_isOrganization == false){
                          if (_npiController.text.isEmpty) {
                            Utils.toastMessage('NPI number is required');
                            return;
                          }else if (_selectedDate==null) {
                            Utils.toastMessage('Date of birth is required');
                            return;
                          } else if (_phoneController.text.isEmpty) {
                            Utils.toastMessage('Phone number is required');
                            return;
                          }
                      } else if (_isOrganization == true){
                          if (_contactPersonNameController .text.isEmpty) {
                            Utils.toastMessage('Contact Person Name is required');
                            return;
                          }else if (_contactPersonEmailController.text.isEmpty) {
                            Utils.toastMessage('Contact Person Email is required');
                            return;
                          }else if (_contactPersonPhoneController.text.isEmpty) {
                            Utils.toastMessage('Contact Person Phone is required');
                            return;
                          } 
                          } if (_isChecked == false) {
                          Utils.toastMessage('Please agree to the terms and conditions.'); 
                          return; 
                          } 
                          else { 
                            Map<dynamic,dynamic> data={}; 
                            if(_isOrganization==true){
                            data = {
                              'role':widget.data['role'],
                              'email': widget.data['email'],
                              'phone': _phoneController.text,
                              'fname': widget.data['fname'],
                              'lname': widget.data['lname'],
                              'username': widget.data['username'],
                              'phone':widget.data['phone'],
                              'country_code': '+1',
                              'password': _passwordController.text,
                              'confirm_password': _passwordController.text,
                              'cp_name':_contactPersonNameController.text,
                              'cp_email':_contactPersonEmailController.text,
                              'cp_phone':_contactPersonPhoneController.text,
                              'fax':_faxController.text,
                            };
                          }else{
                            data = {
                              'role':widget.data['role'],
                              'email': widget.data['email'],
                              'phone': _phoneController.text,
                              'fname': widget.data['fname'],
                              'lname': widget.data['lname'],
                              'npi': _npiController.text,
                              'gender': gender,
                              'username': widget.data['username'],
                              'dob': DateFormat('yyyy-MM-dd').format(_selectedDate!),
                              'country_code': '+1',
                              'password': _passwordController.text,
                              'confirm_password': _passwordController.text,
                              'fax':_faxController.text,
                            };
                          }

                          setState(() { _isLoading=true; });
                          Map response = await authViewModel.registerApi(data, context);
                          setState(() { _isLoading=false; });

                          if (response['register'] == true) {
                            Utils.toastMessage(response['message']);

                            AppSharedPref.saveAuthTokenResponse(response['data']['token']);
                            AppSharedPref.saveLoginUserResponse(response['data']['data']['id']);

                            if(response['data']['data']['email_verified_at'] ==  null){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountVerificationScreen()));
                            }else{
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                            }
                            //Navigator.pushNamed(context, route.homePage);
                          } else {
                            Utils.toastMessage(response['message']);

                          }
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget inputWidget(label, TextEditingController _controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}

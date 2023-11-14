import 'package:flutter/material.dart';
import 'package:np_social/res/constant.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _npiController = TextEditingController();
  final _genderController = TextEditingController();
  final _dateofbirthController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  DateTime? _selectedDate;
  String? gender = 'Male';

  var inputFormat = DateFormat('yyyy-M-dd');

  var profileSelected = false;

  //Method for showing the date picker
  void _pickDateDialog() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            //which date will display when user open the picker
            firstDate: DateTime(1950),
            //what will be the previous supported year in picker
            lastDate: DateTime
                .now()) //what will be the up to supported date in picker
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

  /*File profile=new File('');
  var profilePath='';
  Future<File> getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    File file = File(image!.path);
    setState(() {
      profileSelected=true;
      profile=file;
      profilePath=image!.path;
    });

    return file;
  }*/

  @override
  void initState() {
    super.initState();
    Constants.checkToken(context);
  }

  Widget build(BuildContext context) {
    return Container();
  }
  /*Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('NP Social'),
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
                    'Register',
                    style: Constants().np_heading,
                  ),
                ),
                */ /*Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: InkWell(
                    onTap: getImage,
                    child: ClipOval(
                      child: SizedBox.fromSize(
                        size: Size.fromRadius(60),
                        child : (profileSelected == false)
                            ? Image.asset('${Constants.avatarImage}')
                            : Image.file( profile ),
                      ),
                    ),
                  ),
                ),
                */ /*
                inputWidget('First Name', _fnameController),
                inputWidget('Last Name', _lnameController),
                inputWidget('Email', _emailController),
                inputWidget('Username', _usernameController),

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
                ),

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
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: _confirmpasswordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                    ),
                  ),
                ),

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
                          Row(
                            children: [
                              Text('Gender'),
                              PopupMenuButton<String>(
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
                          Text(gender!),
                        ],
                      ),
                    ),
                  ),
                ),
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
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width * 1,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: const Text('Sign Up'),
                      onPressed: () async {
                        if (_emailController.text.isEmpty) {
                          Utils.toastMessage('Email field is required');
                        } else if (_phoneController.text.isEmpty) {
                          Utils.toastMessage('Phone field is required');
                        } else if (_fnameController.text.isEmpty) {
                          Utils.toastMessage('First name field is required');
                        } else if (_lnameController.text.isEmpty) {
                          Utils.toastMessage('Last name field is required');
                        } else if (_npiController.text.isEmpty) {
                          Utils.toastMessage('NPI number field is required');
                        } else if (_usernameController.text.isEmpty) {
                          Utils.toastMessage('Username field is required');
                        } else if (_selectedDate==null) {
                          Utils.toastMessage('Date of birth field is required');
                        } else if (_usernameController.text.isEmpty) {
                          Utils.toastMessage('Username field is required');
                        } else if (_passwordController.text.isEmpty) {
                          Utils.toastMessage('Password field is required');
                        } else if (_confirmpasswordController.text.isEmpty) {
                          Utils.toastMessage('Confirm Password field is required');
                        } else if (profileSelected==false) {
                          Utils.toastMessage('Profile field is required');
                        } else {
                          Map<dynamic,dynamic> data = {
                            'email': _emailController.text,
                            'phone': _phoneController.text,
                            'fname': _fnameController.text,
                            'lname': _lnameController.text,
                            'npi': _npiController.text,
                            'gender': gender,
                            'username': _usernameController.text,
                            'dob': inputFormat.format(_selectedDate!),
                            'country_code': '+1',
                            'role': '3',
                            'password': _passwordController.text,
                            'confirm_password': _passwordController.text,
                          };

                        Map response = await authViewModel.registerApi(data, context);
                          if (response['register'] == true) {
                            Utils.toastMessage(response['message']);


                            */ /*await Constants.changeProfile(
                                response['data']['token'],
                                response['data']['data']['id'],
                                profile, profilePath, AppUrl.changeProfilePicture,
                                'Profile'
                            );
                            */ /*
                            AppSharedPref.saveAuthTokenResponse(response['data']['token']);
                            AppSharedPref.saveLoginUserResponse(response['data']['data']['id']);

                            Navigator.pushNamed(context, route.homePage);
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
  */
}

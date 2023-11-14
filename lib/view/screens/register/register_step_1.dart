import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indexed/indexed.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/register/register_step_2.dart';
import 'package:np_social/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

class RegisterStep1Screen extends StatefulWidget {
  int role;
  RegisterStep1Screen({Key? key, required this.role}) : super(key: key);

  @override
  State<RegisterStep1Screen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterStep1Screen> {
  final _emailController = TextEditingController();
  final _fnameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _lnameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Constants.checkToken(context);
  }

  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Constants.np_bg_clr,
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  color: Constants.np_bg_clr,
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
                                          image: AssetImage(
                                              'assets/images/logo.png'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Indexed(
                                  index: 1,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
                                    child: Container(
                                      height: 550,
                                      child: Card(
                                        color: Colors.white,
                                        child: SizedBox(
                                            child: ListView(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 60, 10, 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    'Registering as ${Role.getTitle(widget.role)}',
                                                    style:
                                                        Constants().np_heading,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            inputWidget(
                                                widget.role == Role.Organization
                                                    ? 'Organization Name'
                                                    : 'First Name',
                                                _fnameController,
                                                [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                          RegExp(r'[a-zA-Z\s]'))
                                                ],
                                                TextInputType.name,
                                                60),
                                            widget.role == Role.Organization
                                                ? Container()
                                                : inputWidget(
                                                    'Last Name',
                                                    _lnameController,
                                                    [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'[a-zA-Z\s]'))
                                                    ],
                                                    TextInputType.name,
                                                    60),
                                            inputWidget(
                                                widget.role == Role.Organization
                                                    ? 'Email (This will be used for sign-up)'
                                                    : 'Email',
                                                _emailController,
                                                [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'[a-zA-Z0-9@._-]'),
                                                  ),
                                                ],
                                                TextInputType.emailAddress,
                                                60),
                                            inputWidget(
                                                widget.role == Role.Organization
                                                    ? 'EIN'
                                                    : 'Username',
                                                _regNoController,
                                                [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'[a-zA-Z0-9@._-]'),
                                                  ),
                                                ],
                                                TextInputType.name,
                                                60),
                                            widget.role == Role.Organization
                                                ? inputWidget(
                                                    widget.role ==
                                                            Role.Organization
                                                        ? 'Contact No.'
                                                        : 'Phone No.',
                                                    _phoneController,
                                                    [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    TextInputType.number,
                                                    15)
                                                : Container(),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1,
                                                height: 50,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 10, 0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.black,
                                                  ),
                                                  child: _isLoading
                                                      ? Utils
                                                          .LoadingIndictorWidtet()
                                                      : Text(
                                                          'Verify your email address'),
                                                  onPressed: () async {
                                                    if (_fnameController
                                                        .text.isEmpty) {
                                                      Utils.toastMessage(
                                                          '${widget.role == Role.User ? 'First name' : 'Organization name'} is required');
                                                    } else if (_emailController
                                                        .text.isEmpty) {
                                                      Utils.toastMessage(
                                                          'Email is required');
                                                    } else if (_regNoController
                                                        .text.isEmpty) {
                                                      Utils.toastMessage(
                                                          '${widget.role == Role.User ? 'Username' : 'EIN'} is required');
                                                    } else if (widget.role ==
                                                            Role.User &&
                                                        _lnameController
                                                            .text.isEmpty) {
                                                      Utils.toastMessage(
                                                          'Last name is required');
                                                    } else {
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                      var otp = Random()
                                                          .nextInt(999999)
                                                          .toString()
                                                          .padLeft(6, '0');

                                                      Map<dynamic, dynamic>
                                                          data = {
                                                        'role': widget.role
                                                            .toString(),
                                                        'lname':
                                                            _lnameController
                                                                .text,
                                                        'email':
                                                            _emailController
                                                                .text,
                                                        'fname':
                                                            _fnameController
                                                                .text,
                                                        'username':
                                                            _regNoController
                                                                .text,
                                                        'code': otp
                                                      };

                                                      Map response =
                                                          await authViewModel
                                                              .verifyEmail(data,
                                                                  context);
                                                      setState(() {
                                                        _isLoading = false;
                                                      });

                                                      if (response['success'] ==
                                                          true) {
                                                        AppSharedPref.saveOtp(
                                                            otp);
                                                        Utils.toastMessage(
                                                            response[
                                                                'message']);
                                                        Map registerData = {
                                                          'role': widget.role
                                                              .toString(),
                                                          'email':
                                                              _emailController
                                                                  .text,
                                                          'fname':
                                                              _fnameController
                                                                  .text,
                                                          'code': otp,
                                                          'username':
                                                              _regNoController
                                                                  .text,
                                                          'lname':
                                                              _lnameController
                                                                  .text,
                                                          'phone':
                                                              _phoneController
                                                                  .text
                                                        };
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    RegiserStep2Screen(
                                                                        registerData)));
                                                      } else {
                                                        Utils.toastMessage(
                                                            response[
                                                                'message']);
                                                      }
                                                    }
                                                  },
                                                )),
                                          ],
                                        )),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputWidget(label, TextEditingController _controller,
      [List<TextInputFormatter>? inputFormatters,
      TextInputType? keyboardType,
      int? maxLength]) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextField(
        maxLength: maxLength ?? null,
        keyboardType: keyboardType != null ? keyboardType : null,
        inputFormatters: inputFormatters != null ? inputFormatters : [],
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}

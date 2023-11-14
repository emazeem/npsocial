import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:np_social/res/constant.dart';

import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/register/register_step_3.dart';
import 'package:pinput/pinput.dart';

class RegiserStep2Screen extends StatefulWidget {
  final Map data;
  const RegiserStep2Screen(this.data, {Key? key}) : super(key: key);

  @override
  State<RegiserStep2Screen> createState() => _RegiserStep2ScreenState();
}

class _RegiserStep2ScreenState extends State<RegiserStep2Screen> {
  final _otpController = TextEditingController();

  bool _isLoading = false;
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    Constants.checkToken(context);
  }

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
                    'Verify OTP',
                    style: Constants().np_heading,
                  ),
                ),
                widget.data['role'] == '3'
                    ? Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                            '${widget.data['fname']} ${widget.data['lname']} please enter 6-Digit code sent to ${widget.data['email']}'),
                      )
                    : Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                            '${widget.data['fname']} please enter 6-Digit code sent to ${widget.data['email']}'),
                      ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: pinputWidget(),
                ),
                Visibility(
                  visible: false,
                  child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      width: MediaQuery.of(context).size.width * 1,
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: _isLoading
                            ? Utils.LoadingIndictorWidtet()
                            : Text('Submit'),
                        onPressed: () async {
                          VerifyOTP();
                        },
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  VerifyOTP() {
    if (pinController.text.isEmpty) {
      Utils.toastMessage('6-Digit OTP is required');
    } else if (pinController.text != widget.data['code']) {
      Utils.toastMessage('Please type correct OTP');
      pinController.clear();

    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterStep3Screen(widget.data)));
    }
  }

  Widget pinputWidget() {
    return Form(
        key: formKey,
        child: Pinput(
          controller: pinController,
          focusNode: focusNode,
          length: 6,
          autofocus: true,
          androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
          listenForMultipleSmsOnAndroid: true,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: (pin) {
            VerifyOTP();
          },
           inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, 
            ],
          onChanged: (value) {
          },
        ));
  }
}

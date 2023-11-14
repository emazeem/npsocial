import 'dart:io';

import 'package:np_social/model/Privacy.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/settings/update_privacy.dart';
import 'package:np_social/view_model/privacy_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PrivacyManagementScreen extends StatefulWidget {
  const PrivacyManagementScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyManagementScreen> createState() => _PrivacyManagementScreenState();
}

class _PrivacyManagementScreenState extends State<PrivacyManagementScreen> {
  var authToken;
  var authId;
  List<String>? updatedPrivacy;
  Future<void> _pullRefresh(ctx) async {
    Map data = {'id': '${authId}'};
    Provider.of<PrivacyViewModel>(context, listen: false).setPrivacy(Privacy());
    Provider.of<PrivacyViewModel>(context, listen: false).fetchPrivacy(data, '${authToken}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _pullRefresh(context);
    });
  }
  @override
  void dispose() {
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

                        Container(
                          padding: EdgeInsets.all(10),
                          child:  Row(
                            children: [
                              Icon(Icons.edit_note),
                              Text('Privacy Settings',style: TextStyle(fontSize: 20),),
                            ],
                          ),
                        ),
                        Divider(),

                        privacyCard('Email','email'),
                        privacyCard('Mobile Number','phone'),
                        privacyCard('Gender','gender'),
                        privacyCard('Fax','fax'),

                        privacyCard('About','about'),
                        privacyCard('City','city'),
                        privacyCard('State','state'),
                        privacyCard('Country','country'),

                        privacyCard('Date of Joining','joining'),
                        privacyCard('Workplace','workplace'),
                        privacyCard('University','university'),
                        privacyCard('Hobbies','hobbies'),

                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
      backgroundColor: Colors.white,
    );
  }
  Widget privacyCard(String column,String columnKey){
    PrivacyViewModel privacyViewModel = Provider.of<PrivacyViewModel>(context);
    Privacy? privacyValues=privacyViewModel.getPrivacy;

    Widget image=Container();
    String? privacyValue;

    if(privacyViewModel.fetchPrivacyStatus.status==Status.BUSY){
      image=Utils.LoadingIndictorWidtet(size: 15.0);
    }else{
      if(columnKey=='email'){ image=privacyImage(privacyValues?.email); privacyValue=privacyValues?.email;}
      if(columnKey=='phone'){ image=privacyImage(privacyValues?.phone);privacyValue=privacyValues?.phone; }
      if(columnKey=='gender'){ image=privacyImage(privacyValues?.gender); privacyValue=privacyValues?.gender;}
      if(columnKey=='fax'){ image=privacyImage(privacyValues?.fax); privacyValue=privacyValues?.fax;}

      if(columnKey=='about'){ image=privacyImage(privacyValues?.about);privacyValue=privacyValues?.about; }
      if(columnKey=='city'){ image=privacyImage(privacyValues?.city);privacyValue=privacyValues?.city; }
      if(columnKey=='state'){ image=privacyImage(privacyValues?.state); privacyValue=privacyValues?.state;}
      if(columnKey=='country'){ image=privacyImage(privacyValues?.country); privacyValue=privacyValues?.country;}

      if(columnKey=='joining'){ image=privacyImage(privacyValues?.joining);privacyValue= privacyValues?.joining;}
      if(columnKey=='workplace'){ image=privacyImage(privacyValues?.workplace); privacyValue=privacyValues?.workplace;}
      if(columnKey=='university'){ image=privacyImage(privacyValues?.university); privacyValue=privacyValues?.university;}
      if(columnKey=='hobbies'){ image=privacyImage(privacyValues?.hobbies);privacyValue= privacyValues?.hobbies;}
      }


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(column),

          Row(
            children: [
              image,
              Container(
                margin: EdgeInsets.only(left: 10),
                child: InkWell(
                  child: Container(
                      padding: EdgeInsets.only(left: 10,top: 10,bottom: 10,right: 10),
                      child: Icon(Icons.edit,size: 12,)
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePrivacyScreen(columnKey,column,privacyValue))).then((value) => _pullRefresh(context));
                  },
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget privacyImage(String? privacyList){
    return Container(
        child:Tooltip(
          message: '${privacyList}',
          child: Image.asset('assets/images/${privacyList}.png',
            width: 20,
            height: 20,
            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              return Constants.defaultImage(20.0);
            },
          ),
        )
    );
  }


}

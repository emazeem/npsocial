import 'package:np_social/model/Privacy.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/privacy_view_model.dart';
import 'package:flutter/material.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view_model/privacy_view_model.dart';
import 'package:provider/provider.dart';

class UpdatePrivacyScreen extends StatefulWidget {
  final columnKey;
  final column;
  final value;
  const UpdatePrivacyScreen(this.columnKey,this.column,this.value);

  @override
  State<UpdatePrivacyScreen> createState() => _UpdatePrivacyScreenState();
}

class _UpdatePrivacyScreenState extends State<UpdatePrivacyScreen> {
  var authToken;
  var authId;
  String? _updatedPrivacy;
  Privacy? privacyValues;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
    });
    _updatedPrivacy=widget.value;
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
      body: Center(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Update Privacy of ${widget.column}',style: TextStyle(fontSize: 18),),
                  InkWell(
                    child:Container(
                      margin: EdgeInsets.all(10),
                      child: Icon(Icons.close),
                    ),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Divider(),
        for (var v in Constants.networkList())
          InkWell(
              onTap: (){
                setState(() {
                  _updatedPrivacy = v['key'];
                });
              },
              child: Container(
                color: ( _updatedPrivacy == v['key'] )?Colors.grey.shade300:Colors.transparent,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Image.asset('assets/images/${v['key']}.png',width: 20,),
                    SizedBox(width: 10,),
                    Text(v['title'],style: TextStyle(color:  Colors.black)),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child:Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          )
                      ),
                      child: Text('Update',style: TextStyle(color: Colors.white),),
                    ),
                    onTap: ()async{
                      if(_updatedPrivacy == null ){
                        Utils.toastMessage('Please select privacy to update.');
                      }else{
                        String columnKey=widget.columnKey;
                        dynamic data={'id':'${authId}','column':'${columnKey.replaceAll('_', '-')}','privacies':'${_updatedPrivacy}'};
                        dynamic response=await Provider.of<PrivacyViewModel>(context,listen: false).updatePrivacy(data, authToken);
                        Utils.toastMessage('${response['message']}');
                        if(response['data']==true){
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

          ],
        )
      ),
    );
  }
}

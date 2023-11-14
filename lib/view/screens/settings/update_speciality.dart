
import 'package:np_social/model/Privacy.dart';
import 'package:np_social/model/Speciality.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/privacy_view_model.dart';
import 'package:flutter/material.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view_model/privacy_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:provider/provider.dart';

class UpdateSpecialityScreen extends StatefulWidget {
  final id;
  const UpdateSpecialityScreen(this.id);

  @override
  State<UpdateSpecialityScreen> createState() => _UpdateSpecialityScreenState();
}

class _UpdateSpecialityScreenState extends State<UpdateSpecialityScreen> {
  var authToken;
  var authId;
  final _otherSpecialityController = TextEditingController();

  int? _updatedSpeciality;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();

      Provider.of<UserDetailsViewModel>(context, listen: false).fetchSpecialities([], '${authToken}');

    });
    _updatedSpeciality=widget.id;
    super.initState();

  }
  @override
  void dispose() {
    _otherSpecialityController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    List<Speciality>? specialities=Provider.of<UserDetailsViewModel>(context).getSpecialities;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Constants.titleImage(),
        leading: new InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => NPLayout(currentIndex: 4,)));
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Center(
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Text('Update Speciality',style: TextStyle(fontSize: 18),),
              ),
              Divider(),

              for(Speciality speciality in specialities!)
                InkWell(
                  onTap: (){
                    setState(() {
                      _updatedSpeciality=speciality.id;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (_updatedSpeciality==speciality.id)?Colors.grey:Colors.grey.shade200,
                    ),
                    child: Text('${speciality.title}'),
                  ),
                ),
              InkWell(
                onTap: (){
                  setState(() {
                    _updatedSpeciality=0;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_updatedSpeciality==0)?Colors.grey:Colors.grey.shade200,
                  ),
                  child: Text('Other'),
                ),
              ),
              (_updatedSpeciality==0)
                  ?
              Container(
                  margin: EdgeInsets.all(10),
                  height: 8 * 24.0,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _otherSpecialityController,
                    maxLines: 8,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Write non-listed speciality here...',
                      fillColor: Colors.grey[100],
                      filled: true,
                      border: InputBorder.none,
                    ),
                  )):Container(),


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
                        if(_updatedSpeciality == null ){
                          Utils.toastMessage('Please select speciality to update.');
                        }
                        else if(_otherSpecialityController.text.isEmpty && _updatedSpeciality==0 ){
                          Utils.toastMessage('Please type speciality in textbox.');
                        }
                        else{
                          dynamic data={'id':'${authId}','speciality':'${_updatedSpeciality}','title':'${_otherSpecialityController.text}'};
                          dynamic response=await Provider.of<UserDetailsViewModel>(context,listen: false).updateSpeciality(data, authToken);

                          Utils.toastMessage('${response['message']}');
                          if(response['data']==true){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NPLayout(currentIndex: 4)));
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

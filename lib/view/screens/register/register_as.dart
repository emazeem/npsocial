import 'package:flutter/material.dart';
import 'package:indexed/indexed.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/register/register_step_1.dart';

class RegisterAs extends StatefulWidget {
  const RegisterAs({Key? key}) : super(key: key);

  @override
  State<RegisterAs> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterAs> {
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
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 180.0,
                color: Color(0xFFf0f2f5),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterStep1Screen(role:Role.User,),),);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width/1.5,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(100)
                          ),
                          child: Text('Join as User',textAlign: TextAlign.center,),
                        ),
                      ),
                      SizedBox(height: 15,),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterStep1Screen(role:Role.Organization,),),);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width/1.5,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.amber,
                          ),
                          child: Text('Join as Organization',textAlign: TextAlign.center,),

                        ),
                      ),
                      SizedBox(height: 30,),

                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 100.0, // (background container size) - (circle height / 2)
            child: Image.asset(
              'assets/images/logo.png',
              width: 160,
              height: 160,
            ),
          )
        ],
      ),
    );
  }
}
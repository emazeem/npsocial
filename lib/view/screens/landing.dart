import 'package:flutter/material.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:np_social/view/screens/register/register_as.dart';
import 'package:np_social/view/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage();

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  checkToken(context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(Constants.authToken);
    if (token != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SplashScreen()));
      });
    }
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await checkToken(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 230.0,
                color: Color(0xFFf0f2f5),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Together, we are unstoppable',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                        (MediaQuery.of(context).size.width /
                                            2.3),
                                        70),
                                    primary:Colors.grey.shade200,
                                    onPrimary: Colors.black,
                                    textStyle: TextStyle(
                                        color: Colors.black, fontSize: 22),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                child: Text('Sign Up'),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RegisterAs()));
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                        (MediaQuery.of(context).size.width /
                                            2.3),
                                        70),
                                    primary: Colors.amber,
                                    onPrimary: Colors.black,
                                    textStyle: TextStyle(
                                        color: Colors.black, fontSize: 22),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                child: Text('Sign In'),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SplashScreen()));
                                  /*Navigator.pushNamed(context, route.loginPage);
                                  */
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 150.0, // (background container size) - (circle height / 2)
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

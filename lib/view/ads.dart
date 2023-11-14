import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:np_social/model/Ad.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/webview/video.dart';
import 'package:np_social/view_model/ads_view_model.dart';
import 'package:provider/provider.dart';

class AdsScreen extends StatefulWidget {
  final Ad ad;
  const AdsScreen(this.ad);

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  int? AuthId;
  Map data = {};
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AuthId = await AppSharedPref.getAuthId();
      data = {'ad_id': '${widget.ad.id}', 'user_id': '${AuthId}', 'type': 'click'};
      Provider.of<AdsViewModel>(context, listen: false).registerClick(data);
    });
    print('object ${Constants.profileImage(widget.ad.user!)}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              ListTile(
                title: Text('${widget.ad.title!}',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                leading: Card(
                    child: Image.network(
                  '${AppUrl.url + '/' + widget.ad.image.toString()}',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )),
                subtitle: Text(
                  '${widget.ad.createdAt!.m}-${widget.ad.createdAt!.d}-${widget.ad.createdAt!.Y} ${widget.ad.createdAt!.h}:${widget.ad.createdAt!.i} ${widget.ad.createdAt!.A} ',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              Divider(),
              (widget.ad.type=='none')?Container():
              Container(
                color: Constants.np_bg_clr,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: (){
                        if(widget.ad.type=='video'){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(videoUrl: widget.ad.video.toString(),)));
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          child: Image.network(
                            '${AppUrl.url + '/' + widget.ad.image.toString()}',
                            width: double.infinity,
                            fit: BoxFit.contain,
                            height: 300,
                          ),
                        ),
                      ),
                    ),
                    (widget.ad.type=='video')?
                    Positioned(
                        top: 140,
                        left: MediaQuery.of(context).size.width/2-20,
                        child: Icon(Icons.play_circle,size: 40,)
                    ):
                    Container()
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Text('Details',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      )),
                ],
              ),
              Divider(),
              Text(
                widget.ad.description!,
                textAlign: TextAlign.start,
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 14),
              ),
              Divider(),
              Text(
                    'Advertiser Details',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                  ),
            Row(
              children: [
                  Container(
                    margin: EdgeInsets.only(right: 8),
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                '${Constants.profileImage(widget.ad.user!)}',
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception,
                                    StackTrace? stackTrace) {
                                  return Constants.defaultImage(
                                      50.0);
                                },
                              ))
                      ),
                Column(
                  crossAxisAlignment:CrossAxisAlignment.start,
                  children: [
                 
                
                  
                  SizedBox(height: 8),
                  Text(
                    'Name: ${widget.ad.user!.fname}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: ${widget.ad.user!.email}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Phone: ${widget.ad.user!.phone}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  Divider(),
                  
                  ],
                ),
              ],
            )
            ],
          ),
        ),
      ),
    );
  }
}

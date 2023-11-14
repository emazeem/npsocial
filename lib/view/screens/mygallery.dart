import 'package:flutter/material.dart';
import 'package:np_social/model/Gallery.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/view/screens/single_post.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/widgets/show_post.dart';
import 'package:np_social/view_model/gallery_view_model.dart';
import 'package:provider/provider.dart';


class MyGalleryScreen extends StatefulWidget {
  final int? user_id;
  const MyGalleryScreen(this.user_id);

  @override
  State<MyGalleryScreen> createState() => _MyGalleryScreenState();
}

class _MyGalleryScreenState extends State<MyGalleryScreen> {


  var authId;
  String? authToken;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      authToken=await AppSharedPref.getAuthToken();
      authId=await AppSharedPref.getAuthId();
      Map data={'id': '${widget.user_id}'};
      Provider.of<GalleryViewModel>(context,listen: false).fetchMygalleryImages(data,'${authToken}');

    });
  }


  @override
  Widget build(BuildContext context) {
    List<Gallery?> galleryImages=Provider.of<GalleryViewModel>(context).getGalleryImages;


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
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 4,horizontal: 2),
                child: Row(
                  children: [
                    Icon(Icons.image),
                    Text('Gallery images',style:Constants().np_heading,),
                  ],
                ),
              ),
              new Expanded(
                child: GridView.count(
                    crossAxisCount: 3,
                    //padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    children: List<Widget>.generate(galleryImages.length, (index){
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePostScreen(galleryImages[index]?.post_id)));
                        },
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            //child: Image.network('${Constants.postImage(galleryImages[index])}',fit: BoxFit.cover,)
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/image-placeholder.png',
                              image: Constants.postImage(galleryImages[index]),
                              fit: BoxFit.cover,
                            )
                        ),
                      );
                    })
                ),
              )
            ],
          ),
        )
    );
  }
}


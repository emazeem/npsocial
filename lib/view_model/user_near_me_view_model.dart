import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:np_social/model/Speciality.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/UserNearme.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/nearme_repo.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/widgets/layout.dart';

import '../view/screens/near-me.dart';

class UserNearmeViewModel extends ChangeNotifier {
  bool _isNearmeLoading = true;

  ApiResponse _apiResponse = ApiResponse();
  ApiResponse get fetchUserNearme => _apiResponse;

  UserNearme? _userNearme;
  NearmeRepo _nearmeRepo = NearmeRepo();
  List<Datum> _userNearmeList = [];
  List<Marker> _markers = [];

  // List<MapsUser> _userNearmedataList = [];

  List<Datum> get userNearmeList => _userNearmeList;
  List<Marker> get getMerker => _markers;
  UserNearme? get userNearme => _userNearme;
  bool get isNearmeLoading => _isNearmeLoading;

  Future fetchNearme(dynamic userdata, String token) async {
    setLoaderValue(
      value: true,
    );

    final response = await _nearmeRepo.fetchNearmeUsers(userdata, token);
    try {
      _userNearmeList = [];
      var json = response['data'];
      print('json: $json');

      // _userNearme = UserNearme.fromJson(json);

      for (var i = 0; i < json!.length; i++) {
        _userNearmeList.add(Datum.fromJson(json[i]));
      }
      print('userNearmeList: ${_userNearmeList.first.workplaceLatitude}');
      Completer<void> completer = Completer<void>();
      int completedCount = 0;

      _userNearmeList.forEach((element) async {
        await element.user.setImageBytes(element.user);
        completedCount++;
        if (completedCount == _userNearmeList.length) {
          completer.complete();
        }
      });
      await completer.future;

      setLoaderValue();
      notifyListeners();
      return response;
    } catch (e) {
      print(response);
      setLoaderValue();
      rethrow;
    }
  }

  void setLoaderValue({bool value = false}) {
    _isNearmeLoading = value;
    notifyListeners();
  }
  BaseApiServices _apiServices = NetworkApiServices();

  setUsersMarkers(List<Datum> nearmeList, BuildContext context, UserDetail userDetail) async {
    final index =nearmeList.indexWhere((element) => element.id == userDetail.id);
    print(index);
    _markers = [];
    Uint8List defaultimage = await getBytesFromAsset('assets/images/maps-and-flags.png', 100);

    for (int i = 0; i < nearmeList.length; i++) {
      _markers.add(Marker(
          markerId: MarkerId(nearmeList[i].id.toString()),
          position: LatLng(double.parse(nearmeList[i].workplaceLatitude),
              double.parse(nearmeList[i].workplaceLongitude)),
          //icon from network using nearmelist[i].user.profileImage

          icon: i == index
              ? BitmapDescriptor.defaultMarker
              : BitmapDescriptor.fromBytes(defaultimage),
          // nearmeList[i].user.uint8list ?? defaultimage),

          infoWindow: nearmeList[i].user.role ==Role.User? InfoWindow(
              title: nearmeList[i].user.fname + ' ' + nearmeList[i].user.lname,
              snippet: nearmeList[i].workplace):nearmeList[i].user.role ==Role.Organization?
              InfoWindow(
              title: nearmeList[i].user.fname ,
              snippet: nearmeList[i].workplace
              )
              :InfoWindow(
              title: '',
              snippet:  ''
              ),
          onTap: () async{
            String token=await AppSharedPref.getAuthToken();
            Speciality? _speciality=new Speciality();
            dynamic response=await _apiServices.getPostAuthApiResponse(AppUrl.fetchUserDetail, {'id':'${nearmeList[i].user.id}'}, token);
            if(response['data']['ambassador_details']['speciality_id']!=null){
              _speciality=Speciality.fromJson(response['data']['ambassador_details']['speciality']);
            }
            showMarkerBottomSheet(context, nearmeList[i], userDetail.user_id,_speciality);
          }));
    }
    notifyListeners();
  }

  void showMarkerBottomSheet(BuildContext context, Datum datum, int? id,Speciality _speciality) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.10,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(25.0),
            topRight: const Radius.circular(25.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              (datum == null)
                  ? Utils.LoadingIndictorWidtet()
                  : CachedNetworkImage(
                      placeholder: (context, url) =>
                          Utils.LoadingIndictorWidtet(),
                      errorWidget: (context, url, error) =>
                          Constants.defaultImage(40.0),
                      imageUrl: "${Constants.profileImage(datum.user)}",
                      width: 40,
                      height: 40,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
              // CircleAvatar(
              //   backgroundImage: NetworkImage('${Constants.profileImage(datum.user)}'),
              //   radius: 25,
              // ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  if (datum.userId != id) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtherProfileScreen(datum.user.id)));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NPLayout(
                                  currentIndex: 4,
                                )));
                  }
                },
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                 datum.user.role==Role.User?   Text(
                      '${datum.user.fname} ${datum.user.lname}',
                      style: TextStyle(fontSize: 18),
                    ):
                    Text(
                      '',
                      style: TextStyle(fontSize: 18),
                    ),
                    datum.user.role==Role.Organization?  Text(
                     '${datum.user.fname} ',
                      style: TextStyle(fontSize: 12),
                    ):
                    Text(
                      '',
                      style: TextStyle(fontSize: 18),
                    ),
                    (_speciality.title==null) ? Container() :
                    Text(
                      '${_speciality.title}',
                      style: TextStyle(fontSize: 12),
                    ),

                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}

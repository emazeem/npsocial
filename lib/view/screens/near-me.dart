import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/UserNearme.dart';
import 'package:np_social/res/constant.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_near_me_view_model.dart';
import 'package:provider/provider.dart';

class NearmeScreen extends StatefulWidget {
  const NearmeScreen({Key? key}) : super(key: key);

  @override
  State<NearmeScreen> createState() => _NearmeState();
}


Map<String, BitmapDescriptor> customMarkers = Map<String, BitmapDescriptor>();

UserDetail userDetail = UserDetail();
String? authToken;
var authId;

class _NearmeState extends State<NearmeScreen> {
  @override
  void initState() {
    super.initState();
    // map_marker_colorset();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};
      Provider.of<UserDetailsViewModel>(context, listen: false).getUserDetails(data, authToken!);
      Provider.of<UserNearmeViewModel>(context, listen: false).fetchNearme(data, authToken!);
    });
  }


  @override
  Widget build(BuildContext context) {
    userDetail = Provider.of<UserDetailsViewModel>(context).getDetails!;
    final nearmeList = context.watch<UserNearmeViewModel>().userNearmeList;
    final isloadoing = context.watch<UserNearmeViewModel>().isNearmeLoading;
    final markers = context.watch<UserNearmeViewModel>().getMerker;

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
        body: Column(
          children: [
            Expanded(
              child: Consumer(
                builder: (context, value, child) {
                  return isloadoing == true
                      ? Center(child: Utils.LoadingIndictorWidtet())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                double.parse(
                                    userDetail.workplace_latitude ?? '0.0'),
                                double.parse(
                                    userDetail.workplace_longitude ?? '0.0')),
                            zoom: 12,
                          ),
                          markers: Set.from(markers),
                          onMapCreated: (GoogleMapController controller) {
                           context.read<UserNearmeViewModel>().setUsersMarkers(nearmeList, context,userDetail);
                          },
                          myLocationEnabled: true,
                          mapType: MapType.normal,
                        );
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ));
  }
}

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/view/screens/single_post.dart';
import 'package:map_launcher/map_launcher.dart' as mt;


class Utils {

  static bool organizationSprint = true;
  static toastMessage(String message) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black,
      fontSize: 16.0,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static LoadingIndictorWidtet({size = 20.0}) {
    return Center(
      child: Container(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          semanticsLabel: 'Circular progress indicator',
          color: Constants.np_yellow,
        ),
      ),
    );
  }

  static flushBarMessage() {}
  static imageError(context, size) {}
  static snackBarMessage() {}
  static Widget socialInformation(String column, String value) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${column}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        width: 1,
                        child: Text(
                          '${value}',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.right,
                        ))),
              ],
            ),
            Divider(),
          ],
        ));
  }

  static Widget galleryImageWidget(context, galleryImage) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SinglePostScreen(galleryImage.post_id)));
      },
      child: Container(
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width / 3.61,
          height: 130,
          color: Colors.grey,
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/image-placeholder.png',
            image: Constants.postImage(galleryImage),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          )
          /*child: CachedNetworkImage(
            imageUrl:
            "${Constants.postImage(galleryImage)}",
            fit: BoxFit.cover,
            width: 150,
            height: 150,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Utils.LoadingIndictorWidtet(),
            errorWidget: (context, url, error) => Utils.LoadingIndictorWidtet(),
          )*/

          ),
    );
  }

  static bool _isNetworkErrorToastShown = false;
  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      if (!_isNetworkErrorToastShown) {
        Utils.toastMessage('No internet connection!');

        _isNetworkErrorToastShown = true;
      }
      return false;
    }
  }

  static showMapWithLongLat(long, lat, height) {
    CameraPosition initialCameraPosition =
        CameraPosition(target: LatLng(lat, long), zoom: 14.0);
    Set<Marker> markersList = {};
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: 'Location')));
    late GoogleMapController googleMapController;
    return Container(
      padding: EdgeInsets.all(10),
      height: height,
      child: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markersList,
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        circles: Set.from([
          Circle(
            circleId: CircleId("1"),
            center: LatLng(lat, long),
            radius: 1000, // 1000 meters
            fillColor: Colors.blue.withOpacity(0.3),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          )
        ]),
      ),
    );
  }

  static Future<void> openMap(
      double? latitude, double? longitude, location) async {
    final availableMaps = await mt.MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
      coords: mt.Coords(latitude!, longitude!),
      title: location,
    );
  }

  static hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static String changeDateType(String date) {
    if (date.isEmpty) {
      return '';
    } else {
      var myFormat = DateFormat('MM-dd-yyyy');
      final result = myFormat.format(DateTime.parse(date));
      return result;
    }
  }

  static Widget showImage(String image) {
    return CachedNetworkImage(
      imageUrl: image,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Utils.LoadingIndictorWidtet(),
      errorWidget: (context, url, error) => Image.asset(
        '${Constants.defaultCover}',
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

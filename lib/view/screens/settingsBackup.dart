import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/utils.dart';
import 'package:np_social/view/screens/current_location_screen.dart';
import 'package:np_social/view_model/UserDeviceViewModel.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

const kGoogleApiKey = 'AIzaSyBGJuEGra6A-9OpUKt9zSOq3NUA6hQC-zU';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _LocationScreenState extends State<LocationScreen> {
  var authToken;
  var authId;

  final _businessLocationController = TextEditingController();



  bool profileSelected = false;
  File profile = new File('');

  Set<Marker> markersList = {};

  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;

  String? _currentAddress;
  String? _currentCity;
  String? _currentState;
  String? _currentCountry;
  String? formattedAddress;

  double lng = 0.0;

  double lat = 0.0;

  static const CameraPosition initialCameraPosition =
  CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};
      Provider.of<UserDetailsViewModel>(context, listen: false)
          .getUserDetails(data, '${authToken}');
    });
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);
    var userDetailViewModel = Provider.of<UserDetailsViewModel>(context, listen: false);
    User? user = userViewModel.getUser;
    UserDetail? userDetail = Provider.of<UserDetailsViewModel>(context, listen: false).getDetails;

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
                    height: MediaQuery.of(context).size.height * 0.314,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, top: 20, bottom: 10),
                          child: Text(
                            'Edit Business Location',
                            style: Constants().np_heading,
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADDRESS: ${_currentAddress ?? ""}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'LAT: ${lat}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'LNG: ${lng}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'City: ${_currentCity ?? ""}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'State: ${_currentState ?? ""}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Country: ${_currentCountry ?? ""}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                    onPressed: () async {
                                      Map data = {
                                        'longitude': '${lng}',
                                        'latitude': '${lat}',
                                      };
                                      dynamic response =
                                          await userDetailViewModel
                                              .updateSocialInfo(
                                                  data, '${authToken}');
                                      if (response['success'] == true) {
                                        Utils.toastMessage(
                                            '${response['message']}');
                                      } else {
                                        Utils.toastMessage(
                                            '${response['message']}');
                                      }
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: initialCameraPosition,
                          markers: markersList,
                          mapType: MapType.normal,
                          onMapCreated: (GoogleMapController controller) {
                            googleMapController = controller;
                          },
                          circles: Set.from([
                            Circle(
                              circleId: CircleId("1"),
                              center: LatLng(lat, lng),
                              radius: 1000, // 1000 meters
                              fillColor: Colors.blue.withOpacity(0.3),
                              strokeColor: Colors.blue,
                              strokeWidth: 2,
                            )
                          ]),
                        ),
                        Positioned(
                          top: 5,
                          left: 10,
                          child: ElevatedButton(
                              onPressed: _handlePressButton,
                              child: const Text("Edit Business Location")),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          )),
      backgroundColor: Colors.white,
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))),
        components: [
          Component(Component.country, "pk"),
          Component(Component.country, "usa"),
        ]);
    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage!,
        contentType: ContentType.failure,
      ),
    ));
  }

  Future<void> displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    lat = detail.result.geometry!.location.lat;
    lng = detail.result.geometry!.location.lng;

    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));


    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    setState(() {
      _currentAddress = placemarks[0].name;
      _currentCity = placemarks[0].locality;
      _currentState = placemarks[0].administrativeArea;
      _currentCountry = placemarks[0].country;
    });

    setState(() {
      formattedAddress = detail.result.formattedAddress;
    });

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 13.0));
  }


}

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
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/UserDeviceViewModel.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

// https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6


class PracticeLocationScreen extends StatefulWidget {
  const PracticeLocationScreen({Key? key}) : super(key: key);

  @override
  State<PracticeLocationScreen> createState() => _PracticeLocationScreenState();
}

const kGoogleApiKey = 'AIzaSyBGJuEGra6A-9OpUKt9zSOq3NUA6hQC-zU';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _PracticeLocationScreenState extends State<PracticeLocationScreen> {
  var authToken;
  var authId;


  bool profileSelected = false;
  File profile = new File('');

  Set<Marker> markersList = {};

  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;

  FocusNode focusNode = FocusNode();



  String? _currentAddress;
  String? _currentCity;
  String? _currentState;
  String? _currentCountry;

  final workplaceController = TextEditingController();

  double lng = 0.0;
  double lat = 0.0;

  static CameraPosition initialCameraPosition = CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);

  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};
      Provider.of<UserDetailsViewModel>(context, listen: false).getUserDetails(data, '${authToken}');
    });
    UserDetail? userDetail = Provider.of<UserDetailsViewModel>(context, listen: false).getDetails;
    if(userDetail?.workplace_latitude!=null){
      double lat=double.parse('${userDetail?.workplace_latitude}');
      double long=double.parse('${userDetail?.workplace_longitude}');
      initialCameraPosition = CameraPosition(target: LatLng( lat,long), zoom: 14.0);
      setState(() {
        markersList.add(
            Marker(
                markerId: const MarkerId("0"),
                position: LatLng(lat, long),
                infoWindow: InfoWindow(title: 'Location')
            )
        );
      });
    }
    _currentCity=userDetail?.city;
    _currentState=userDetail?.state;
    _currentCountry=userDetail?.country;
    _currentAddress=userDetail?.address;
    workplaceController.text='${userDetail?.workplace!=null?userDetail?.workplace:''}';
    super.initState();

  }

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);
    var userDetailViewModel = Provider.of<UserDetailsViewModel>(context, listen: false);
    UserDetail? userDetail = userDetailViewModel.getDetails;
    User? user = userViewModel.getUser;

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
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(
                left: Constants.np_padding_only,
                right: Constants.np_padding_only,
                top: Constants.np_padding_only),
            child: Card(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                        _handlePressButton();
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 5,top: 10,left: 10,right: 10),
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade500
                            ),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              Icon(Icons.search,color: Colors.grey,),
                              SizedBox(width: 10,),
                              Text('Search your workplace location',style: TextStyle(fontSize: 20,color: Colors.grey),),
                            ],
                          ),
                          scrollDirection: Axis.horizontal,
                        )
                      ),
                    ),
                    /*Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('This will only record your city, state and country names.'),
                    ),*/
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: workplaceController,

                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Workplace',
                            ),
                          ),

                          /*Text('City',style: TextStyle(color: Colors.grey),),
                          fakeInput(_currentCity!),
                          Text('State',style: TextStyle(color: Colors.grey),),
                          fakeInput(_currentState!),
                          Text('Country',style: TextStyle(color: Colors.grey),),
                          fakeInput(_currentCountry!),
                          */

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                ),
                                onPressed: () async {
                                  Map data = {
                                    'id': '${authId}',
                                    'workplace_longitude': '${lng}',
                                    'workplace_latitude': '${lat}',
                                    'workplace': '${workplaceController.text}',
                                  };
                                  dynamic response =
                                  await userDetailViewModel.updateLocation(data, '${authToken}');
                                  if (response['success'] == true) {
                                    late UserDetail? ud=UserDetail();
                                    Provider.of<UserDetailsViewModel>(context,listen: false).getUserDetails({'id':'${authId}'}, authToken);
                                    ud= Provider.of<UserDetailsViewModel>(context,listen: false).getDetails;
                                    Utils.toastMessage('Workplace information updated successfully!');
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NPLayout(currentIndex: 4,)));
                                  } else {
                                    Utils.toastMessage('${response['message']}');
                                  }
                                },
                                child: const Text('Update'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child:GoogleMap(
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
                        )
                    ),
                  ],
                ),
              ),
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
        logo: SizedBox(),
        decoration: InputDecoration(
            hintText: 'Search your workplace location',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))
        ),
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

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey, apiHeaders: await const GoogleApiHeaders().getHeaders());
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
    lat = detail.result.geometry!.location.lat;
    lng = detail.result.geometry!.location.lng;


    markersList.add(
        Marker(
            markerId: const MarkerId("0"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: detail.result.name)
        )
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    setState(() {
      _currentCity = placemarks[0].locality;
      _currentState = placemarks[0].administrativeArea;
      _currentCountry = placemarks[0].country;
      _currentAddress= p.description;
      workplaceController.text= '${p.description}';

    });
    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 13.0));
  }
  Widget fakeInput(String title){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey.shade500
          ),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text(title,style: TextStyle(fontSize: 17),),
    );
  }

}

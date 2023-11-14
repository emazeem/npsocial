import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:np_social/res/constant.dart';

class CurrentLocationScreen extends StatefulWidget {
  CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

const kGoogleApiKey = 'AIzaSyBGJuEGra6A-9OpUKt9zSOq3NUA6hQC-zU';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
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
      body: Stack(
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
          // Text('LAT: ${_currentPosition?.latitude ?? ""}'),
          // Text('LNG: ${_currentPosition?.longitude ?? ""}'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Flexible(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADDRESS: ${_currentAddress ?? ""}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('City: ${_currentCity ?? ""}'),
                  Text('State: ${_currentState ?? ""}'),
                  Text('Country: ${_currentCountry ?? ""}'),
                ],
              ),
            ),
          ),

          Positioned(
            top: 120,
            left: 10,
            child: ElevatedButton(
                onPressed: _handlePressButton,
                child: const Text("Search Places")),
          ),
        ],
      ),
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

    markersList.clear();
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));
    print(
      "address : " + detail.result.toString(),
    );

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
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }
}

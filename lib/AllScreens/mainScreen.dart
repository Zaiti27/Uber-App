import 'dart:async';
import 'dart:ffi';
import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_uber_app/AllScreens/searchScreen.dart';
import 'package:flutter_uber_app/AllWidgets/Divider.dart';
import 'package:flutter_uber_app/AllWidgets/progressDialog.dart';
import 'package:flutter_uber_app/Assistant/assistantMethods.dart';
import 'package:flutter_uber_app/Assistant/assistantMethods.dart';
import 'package:flutter_uber_app/DataHandler/appData.dart';
import 'package:flutter_uber_app/Models/directionDetails.dart';
import 'package:flutter_uber_app/configMap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripDetails;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  double rideDetailContainer = 0.0;
  double searchContainerHeight = 320.0;
  bool drawerOpen = true;
  double requestRideDetail = 0;
  DatabaseReference riderRequestRef;
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController controller;
  Location _location = Location();

  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineInfo();
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _cntlr.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 15),
        ),
      );
    });
  }

  void saveRiderRequest() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog("Demande en cours ...");
        });
    riderRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Request");
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;
    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };
    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };
    Map riderinfoMap = {
      "driver_id": "waiting",
      "payment_method": "Cash",
      "pickUp": pickUpLocMap,
      "dropOff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.nom,
      "rider_prenom": userCurrentInfo.prenom,
      "rider_phone": userCurrentInfo.tel,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };
    riderRequestRef.push().set(riderinfoMap);
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 320.0;
      rideDetailContainer = 0.0;
      bottomPaddingOfMap = 320;
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      pLineCoordinates.clear();
    });
  }

  void displayRiderDetailContainer() async {
    await getPlaceDirecion();

    setState(() {
      searchContainerHeight = 0.0;
      rideDetailContainer = 320.0;
      bottomPaddingOfMap = 320;
      drawerOpen = false;
    });
  }

  /*void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("this is ur address :: " + address);
  }*/

  /*static final CameraPosition _myLocation = CameraPosition(
    target: LatLng(0, 0),
  );*/
  /* static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );*/
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 200.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 35.0, vertical: 2.0)),
                      Image.asset(
                        "images/user.png",
                        height: 70.0,
                        width: 70.0,
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Nom de Profile",
                            style:
                                TextStyle(fontSize: 22.0, color: Colors.blue),
                          ),
                          SizedBox(
                            width: 18.0,
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 28.0)),
                          Icon(
                            FontAwesomeIcons.pen,
                            color: Colors.blueGrey,
                            size: 22.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              DividerWidget(),
              SizedBox(
                height: 12.0,
              ),
              // Drawer body controller
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.history,
                  color: Colors.blue,
                  size: 18.0,
                ),
                title: Text(
                  "Historique",
                  style: TextStyle(fontSize: 17.0, color: Colors.blueGrey),
                ),
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.user,
                  color: Colors.blue,
                  size: 18.0,
                ),
                title: Text(
                  "Voir le profile",
                  style: TextStyle(fontSize: 17.0, color: Colors.blueGrey),
                ),
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.info,
                  color: Colors.blue,
                  size: 18.0,
                ),
                title: Text(
                  "A propos",
                  style: TextStyle(fontSize: 17.0, color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition:
                CameraPosition(target: _initialcameraposition),
            myLocationEnabled: true,
            onMapCreated: _onMapCreated,
            /*onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 318;
              });
              locatePosition();
            },*/
          ),

          // humberger button for drawer
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),

          // recherche button

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: searchContainerHeight,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: 320.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text(
                        "Où vous-allez ?",
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));

                          if (res == "obtainDirection") {
                            displayRiderDetailContainer();
                          }
                        },
                        child: Container(
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue,
                                // blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 15.0),
                              Text("Rechercher ici",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16.0)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 54.0,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  Provider.of<AppData>(context)
                                              .pickUpLocation !=
                                          null
                                      ? Provider.of<AppData>(context)
                                          .pickUpLocation
                                          .placeName
                                      : "Adresse domicile",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16.0)),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Ajouter l'adresse",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 26.0),
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Adresse Boulot",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16.0)),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Ajouter l'adresse",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ride details
          Positioned(
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailContainer,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300],
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                                bottomLeft: Radius.circular(16.0),
                                bottomRight: Radius.circular(16.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue,
                                blurRadius: 16.0,
                                // spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ]),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/car.png",
                                height: 80.0,
                                width: 80.0,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Automobile",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // la distance entre pickup et dropoff location
                                  /*Text(
                                    ((tripDetails.distanceText != null)
                                        ? '\$${tripDetails.distanceText}'
                                        : ''),
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.black),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Text(
                                ((tripDetails.distanceText != null)
                                    ? '\$${AssistantMethods.calculateFares(tripDetails)}'
                                    : ''),
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),*/
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt,
                                size: 18.0, color: Colors.blue),
                            SizedBox(
                              width: 26.0,
                            ),
                            Text(
                              "Cash",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          height: 50,
                          child: RaisedButton(
                            color: Colors.blue,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0)),
                            ),
                            onPressed: () {
                              saveRiderRequest();
                            },
                            //color: Theme.of(context).accentColor,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                5.0,
                                0.0,
                                5.0,
                                0.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Demander",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    color: Colors.white,
                                    size: 18.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Void> getPlaceDirecion() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              " en attente ...",
            ));

    var details =
        await AssistantMethods.obtainDirectionsDetails(pickUpLng, dropOffLng);
    Navigator.pop(context);
    setState(() {
      tripDetails = details;
    });

    print("This is encoded points :: ");
    print(details.encodePoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResults =
        polylinePoints.decodePolyline(details.encodePoints);
    pLineCoordinates.clear();
    if (decodedPolyLinePointsResults.isNotEmpty) {
      decodedPolyLinePointsResults.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLng.latitude > dropOffLng.latitude &&
        pickUpLng.longitude > dropOffLng.longitude) {
      latLngBounds = LatLngBounds(southwest: dropOffLng, northeast: pickUpLng);
    } else if (pickUpLng.latitude > dropOffLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLng.latitude, pickUpLng.longitude),
          northeast: LatLng(pickUpLng.latitude, dropOffLng.longitude));
    } else if (pickUpLng.longitude > dropOffLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLng.latitude, dropOffLng.longitude),
          northeast: LatLng(dropOffLng.latitude, dropOffLng.longitude));
    } else {
      latLngBounds = LatLngBounds(southwest: pickUpLng, northeast: dropOffLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickupLocMarker = Marker(
      markerId: MarkerId("pickUpID"),
      infoWindow: InfoWindow(
          title: initialPos.placeName, snippet: "Ma localisation de départ"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: pickUpLng,
    );
    Marker dropoffLocMarker = Marker(
      markerId: MarkerId("dropOffID"),
      infoWindow: InfoWindow(
          title: initialPos.placeName, snippet: "Ma localisation d'arrivée"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLng,
    );
    setState(() {
      markerSet.add(pickupLocMarker);
      markerSet.add(dropoffLocMarker);
    });
    Circle pickUpLocCircle = Circle(
      circleId: CircleId("pickUpId"),
      fillColor: Colors.blue,
      center: pickUpLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.white,
    );
    Circle dropOffLocCircle = Circle(
      circleId: CircleId("dropOffId"),
      fillColor: Colors.blue,
      center: dropOffLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.white,
    );
    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void modifyUser(BuildContext context) async {}
}

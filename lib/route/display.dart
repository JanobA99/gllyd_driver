import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gllyd_driver/model/busstop.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gllyd_driver/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class RouteDisplayPage extends StatefulWidget {

  RouteDisplayPage({Key key, this.busStops, this.trafficEnabled}) : super(key: key);
  final List<BusStop> busStops;
  bool trafficEnabled;

  @override
  _RouteDisplayPageState createState() => _RouteDisplayPageState();
}

class _RouteDisplayPageState extends State<RouteDisplayPage> {
  final double barHeight = 93.0;


  //Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyAA_JAG3GB2wCPlrDDxCU20bW0W_9L5hX0";

  List<LatLng> polylineFullCoordinates = [];
  PolylinePoints polylineFullPoints = PolylinePoints();

  List<double> distancesList = [];

  int curStop = 0;
  Uint8List destinationIcon;
  Uint8List busIcon;
  String startLabel;
  String endLabel;
  int stopIndex = 0 ;
  bool moveCamera = false;
  int nextPosition  = 0;

  StreamSubscription<Position> positionStream;
  double curLat = 0;
  double curLng = 0;
  bool bShowOnce = false;

  IconData arrow = null;

  int circuit = 0;

  // For Testing...
  int tempPos = 0;

  // Bus History information
  String driverId = "";
  String routeId = "";
  String date = "";
  String yearOfToday = "";
  String monthOfToday = "";
  String dayOfToday = "";
  String startTime = "";
  String endTime = "";
  double distance = 0;

  bool bPanicEnabled = true;
  bool bShowNotification = false;
  bool bMapCreated = false;

  int target = 0;

  @override
  void initState() {
    loadData();
    setSourceAndDestinationIcons() ;
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    if (positionStream != null)
      positionStream.cancel();
    super.dispose();
  }

  loadData() async {
    target = 2;  // first destination bus stop
    SharedPreferencesHelper.getPanicFlag().then((value) {
      setState(() {
        bPanicEnabled = value;
      });
    });
    SharedPreferencesHelper.getTodayCircuit().then((value) {
      setState(() {
        circuit = value;
      });
    });
    SharedPreferencesHelper.getUserIdCode().then((value) {
      driverId = value;
    });
    SharedPreferencesHelper.getRouteIdCode().then((value) {
      routeId = value;
    });
    date = DateFormat('y-M-d').format(new DateTime.now());
    yearOfToday = DateFormat('y').format(new DateTime.now());
    monthOfToday = DateFormat('M').format(new DateTime.now());
    dayOfToday = DateFormat('d').format(new DateTime.now());
    startTime = DateFormat('k:m').format(new DateTime.now());

    for(int i = 0; i < widget.busStops.length - 1; i++) {
      double distanceInMeters = await Geolocator().distanceBetween(widget.busStops[i].lat, widget.busStops[i].lng, widget.busStops[i + 1].lat, widget.busStops[i + 1].lng);
      distance += distanceInMeters;
    }
    print("Driver ID: " + driverId);
    print("Route ID: " + routeId);
    print("Date: " + date);
    print("Start time: " + startTime);
    print("Distance: " + distance.toString());
  }

  void setSourceAndDestinationIcons() async {
    destinationIcon = await getBytesFromAsset('assets/images/directions_bus.png', 80);
    busIcon = await getBytesFromAsset('assets/images/bus.png', 40);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void calculateDistance() async {
    for (int i = nextPosition; i < polylineCoordinates.length - 1; i++) {
      if (((polylineCoordinates[i].latitude <= curLat && curLat <= polylineCoordinates[i + 1].latitude)
          || (polylineCoordinates[i + 1].latitude <= curLat && curLat <= polylineCoordinates[i].latitude))
          &&
          ((polylineCoordinates[i].longitude <= curLng && curLng <= polylineCoordinates[i + 1].longitude)
              || (polylineCoordinates[i + 1].longitude <= curLng && curLng <= polylineCoordinates[i].longitude))) {
        nextPosition = i + 1;
        break;
      }
    }

    if (nextPosition >= polylineCoordinates.length)
      nextPosition = polylineCoordinates.length - 1;

    double distanceInMeters = await Geolocator().distanceBetween(curLat, curLng, polylineCoordinates[nextPosition].latitude, polylineCoordinates[nextPosition].longitude);
    for (int i = nextPosition; i < distancesList.length; i++)
      distanceInMeters += distancesList[i];

    if (distanceInMeters < 600) // For testing...
      print("distance: " + distanceInMeters.toString());

    if (distanceInMeters < 10) {
      setState(() {
        arrow = null;
      });

      if (stopIndex == (widget.busStops.length - 2)) {
        moveCamera = false;
        setState(() {
          circuit = circuit + 1;
        });
        SharedPreferencesHelper.setTodayCircuit(circuit);

        // Save Circuit details.
        endTime = DateFormat('k:m').format(new DateTime.now());
        DocumentReference ref = await Firestore.instance.collection("bus_history").add({
          'driver_id': driverId,
          'route_id': routeId,
          'date': date,
          'year': yearOfToday,
          'month': monthOfToday,
          'day': dayOfToday,
          'start_time': startTime,
          'end_time': endTime,
          'circuit': circuit,
          'distance': distance,
        });
        print("Document ID:" + ref.documentID);

        // Restart bus from start position.
        target = 2;  // rest destination bus stop
        stopIndex = 0;
        tempPos = 0;
        nextPosition = 0;
        moveCamera = false;
        bShowOnce = false;
        startTime = DateFormat('k:m').format(new DateTime.now());
        setPolylines();
      } else {
        stopIndex = stopIndex + 1;
        target = target + 1;  // next destination bus stop
        tempPos = 0;
        nextPosition = 0;
        moveCamera = false;
        bShowOnce = false;
        setPolylines();
      }
    } else {
      double bearing = await Geolocator().bearingBetween(curLat, curLng, polylineCoordinates[nextPosition].latitude, polylineCoordinates[nextPosition].longitude);
      setMapPins(bearing);
      if (bearing > -45 && bearing < 45) {
        setState(() {
          arrow = Icons.arrow_upward;
        });
      }
      else if (bearing > -135 && bearing <= -45) {
        setState(() {
          arrow = Icons.arrow_back;
        });
      }  else if (bearing >= 45 && bearing < 135) {
        setState(() {
          arrow = Icons.arrow_forward;
        });
      } else if (bearing <= -135 || bearing >= 135) {
        setState(() {
          arrow = Icons.arrow_downward;
        });
      }

      if (bShowOnce == false && distanceInMeters < 500) {
        bShowOnce = true;
        bShowNotification = true;
        _settingModalBottomSheet(context);
        hidePopup();
      }
    }

  }

  hidePopup() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    if (bShowNotification) {
      Navigator.of(context).pop();
      bShowNotification = false;
    }
  }

  void addDistanceList(double startLat, double startLng, double endLat, double endLng) async {
    double distanceInMeters = await Geolocator().distanceBetween(startLat, startLng, endLat, endLng);
    //print("distance: " + distanceInMeters.toString());
    distancesList.add(distanceInMeters);
  }

  void setMapPins(double bearing) {
    _markers.clear();

    if (this.mounted){
      setState(() {
        // source pin
        /*_markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng(widget.busStops[0].lat, widget.busStops[0].lng),

        ));*/
        // destination pin
        _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: LatLng(widget.busStops[stopIndex + 1].lat, widget.busStops[stopIndex + 1].lng),
          icon: BitmapDescriptor.fromBytes(destinationIcon),
        ));

        if (curLat != 0 && curLng != 0) {
          _markers.add(Marker(
            markerId: MarkerId('busPin'),
            position: LatLng(curLat, curLng),
            anchor: Offset(0.5, 0.5),
            rotation: bearing,
            icon: BitmapDescriptor.fromBytes(busIcon),
          ));

          updateData(bearing);
        }
      });
    }
  }

  void updateData(double bearing) async {
    try {
      Firestore.instance.collection('drivers').document(driverId)
          .updateData({'lat': curLat, 'lng': curLng, 'bearing': bearing, 'target': target});
    } catch (e) {
      print(e.toString());
    }
  }

  setFullPolylines() async {
    polylineFullCoordinates.clear();
    for (int i = 0; i < widget.busStops.length - 1; i++) {
      List<PointLatLng> result = await polylineFullPoints?.getRouteBetweenCoordinates(
          googleAPIKey,
          widget.busStops[i].lat,
          widget.busStops[i].lng,
          widget.busStops[i + 1].lat,
          widget.busStops[i + 1].lng);
      if (result.isNotEmpty) {
        polylineFullCoordinates.add(LatLng(widget.busStops[i].lat, widget.busStops[i].lng));
        result.forEach((PointLatLng point) {
          polylineFullCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        polylineFullCoordinates.add(LatLng(widget.busStops[i + 1].lat, widget.busStops[i + 1].lng));
      }

      if (this.mounted){
        setState(() {
          Polyline polyline = Polyline(
              polylineId: PolylineId("poly"),
              color: Colors.grey, //Color.fromRGBO(63, 110, 147, 1),
              width: 8,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              points: polylineFullCoordinates);

          _polylines.add(polyline);
        });
      }
    }
  }

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        widget.busStops[stopIndex].lat,
        widget.busStops[stopIndex].lng,
        widget.busStops[stopIndex + 1].lat,
        widget.busStops[stopIndex + 1].lng);
    if (result.isNotEmpty) {
      polylineCoordinates.clear();
      distancesList.clear();
      polylineCoordinates.add(LatLng(widget.busStops[stopIndex].lat, widget.busStops[stopIndex].lng));
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      polylineCoordinates.add(LatLng(widget.busStops[stopIndex + 1].lat, widget.busStops[stopIndex + 1].lng));
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        addDistanceList(polylineCoordinates[i].latitude, polylineCoordinates[i].longitude, polylineCoordinates[i + 1].latitude, polylineCoordinates[i + 1].longitude);
      }
    }

    if (polylineCoordinates.length > 0) {
       curLat = polylineCoordinates[0].latitude;
       curLng = polylineCoordinates[0].longitude;

      _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: LatLng(curLat, curLng))));
      //setMapPins();
      calculateDistance();
    }

    setState(() {
      /*Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Colors.grey, //Color.fromRGBO(63, 110, 147, 1),
          width: 10,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: polylineCoordinates);

      _polylines.add(polyline);*/
      moveCamera = true;
    });
  }

  void getCurrentLocation() async {
    Geolocator geolocator = Geolocator(); //..forceAndroidLocationManager = true;
    GeolocationStatus geolocationStatus = await geolocator.checkGeolocationPermissionStatus();
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    //print("locationLatitude: ${position.latitude.toString()}");
    //print("locationLongitude: ${position.longitude.toString()}");

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high/*, distanceFilter: 10*/);
    try {
      positionStream = geolocator.getPositionStream(locationOptions).listen(
              (Position position) {
            if (position != null && moveCamera){
              //print("new locationLatitude: ${position.latitude.toString()}");
              //print("new locationLongitude: ${position.longitude.toString()}");
              /*curLat = position.latitude;
              curLng = position.longitude;
              _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: LatLng(curLat, curLng))));
              setMapPins();
              calculateDistance();*/


              // For testing...
              if (polylineCoordinates.length > 0) {
                if (tempPos < polylineCoordinates.length) {
                  curLat = polylineCoordinates[tempPos].latitude;
                  curLng = polylineCoordinates[tempPos].longitude;
                  tempPos += 1;
                } else {
                  curLat = polylineCoordinates[polylineCoordinates.length - 1].latitude;
                  curLng = polylineCoordinates[polylineCoordinates.length - 1].longitude;
                }

                _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: LatLng(curLat, curLng))));
                //setMapPins();
                calculateDistance();
              }
            }
          }
      );
    } on PlatformException catch (e) {
      print("PlatformException");
      positionStream.cancel();
    }
  }

  showToolsPage() async {
    await Navigator.pushNamed(context, '/ToolsPage');
    SharedPreferencesHelper.getTrafficCode().then((value) {
      widget.trafficEnabled = value;
    });

  }

  @override
  Widget build (BuildContext context) {
    final double statusHeight = MediaQuery.of(context).padding.top;

    startLabel = widget.busStops[stopIndex].label;
    endLabel = widget.busStops[stopIndex + 1].label;
    CameraPosition initialLocation = CameraPosition(
        zoom: 15,
        //target: curLat == 0 && curLng == 0 ? LatLng((widget.busStops[0].lat + widget.busStops[1].lat) / 2, (widget.busStops[0].lng + widget.busStops[1].lng) / 2) : LatLng(curLat, curLng));
        target: curLat == 0 && curLng == 0 ? LatLng(widget.busStops[stopIndex].lat, widget.busStops[stopIndex].lng) : LatLng(curLat, curLng));

    return new Scaffold(
        body: new Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              new Container (
                margin: new EdgeInsets.only(top:statusHeight),
                decoration: new BoxDecoration(
                  color: Color.fromRGBO(63, 110, 147, 1),
                ),
                height: barHeight,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left:20.0, right: 20.0),
                          child: new Icon(Icons.arrow_upward, size: 48, color: Colors.white, ),
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new RichText(
                              text: new TextSpan(
                                children: <TextSpan>[
                                  new TextSpan(text: startLabel, style: new TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),),
                                  //new TextSpan(text: ' Ave', style: new TextStyle(color: Colors.white, fontSize: 13),),
                                ],
                              ),
                            ),
                            new RichText(
                              text: new TextSpan(
                                children: <TextSpan>[
                                  new TextSpan(text: 'toward ', style: new TextStyle(color: Colors.white, fontSize: 13),),
                                  new TextSpan(text: endLabel, style: new TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                                  //new TextSpan(text: ' Ave', style: new TextStyle(color: Colors.white, fontSize: 13),),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Visibility(
                    visible: widget.trafficEnabled,
                    child: Container(
                      height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 50 - barHeight,
                      child: GoogleMap(
                        //myLocationEnabled: true,
                        mapType: MapType.normal,
                        initialCameraPosition: initialLocation,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                          //setMapPins();
                          if (bMapCreated == false) {
                            bMapCreated = true;
                            setFullPolylines();
                            setPolylines();
                          }
                        },
                        markers: _markers,
                        polylines: _polylines,
                        trafficEnabled: true, //widget.trafficEnabled,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !widget.trafficEnabled,
                    child: Container(
                      height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 50 - barHeight,
                      child: GoogleMap(
                        //myLocationEnabled: true,
                        mapType: MapType.normal,
                        initialCameraPosition: initialLocation,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                          //setMapPins();
                          if (bMapCreated == false) {
                            bMapCreated = true;
                            setFullPolylines();
                            setPolylines();
                          }
                        },
                        markers: _markers,
                        polylines: _polylines,
                        trafficEnabled: false, //widget.trafficEnabled,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: arrow != null,
                    child: new Container(
                      color: Color.fromRGBO(50, 88, 117, 1),
                      child: FlatButton.icon(
                        onPressed: () {
                          //showStopAlert(context);
                        },
                        label: Text('Then', style: TextStyle(color: Colors.white, fontSize: 20),),
                        icon: Icon(arrow, size: 24, color: Colors.white, ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:24.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: RawMaterialButton(
                        onPressed: () {
                          if (bPanicEnabled) {
                            showPanicAlert(context);
                            _settingPanicBottomSheet(context);
                          } else {
                            setState(() {
                              bPanicEnabled = true;
                            });
                            SharedPreferencesHelper.setPanicFlag(true);
                          }
                        },
                        child: new Icon(
                          Icons.warning,
                          color: bPanicEnabled ? Color.fromRGBO(50, 88, 117, 1) : Color.fromRGBO(245, 166, 35, 1),
                          size: 24.0,
                        ),
                        shape: new CircleBorder(),
                        fillColor: Colors.white,
                        padding: EdgeInsets.all(10.0),
                      ),
                    ),

                  ),
                ],
              )
            ],
          ),
        ),
        floatingActionButtonLocation:
          FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.apps),
          onPressed: () {
            showToolsPage();
          },
          foregroundColor: Color.fromRGBO(63, 110, 147, 1),
          backgroundColor: Colors.white,
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Container(
            height: 50.0,
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FlatButton.icon(
                  label: Text('0', style: TextStyle(color: Colors.black, fontSize: 17),),
                  icon: Icon(Icons.supervisor_account, size: 24, color: Color.fromRGBO(155, 155, 155, 1), ),
                  onPressed: () {

                  },
                ),
                FlatButton.icon(
                  label: Text(circuit.toString(), style: TextStyle(color: Colors.black, fontSize: 17),),
                  icon: Icon(Icons.refresh, size: 24, color: Color.fromRGBO(155, 155, 155, 1), ),
                  onPressed: () {

                  },
                ),
              ],
            ),
          ),

        ),
      );
  }

  Future<void> showStopAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.close, size: 24, color: Color.fromRGBO(155, 155, 155, 1), ),
                  new Row(
                    children: <Widget>[
                      RawMaterialButton(
                        onPressed: () {},
                        child: new Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                          size: 40.0,
                        ),
                        shape: new CircleBorder(),
                        fillColor: Color.fromRGBO(63, 110, 147, 1),
                      ),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text('Bus stop in 500 m', style: TextStyle(color: Colors.black, fontSize: 16),),
                          new Text(endLabel /*'Manelseva st. bust stop'*/, style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1), fontSize: 16),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _settingModalBottomSheet(context){
    SharedPreferencesHelper.getSoundCode().then((value) {
      if (value)
        FlutterRingtonePlayer.playNotification();
    });

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Container(
                padding: const EdgeInsets.only(
                    left: 25.0, top: 27.0, right: 25.0, bottom: 25.0),
                height: 150,
                child: new Container (
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                        child: new GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            bShowNotification = false;
                          },
                          child: Icon(Icons.close, size: 24,
                            color: Color.fromRGBO(155, 155, 155, 1),),
                        ),
                      ),
                      new Row(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {},
                            child: new Icon(
                              Icons.pin_drop,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            shape: new CircleBorder(),
                            fillColor: Color.fromRGBO(63, 110, 147, 1),
                          ),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text('Bus stop in 500 m', style: TextStyle(
                                  color: Colors.black, fontSize: 16),),
                              new Text(endLabel /*'Manelseva st. bust stop'*/,
                                style: TextStyle(
                                    color: Color.fromRGBO(155, 155, 155, 1),
                                    fontSize: 16),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
            ),
          );
        }
    );
  }

  Future<void> showPanicAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 220,
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),),
              color: Colors.white,
              border: Border.all(color: Color.fromRGBO(245, 166, 35, 1), width: 1),
            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Icon(Icons.warning, size: 40, color: Color.fromRGBO(245, 166, 35, 1), )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text('Panic Button Activated', style: TextStyle(color: Colors.black, fontSize: 20), ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Center(
                      child: Text('Help is on the way', style: TextStyle(color: Colors.black, fontSize: 16), ),
                    )
                ),
                Expanded(
                  child: Text(''),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:20.0),
                  child: new Container (
                    decoration: new BoxDecoration(
                      color: Color.fromRGBO(245, 166, 35, 1),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    height: 50.0,
                    child: FlatButton(
                      child: Text('Deactivate', style: TextStyle(color: Colors.white, fontSize: 16),),
                      onPressed: () {
                        setState(() {
                          bPanicEnabled = false;
                        });
                        SharedPreferencesHelper.setPanicFlag(false);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _settingPanicBottomSheet(context){
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        builder: (BuildContext bc){
          return Container(
              height: 152,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  new Container(
                    height: 50,
                    child: new GestureDetector(
                      onTap: () {
                        launch("tel://+234 666 348625");
                      },
                      child: new Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text('Call HG', style: TextStyle(color: Colors.white, fontSize: 17), )),
                          ),
                          Expanded(
                            flex: 0,
                            child: Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.call, size: 24, color: Colors.white, )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: Colors.white, height: 1.0,),
                  new Container(
                    height: 50,
                    child: new GestureDetector(
                      onTap: () {
                        launch("tel://+234 666 348625");
                      },
                      child: new Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text('Call Emergency Center', style: TextStyle(color: Colors.white, fontSize: 17), )),
                          ),
                          Expanded(
                            flex: 0,
                            child: Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.call, size: 24, color: Colors.white, )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: Colors.white, height: 1.0,),
                  new Container(
                    height: 50,
                    child: new GestureDetector(
                      onTap: () {
                        launch("tel://+234 666 348625");
                      },
                      child: new Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text('Call Law Enforcement', style: TextStyle(color: Colors.white, fontSize: 17), )),
                          ),
                          Expanded(
                            flex: 0,
                            child: Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.call, size: 24, color: Colors.white, )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          );
        }
    );
  }
}
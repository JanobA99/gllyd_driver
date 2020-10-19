import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gllyd_driver/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:gllyd_driver/model/busstop.dart';
import 'package:gllyd_driver/route/splash.dart';
import 'package:geolocator/geolocator.dart';

class MorningPage extends StatefulWidget {
  MorningPage({Key key, this.startLat, this.startLng, this.endLat, this.endLng}) : super(key: key);

  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  @override
  _MorningPageState createState() => _MorningPageState();
}


class _MorningPageState extends State<MorningPage> {

  String username = "";
  String routeNum = "";
  String routeStart = "";
  String routeEnd = "";

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyAA_JAG3GB2wCPlrDDxCU20bW0W_9L5hX0";

  Uint8List markerIcon;

  List<BusStop> busStops = [];

  @override
  void initState() {
    super.initState();
    setSourceAndDestinationIcons();
    loadName();
    loadRoute();
  }

  void setSourceAndDestinationIcons() async {
    markerIcon = await getBytesFromAsset('assets/images/bus.png', 50);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  loadName() async {
    SharedPreferencesHelper.getUsernameCode().then((value) {
      setState(() {
        username = value;
      });
    });
  }

  void setMapPins() async {
    double bearing = await Geolocator().bearingBetween(widget.startLat, widget.startLng, widget.endLat, widget.endLng);
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng(widget.startLat, widget.startLng),
          rotation: bearing,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(markerIcon),));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: LatLng(widget.endLat, widget.endLng),));
    });
  }

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        widget.startLat,
        widget.startLng,
        widget.endLat,
        widget.endLng);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    if (this.mounted) {
      setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId("poly"),
            color: Colors.white, //Color.fromRGBO(63, 110, 147, 1),
            width: 8,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            points: polylineCoordinates);

        _polylines.add(polyline);
      });
    }
  }

  loadRoute() async {
    SharedPreferencesHelper.getUserIdCode().then((value) {
      Firestore.instance.collection('schedules')
          .where('driver_id', isEqualTo: value)
          .snapshots().listen((data) {
            String routeId = data.documents[0]['route_id'];
            Firestore.instance.collection('routes')
                .document(routeId)
                .snapshots().listen((data) {
                    setState(() {
                      routeNum = data['number'];
                      routeStart = data['start_pos'];
                      routeEnd = data['end_pos'];
                      /*startLat = double.parse(data['start_lat']);
                      startLng = double.parse(data['start_lng']);
                      endLat = double.parse(data['end_lat']);
                      endLng = double.parse(data['end_lng']);*/
                    });

                    //busStops.add(BusStop(lat: widget.startLat, lng: widget.startLng, routeId: routeId, isStart: true, isReturn: false, label: routeStart));
                    Firestore.instance.collection('bus_stops')
                        .where('route_id', isEqualTo: routeId)
                        .orderBy('stop_id')
                        .getDocuments()
                        .then((QuerySnapshot snapshot) {
                            snapshot.documents.forEach((f) =>
                                busStops.add(BusStop(lat: double.parse(f.data['lat']), lng: double.parse(f.data['lng']), routeId: f.data['route_id'], isStart: false, isReturn: false, label: f.data['label']))
                            );
                            //busStops.add(BusStop(lat: widget.endLat, lng: widget.endLng, routeId: routeId, isStart: false, isReturn: true, label: routeEnd));
                        });
                });
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: 11.8,
        target: LatLng((widget.startLat + widget.endLat) / 2, (widget.startLng + widget.endLng) / 2));

    return Scaffold(
      backgroundColor: Color.fromRGBO(63, 110, 147, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(DateFormat('EEEE K:m a').format(new DateTime.now()), style: TextStyle(color: Colors.black), ),
        iconTheme: new IconThemeData(color: Colors.grey),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left:25.0, top:60.0),
              child: new Text('Hello,\n' + username + '!', style: TextStyle(color: Colors.white, fontSize: 60),),
            ),
            Padding(
              padding: const EdgeInsets.only(left:25.0, top:27.0),
              //child: new Text('Your route for today is 25B.\nRouwel st. to White sq.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
              child: new RichText(
                  text: new TextSpan(
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      new TextSpan(text: 'Your route for today is '),
                      new TextSpan(text: routeNum + '\n', style: new TextStyle(fontWeight: FontWeight.bold),),
                      new TextSpan(text: routeStart, style: new TextStyle(fontWeight: FontWeight.bold),),
                      new TextSpan(text: ' to '),
                      new TextSpan(text: routeEnd, style: new TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:25.0, top:27.0, right:25.0),
              child: new Container (
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 450.0,
                child: GoogleMap(
                  //myLocationEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: initialLocation,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setMapPins();
                    setPolylines();
                  },
                  markers: _markers,
                  polylines: _polylines,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
                  ].toSet(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left:25.0, top:27.0, right:25.0),
              child: new Container (
                decoration: new BoxDecoration(
                  color: Color.fromRGBO(245, 166, 35, 1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 48.0,
                child: FlatButton(
                  child: Text('Start', style: TextStyle(color: Colors.white, fontSize: 17),),
                  onPressed: () {
                    //Navigator.pushNamed(context, '/DaySplashPage');
                    SharedPreferencesHelper.getTrafficCode().then((value) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DaySplashPage(busStops: busStops, trafficEnabled: value)));
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:27.0),
              child: Divider(color: Colors.white,),
            ),
            Padding(
              padding: const EdgeInsets.only(left:25.0, top:27.0, right:25.0, bottom:25.0),
              child: Row (
                children: <Widget>[
                  Expanded(
                    child: new Container (
                      margin: const EdgeInsets.only(right: 12.0),
                      decoration: new BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          launch("tel://+234 666 348625");
                        },
                        padding: EdgeInsets.all(20.0),
                        child: Column( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Icon(Icons.call),
                            Text('Call a fleet\nmanager', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16),),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new Container (
                      margin: const EdgeInsets.only(left: 12.0),
                      decoration: new BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          launch("sms://+234 666 348625");
                        },
                        padding: EdgeInsets.all(20.0),
                        child: Column( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Icon(Icons.chat),
                            Text('Message a\nfleet manager', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:gllyd_driver/model/travel.dart';
import 'package:gllyd_driver/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gllyd_driver/model/circuit.dart';
import 'package:gllyd_driver/utils.dart';

class DetailPage extends StatefulWidget {

  final Travel travel;
  DetailPage({Key key, this.travel}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {


  String googleAPIKey = "AIzaSyAA_JAG3GB2wCPlrDDxCU20bW0W_9L5hX0";
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  PolylinePoints polylinePoints = PolylinePoints();
  double bearing = 0;

  Uint8List busIcon;

  @override
  void initState() {
    super.initState();
    setIcons();
  }

  void setIcons() async {
    busIcon = await getBytesFromAsset('assets/images/bus.png', 50);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void setMapPins() async{
    double bearing = await Geolocator().bearingBetween(widget.travel.startLat, widget.travel.startLng, widget.travel.endLat, widget.travel.endLng);
    setState(() {
      // source pin
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: LatLng(widget.travel.startLat, widget.travel.startLng),
        rotation: bearing,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(busIcon),));
      // destination pin
      _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: LatLng(widget.travel.endLat, widget.travel.endLng),));
    });
  }

  setCircles() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        widget.travel.startLat,
        widget.travel.startLng,
        widget.travel.endLat,
        widget.travel.endLng);
    if (result.isNotEmpty) {
      int i = 1;
      result.forEach((PointLatLng point) {
        if (i % 12 == 0) {
          setState(() {
            Circle circle = Circle(
              circleId: CircleId('point' + i.toString()),
              center: LatLng(point.latitude, point.longitude),
              fillColor: Colors.blue,
              strokeColor: Colors.white,
              radius: 250,
            );
            _circles.add(circle);
          });
        }
        i++;
      });
    }
  }

  @override
  Widget build (BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        //bearing: widget.travel.bearing,
        zoom: 11.8,
        target: LatLng((widget.travel.startLat + widget.travel.endLat) / 2, (widget.travel.startLng + widget.travel.endLng) / 2));

    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          iconTheme: new IconThemeData(color: Colors.grey),
        ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(63, 110, 147, 1),),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:20.0, right: 20.0, top:15.0),
                  child: Text(widget.travel.startPos + ' to ' + widget.travel.endPos, style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:20.0, right: 20.0, top:15.0, bottom: 15.0),
                  child: Text(widget.travel.fullDate, style: TextStyle(color: Color.fromRGBO(231, 231, 231, 1), fontSize: 16)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:20.0, right: 20.0, top:10.0, bottom: 10.0),
            child: Text("Details", style: TextStyle(color: Colors.black, fontSize: 20),),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left:20.0, right: 20.0, top:10.0, bottom: 10.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RichText(
                  text: new TextSpan(
                    children: <TextSpan>[
                      new TextSpan(text: 'xxx', style: TextStyle(color: Colors.black, fontSize: 16),),
                      new TextSpan(text: ' people delievered    ', style: TextStyle(color: Colors.grey, fontSize: 16),),
                      new TextSpan(text: widget.travel.circuitArray.length.toString(), style: TextStyle(color: Colors.black, fontSize: 16),),
                      new TextSpan(text: ' route circuits', style: TextStyle(color: Colors.grey, fontSize: 16),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:10.0),
                  child: RichText(
                    text: new TextSpan(
                      children: <TextSpan>[
                        new TextSpan(text: Utils.convertToHours(widget.travel.minutes) +' h', style: TextStyle(color: Colors.black, fontSize: 16),),
                        new TextSpan(text: ' trip lasted    ', style: TextStyle(color: Colors.grey, fontSize: 16),),
                        new TextSpan(text: Utils.convertToKm(widget.travel.distance) +' km', style: TextStyle(color: Colors.black, fontSize: 16),),
                        new TextSpan(text: ' distance', style: TextStyle(color: Colors.grey, fontSize: 16),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: GoogleMap(
              //myLocationEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: initialLocation,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                setMapPins();
                setCircles();
              },
              markers: _markers,
              circles: _circles,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.details),
        onPressed: () {
          _settingModalBottomSheet(context);
        },
        foregroundColor: Color.fromRGBO(63, 110, 147, 1),
        backgroundColor: Colors.white,
      ),
    );
  }

  void _settingModalBottomSheet(context){

    ListTile makeListTile(Circuit circuit) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      leading: Container(
        //decoration: new BoxDecoration(border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))),
        child: RawMaterialButton(
          onPressed: () {},
          child: new Icon(
            Icons.refresh,
            color: Colors.black,
          ),
          shape: new CircleBorder(),
          fillColor: Color.fromRGBO(231, 231, 231, 1),
          padding: const EdgeInsets.all(10.0),
        ),
      ),
      title: Text(
        circuit.circuit + ' route circuit',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

      subtitle: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
                padding: EdgeInsets.only(left: 0.0),
                child: Text(Utils.convertToHours(Utils.getTripMinutes(circuit.startTime, circuit.endTime)) + ' h',
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)))),
          ),
          Expanded(
            flex: 0,
            child: Padding(
                padding: EdgeInsets.only(left: 0.0),
                child: Text(Utils.convertAMPMTime(circuit.startTime) + ' - ' + Utils.convertAMPMTime(circuit.endTime),
                    style: TextStyle(color: Color.fromRGBO(63, 110, 147, 1), ))),
          ),
        ],
      ),
    );

    Card makeCard(Circuit circuit) => Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0),),
        child: makeListTile(circuit),
      ),
    );

    final makeHistory = Container(
      // decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.travel.circuitArray.length,
        itemBuilder: (BuildContext context, int index) {
          return makeCard(widget.travel.circuitArray[index]);
        },
        physics: const NeverScrollableScrollPhysics(),
      ),
    );

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState /*You can rename this!*/)
              {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      new GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0, top: 30.0),
                          child: new Icon(Icons.close, size: 24,
                            color: Color.fromRGBO(155, 155, 155, 1),),
                        ),
                      ),
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 20.0,),
                            child: new Text('Route circuits',
                              style: TextStyle(color: Colors.black, fontSize: 16),),
                          ),
                        ],
                      ),
                      Divider(),
                      makeHistory,
                    ],
                  ),
                );
              });
        }
    );

  }
}
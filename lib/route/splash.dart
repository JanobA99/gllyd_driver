import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gllyd_driver/model/busstop.dart';
import 'package:gllyd_driver/route/display.dart';

class DaySplashPage extends StatefulWidget {

  DaySplashPage({Key key, this.busStops, this.trafficEnabled}) : super(key: key);
  final List<BusStop> busStops;
  final bool trafficEnabled;

  @override
  _DaySplashPageState createState() => _DaySplashPageState();

}

class _DaySplashPageState extends State<DaySplashPage> {

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    //Navigator.of(context).pushReplacementNamed('/RouteDisplayPage');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RouteDisplayPage(busStops: widget.busStops, trafficEnabled: widget.trafficEnabled)));
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    final double statusHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      //appBar: AppBar(
      //  backgroundColor: Colors.white,
      //),
      body: Container(
        margin: new EdgeInsets.only(top:statusHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Container (
              padding: new EdgeInsets.only(left: 25.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text('Have a\ngood day!', style: TextStyle(color: Colors.black, fontSize: 60),),
                ],
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.cover, // otherwise the logo will be tiny
                child: new Image(image: new AssetImage("assets/images/good_day.png"),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
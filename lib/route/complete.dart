import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DayCompletePage extends StatefulWidget {

  @override
  _DayCompletePageState createState() => _DayCompletePageState();

}

class _DayCompletePageState extends State<DayCompletePage> {

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
                  new Text('Goodbye!', style: TextStyle(color: Colors.black, fontSize: 60),),
                ],
              ),
            ),
            new Container (
              padding: new EdgeInsets.only(left: 25.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text('Thank you for the good job', style: TextStyle(color: Colors.black, fontSize: 20),),
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
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0, right: 10.0,),
        child:FloatingActionButton(
          child: const Icon(Icons.expand_more),
          onPressed: () {
            _settingModalBottomSheet(context);
          },
          foregroundColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

void _settingModalBottomSheet(context){
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc){
        return Container(
          padding: const EdgeInsets.only(left:25.0, top:27.0, right:25.0, bottom:25.0),
          height: 160,
          child: Row (
            children: <Widget>[
              Expanded(
                child: new Container (
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                    color: Color.fromRGBO(63, 110, 147, 1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      launch("tel://+234 666 348625");
                    },
                    padding: EdgeInsets.all(20.0),
                    child: Column( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Icon(Icons.call, color: Colors.white,),
                        Text('Call a fleet\nmanager', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: new Container (
                  margin: const EdgeInsets.only(left: 12.0),
                  decoration: new BoxDecoration(
                    color: Color.fromRGBO(63, 110, 147, 1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      launch("sms://+234 666 348625");
                    },
                    padding: EdgeInsets.all(20.0),
                    child: Column( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Icon(Icons.chat, color: Colors.white,),
                        Text('Message a\nfleet manager', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
  );
}
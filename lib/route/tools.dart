import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:gllyd_driver/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ToolsPage extends StatefulWidget {

  @override
  _ToolsPageState createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {

  bool _trafficFlag = true;
  bool _soundFlag = true;

  @override
  void initState() {
    super.initState();
    getPreferences();
  }

  getPreferences() async {
    SharedPreferencesHelper.getTrafficCode().then((value) {
      setState(() {
        _trafficFlag = value;
      });
    });
    SharedPreferencesHelper.getSoundCode().then((value) {
      setState(() {
        _soundFlag = value;
      });
    });
  }

  setTrafficFlag() async {
    SharedPreferencesHelper.setTrafficCode(_trafficFlag);
  }

  setSoundFlag() async {
    SharedPreferencesHelper.setSoundCode(_soundFlag);
  }

  @override
  Widget build (BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          title: new Text("Driver tools", style: TextStyle(color: Colors.black,),),
          iconTheme: new IconThemeData(color: Colors.grey),
        ),
        body: Container (
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:16.0, top: 22.0),
                child: new Text('Tool', style: TextStyle(color: Colors.black, fontSize: 16),),
              ),
              Expanded(
                child: new GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  children: <Widget>[
                    Container(
                      child:new Column(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              setState(() {
                                _trafficFlag = !_trafficFlag;
                              });
                              setTrafficFlag();
                              //showPanicDialog(context);
                            },
                            child: new Icon(
                              Icons.traffic,
                              color: _trafficFlag ?  Colors.white : Colors.grey,
                              size: 32.0,
                            ),
                            shape: new CircleBorder(),
                            fillColor: _trafficFlag ?  Color.fromRGBO(245, 166, 35, 1) : Colors.white,
                            padding: const EdgeInsets.all(16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0),
                            child: new Text('Traffic', style: TextStyle(color: Colors.grey, fontSize: 12),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child:new Column(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              setState(() {
                                _soundFlag = !_soundFlag;
                              });
                              setSoundFlag();
                            },
                            child: new Icon(
                              _soundFlag ? Icons.volume_up : Icons.volume_off,
                              color: _soundFlag ?  Colors.white : Colors.grey,
                              size: 32.0,
                            ),
                            shape: new CircleBorder(),
                            fillColor: _soundFlag ?  Color.fromRGBO(245, 166, 35, 1) : Colors.white,
                            padding: const EdgeInsets.all(16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0),
                            child: new Text('Sound', style: TextStyle(color: Colors.grey, fontSize: 12),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child:new Column(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              launch("tel://+234 666 348625");
                            },
                            child: new Icon(
                              Icons.call,
                              color: Color.fromRGBO(63, 110, 147, 1),
                              size: 32.0,
                            ),
                            shape: new CircleBorder(),
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0),
                            child: new Text('Call manager', style: TextStyle(color: Colors.grey, fontSize: 12),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child:new Column(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/HistoryListPage');
                            },
                            child: new Icon(
                              Icons.content_paste,
                              color: Color.fromRGBO(63, 110, 147, 1),
                              size: 32.0,
                            ),
                            shape: new CircleBorder(),
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0),
                            child: new Text('Travel history', style: TextStyle(color: Colors.grey, fontSize: 12),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child:new Column(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              //Location origin = new Location(name: 'Nyanya', latitude: 9.022253, longitude: 7.570782);
                              //Location destination = new Location(name: 'Wuse Marke', latitude: 9.0522533, longitude: 7.4752204);
                              //bool simulateRoute = true;
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationView(origin: origin, destination: destination, simulateRoute:simulateRoute)));
                            },
                            child: new Icon(
                              Icons.settings_overscan,
                              color: Color.fromRGBO(63, 110, 147, 1),
                              size: 32.0,
                            ),
                            shape: new CircleBorder(),
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0),
                            child: new Text('QR-scanner', style: TextStyle(color: Colors.grey, fontSize: 12),),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(left:16.0, right: 16.0),
                child: new Container(
                  height: 40,
                  child: new GestureDetector(
                    onTap: () {
                      showCompleteDialog(context);
                    },
                    child: new Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text('Complete day', style: TextStyle(color: Colors.grey, fontSize: 17), )),
                        ),
                        Expanded(
                          flex: 0,
                          child: Padding(
                              padding: EdgeInsets.only(right: 0.0),
                              child: Icon(Icons.check, size: 24, color: Color.fromRGBO(30, 197, 25, 1), )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: new Container(
            height: 48,
            child: new GestureDetector(
              onTap: () {
                showLogoutDialog(context);
              },
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: EdgeInsets.only(left: 26.0),
                        child: Text('Log out', style: TextStyle(color: Colors.grey, fontSize: 17), )),
                  ),
                  Expanded(
                    flex: 0,
                    child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.exit_to_app, size: 24, color: Color.fromRGBO(63, 110, 147, 1), )),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

enum ConfirmAction { YES, NO }
Future<void> showCompleteDialog(BuildContext context) {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        content: const Text('Complete day?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20,),),
        actions: <Widget>[
          FlatButton(
            child: const Text('Yes'),
            onPressed: () {
              SharedPreferencesHelper.setTodayCircuit(0);
              //Navigator.of(context).pop(ConfirmAction.YES);
              //Navigator.pushReplacementNamed(context, '/DayCompletePage');
              Navigator.of(context).pushNamedAndRemoveUntil('/DayCompletePage', (Route<dynamic> route) => false);
            },
          ),
          FlatButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.NO);
            },
          )
        ],
      );
    },
  );
}

Future<void> showLogoutDialog(BuildContext context) {

  logout() async {
    SharedPreferencesHelper.setLoginCode(false).then((value) {
      SharedPreferencesHelper.setEmailCode("").then((value) {
        SharedPreferencesHelper.setPasswordCode("").then((value) {
          SharedPreferencesHelper.setUsernameCode("").then((value) {
            SharedPreferencesHelper.setUserIdCode("").then((value) {
              //exit(0);
              SystemNavigator.pop();
            });
          });
        });
      });
    });
  }

  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        content: const Text('Log out?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20,),),
        actions: <Widget>[
          FlatButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.YES);
              logout();
            },
          ),
          FlatButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.NO);
            },
          )
        ],
      );
    },
  );
}

Future<void> showPanicDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0)),
        ),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:30.0),
                  child: new Icon(Icons.warning, size: 48, color: Color.fromRGBO(245, 166, 35, 1), ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:20.0, bottom: 20.0),
                  child: new Text("Panic Button Activated", style: TextStyle(color: Colors.black, fontSize: 20,), textAlign: TextAlign.center,),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: new Text("Help is on the way", style: TextStyle(color: Colors.black, fontSize: 16,), textAlign: TextAlign.center,),
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(245, 166, 35, 1),
                    ),
                    child: Text(
                      "Deactivate",
                      style: TextStyle(color: Colors.white, fontSize: 16,),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
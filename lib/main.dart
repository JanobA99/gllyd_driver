import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_preferences.dart';
import 'route/morning.dart';
import 'route/splash.dart';
import 'route/display.dart';
import 'route/tools.dart';
import 'route/complete.dart';
import 'history/list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OverlaySupport(child:MaterialApp(
      title: 'Gllyd Coach Driver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: SignInPage(title: 'Gllyd Coach'),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/' : (context) => SliderPage(title: 'Gllyd Coach'), //SignInPage(title: 'Gllyd Coach'),
        //'/MorningPage' : (BuildContext context) => new MorningPage(),
        '/DaySplashPage' : (BuildContext context) => new DaySplashPage(),
        '/RouteDisplayPage': (BuildContext context) => new RouteDisplayPage(),
        '/ToolsPage': (BuildContext context) => new ToolsPage(),
        '/DayCompletePage': (BuildContext context) => new DayCompletePage(),
        '/HistoryListPage': (BuildContext context) => new HistoryListPage(),
      },
    ),);
  }
}

class SliderPage extends StatefulWidget {
  SliderPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {

  startTime() async {
    SharedPreferencesHelper.getSliderCode().then((value) {
      if (value == true) {
        var _duration = new Duration(seconds: 0);
        return new Timer(_duration, navigationPage);
      } else {
        //var _duration = new Duration(seconds: 12);
        //return new Timer(_duration, navigationPage);
        return null;
      }
    });
  }

  void navigationPage() async {
    await SharedPreferencesHelper.setSliderCode();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage(title: 'Gllyd Coach')));
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
      body: new Stack(
        children: [
          Container(
              margin: new EdgeInsets.only(top:statusHeight),
              child: Carousel(
                images: [
                  ExactAssetImage("assets/images/instruction1.png"),
                  ExactAssetImage("assets/images/instruction2.png"),
                  ExactAssetImage("assets/images/instruction3.png"),
                  ExactAssetImage("assets/images/instruction4.png"),
                ],
                dotSize: 4.0,
                dotSpacing: 15.0,
                dotColor: Colors.lightGreenAccent,
                indicatorBgPadding: 5.0,
                dotBgColor: Colors.grey.withOpacity(0.1),
                borderRadius: true,
                //autoplayDuration: Duration(seconds: 3),
                autoplay: false,
              )
          ),
          Container(
            margin: new EdgeInsets.only(top:statusHeight - 6),
            //color: Color.fromRGBO(50, 88, 117, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FlatButton.icon(
                  color: Color.fromRGBO(245, 166, 35, 1),
                  onPressed: () {
                    navigationPage();
                  },
                  label: Text('Skip', style: TextStyle(color: Colors.white, fontSize: 20),),
                  icon: Icon(Icons.arrow_forward, size: 24, color: Colors.white, ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final databaseReference = Firestore.instance;

  TextEditingController _txtEmail = TextEditingController();
  TextEditingController _txtPassword = TextEditingController();
  String username = "";
  String userId = "";
  bool _validateError = false;
  bool _obscureOpt = true;

  @override
  void initState() {
    super.initState();
    getCredential();
  }

  getCredential() async {
    SharedPreferencesHelper.getLoginCode().then((value) {
      if (value) {
        SharedPreferencesHelper.getEmailCode().then((value) {
          _txtEmail.text = value;
        });
        SharedPreferencesHelper.getPasswordCode().then((value) {
          _txtPassword.text = value;
        });
      }
    });
  }

  void checkUser() async {
    /*databaseReference.collection("drivers").getDocuments().then(
      (QuerySnapshot snapshot) {
        snapshot.documents.forEach((f) => print('${f.data}}'));
      }
    );*/

    Firestore.instance.collection('drivers')
        .where('email', isEqualTo: _txtEmail.text)
        .where('password', isEqualTo: _txtPassword.text)
        .snapshots().listen(
            (data) {
              if (data.documents.length == 1) {
                username = data.documents[0]['name'];
                userId = data.documents[0].documentID;
                saveCredential();
              } else
                setState(() {
                  _validateError = true;
                });
            }
        );
  }

  saveCredential() async {
    SharedPreferencesHelper.setLoginCode(true);
    SharedPreferencesHelper.setUsernameCode(username);
    SharedPreferencesHelper.setUserIdCode(userId);
    SharedPreferencesHelper.setEmailCode(_txtEmail.text);
    SharedPreferencesHelper.setPasswordCode(_txtPassword.text);
    //Navigator.pushReplacementNamed(context, '/MorningPage');
    /*Firestore.instance.collection('schedules').where('driver_id', isEqualTo: userId).snapshots().listen((data) {
      String routeId = data.documents[0]['route_id'];
      SharedPreferencesHelper.setRouteIdCode(routeId);
      Firestore.instance.collection('routes').document(routeId).snapshots().listen((data) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MorningPage(startLat: double.parse(data['start_lat']),
                startLng: double.parse(data['start_lng']),
                endLat: double.parse(data['end_lat']),
                endLng: double.parse(data['end_lng']))));
      });
    });*/
    Firestore.instance.collection('schedules').where('driver_id', isEqualTo: userId).getDocuments().then((QuerySnapshot snapshot) {
      String routeId = snapshot.documents[0]['route_id'];
      SharedPreferencesHelper.setRouteIdCode(routeId);
      Firestore.instance.collection('routes').document(routeId).get().then((DocumentSnapshot snapshot) {
        double startLat = double.parse(snapshot['start_lat']);
        double startLng = double.parse(snapshot['start_lng']);
        double endLat = double.parse(snapshot['end_lat']);
        double endLng = double.parse(snapshot['end_lng']);

        if (this.mounted){
          showNextPage(startLat, startLng, endLat, endLng);
        }
      });
    });
  }

  void showNextPage(double startLat, double startLng, double endLat, double endLng) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MorningPage(startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title, style: TextStyle(color: Colors.black)),
      ),
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(image: new AssetImage("assets/images/signin_bg.png"), fit: BoxFit.cover,),
            ),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                visible: _validateError,
                child: new Container (
                  color: Color.fromRGBO(245, 166, 35, 1),
                  height: 48.0,
                  child: new Center(
                    child: new Text('Incorrect credential, enter correct credential', style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                ),
              ),
              new Expanded(
                child: new Container (
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Container (
                        margin: new EdgeInsets.only(left: 16, top:35, right: 16),
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left:16.0, top:24.0),
                              child: new Text('Email', style: TextStyle(fontSize: 14),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left:16.0, top:10.0, bottom: 16.0),
                              child: new TextField(
                                controller: _txtEmail,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'example@gmail.com',
                                    hintStyle: TextStyle(color: _validateError ? Color.fromRGBO(245, 166, 35, 1) : Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Container (
                        margin: new EdgeInsets.only(left: 16, top:35, right: 16),
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left:16.0, top:24.0),
                              child: new Text('Password', style: TextStyle(fontSize: 14),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left:16.0, top:10.0, bottom: 16.0),
                              child: new TextField(
                                controller: _txtPassword,
                                obscureText: _obscureOpt,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter',
                                  hintStyle: TextStyle(color: _validateError ? Color.fromRGBO(245, 166, 35, 1) : Colors.grey),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureOpt ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () {
                                      _obscureOpt = !_obscureOpt;
                                    },
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
              ),
              new GestureDetector(
                onTap: () {
                  toast("Request password from Admin");
                },
                child: new Container (
                  padding: new EdgeInsets.only(left: 16.0),
                  height: 48.0,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Text('Forgot password?', style: TextStyle(color: Colors.white, fontSize: 14),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(63, 110, 147, 1),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1, // 60% of space => (6/(6 + 4))
              child: FlatButton(
                child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 17),),
                highlightColor: Color.fromRGBO(63, 110, 147, 1),
                onPressed: () {
                  setState(() {
                    _txtEmail.text.isEmpty || _txtPassword.text.isEmpty ? _validateError = true : _validateError = false;
                    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regex = new RegExp(pattern);
                    if (!regex.hasMatch(_txtEmail.text))
                      _validateError = true;
                  });

                  if (_validateError == false) {
                    //saveCredential();
                    checkUser();
                  }
                },
              ),
            ),
            /*FlatButton(
              child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 17),),
              highlightColor: Color.fromRGBO(63, 110, 147, 1),
              onPressed: () {
                Navigator.pushNamed(context, '/MorningPage');
              },
            ),*/
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gllyd_driver/model/circuit.dart';
import 'package:gllyd_driver/model/travel.dart';
import 'package:gllyd_driver/history/detail_page.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gllyd_driver/shared_preferences.dart';
import 'package:gllyd_driver/utils.dart';
import 'package:month_picker_strip/month_picker_strip.dart';

class HistoryListPage extends StatefulWidget {

  @override
  _HistoryListPageSate createState() => _HistoryListPageSate();
}

class _HistoryListPageSate extends State<HistoryListPage> {

  List travels = new List();
  DateTime selectedMonth;
  bool showSearchBar = false;
  TextEditingController _txtSearch = TextEditingController();

  String yearOfToday;
  String monthOfToday;

  @override
  void initState() {
    //travels = getHistory();
    yearOfToday = DateFormat('y').format(new DateTime.now());
    monthOfToday = DateFormat('M').format(new DateTime.now());
    selectedMonth = new DateTime(int.parse(yearOfToday), int.parse(monthOfToday));
    getHistory();
    super.initState();
  }

  void showDetailPage(travel) async {
    //travel.bearing = await Geolocator().bearingBetween(travel.startLat, travel.startLng, travel.endLat, travel.endLng);
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(travel: travel)));
  }

  @override
  Widget build (BuildContext context) {

    ListTile makeListTile(Travel travel) => ListTile(
      contentPadding:
      EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      leading: Container(
        //decoration: new BoxDecoration(border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))),
        child: RawMaterialButton(
          onPressed: () {},
          child: new Icon(
            Icons.directions_bus,
            color: Colors.black,
          ),
          shape: new CircleBorder(),
          fillColor: Color.fromRGBO(231, 231, 231, 1),
          padding: const EdgeInsets.all(10.0),
        ),
      ),
      title: RichText(
        text: new TextSpan(
          children: <TextSpan>[
            new TextSpan(text: travel.startPos, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            new TextSpan(text: ' to ', style: TextStyle(color: Colors.grey,),),
            new TextSpan(text: travel.endPos, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

      subtitle: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Padding(
                padding: EdgeInsets.only(left: 0.0),
                child: Text(travel.trip,
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)))),
          ),
          Expanded(
              flex: 1,
            child: Padding(
                padding: EdgeInsets.only(left: 0.0),
                child: Text(travel.date,
                    style: TextStyle(color: Color.fromRGBO(63, 110, 147, 1), ))),
          ),
          /*Expanded(
              flex: 1,
              child: Container(
                // tag: 'hero',
                child: LinearProgressIndicator(
                    backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
                    value: travel.indicatorValue,
                    valueColor: AlwaysStoppedAnimation(Colors.green)),
              )),*/
        ],
      ),
      trailing:
      Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 30.0),
        onTap: () {
          showDetailPage(travel);
        },
    );

    Card makeCard(Travel travel) => Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: makeListTile(travel),
      ),
    );

    final makeBody = Container(
      // decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:20.0, top:10.0, bottom: 6.0, ),
            child: new Text(DateFormat('MMMM, y').format(selectedMonth), style: TextStyle(color: Colors.grey, fontSize: 14.0, ),),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: travels.length,
            itemBuilder: (BuildContext context, int index) {
              return makeCard(travels[index]);
            },
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );

    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          iconTheme: new IconThemeData(color: Colors.grey),
          centerTitle: true,
          title: showSearchBar ? new TextField(
            controller: _txtSearch,
            decoration: new InputDecoration(),
            onChanged: (text) {
              getHistory();
            },
          ) : new Container(),
          actions: <Widget>[
            showSearchBar == false ?
            new IconButton(icon: new Icon(Icons.search, color: Colors.grey,), onPressed: () {
              _txtSearch.text = '';
              setState(() {
                showSearchBar = true;
              });
            },) :
            new IconButton(icon: new Icon(Icons.close, color: Colors.grey,), onPressed: () {
              setState(() {
                showSearchBar = false;
              });
              getHistory();
            },),
          ]
        ),
        body: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new MonthStrip(
                format: 'MMM yyyy',
                from: new DateTime(2019, 12),
                to: new DateTime(2039, 12),
                initialMonth: selectedMonth,
                height: 48.0,
                viewportFraction: 0.25,
                onMonthChanged: (v) {
                  setState(() {
                    selectedMonth = v;
                    yearOfToday = DateFormat('y').format(selectedMonth);
                    monthOfToday = DateFormat('M').format(selectedMonth);
                    getHistory();
                  });
                },
              ),
              makeBody,
            ],
          ),
        ),

    );
  }

  void getHistory() {
    travels.clear();
    SharedPreferencesHelper.getUserIdCode().then((value) {
      String driverId = value;
      Firestore.instance.collection('bus_history')
          .where('driver_id', isEqualTo: driverId)
          .where('year', isEqualTo: yearOfToday)
          .where('month', isEqualTo: monthOfToday)
          .orderBy('day', descending: true)
          .orderBy('circuit')
          .snapshots().listen(
              (data) {
              for (int i = 0; i < data.documents.length; i++) {
                int circuit = data.documents[i]['circuit'];
                String year = data.documents[i]['year'];
                String day = data.documents[i]['day'];
                String startTime = data.documents[i]['start_time'];
                String endTime = data.documents[i]['end_time'];
                String route = data.documents[i]['route_id'];
                double distance = data.documents[i]['distance'];
                //print("startTime:" + startTime);
                //print("endTime:" + endTime);

                bool bFind = false;
                for (int j = 0; j < travels.length; j ++) {
                  Travel temp = travels[j];
                  if (temp.day == day) {
                    bFind = true;
                    temp.minutes += Utils.getTripMinutes(startTime, endTime);
                    //temp.circuit += 1;
                    temp.distance += distance;
                    temp.circuitArray.add(Circuit(circuit: circuit.toString(), startTime: startTime, endTime: endTime));
                  }
                }

                if (bFind == false) {
                  Travel item = Travel(circuit:1, route:route, date:Utils.convertDate(monthOfToday, day), day: day,
                    minutes: Utils.getTripMinutes(startTime, endTime), fullDate: Utils.getFullDate(year, monthOfToday, day),
                    distance: distance,
                  );
                  item.circuitArray.add(Circuit(circuit: circuit.toString(), startTime: startTime, endTime: endTime));
                  travels.add(item);
                }
              }

              for (int i = 0 ; i < travels.length; i++) {
                Travel travel = travels[i];
                travel.trip = 'Trip lasted ' + Utils.convertToHours(travel.minutes) + ' h';
                Firestore.instance.collection('routes')
                    .document(travel.route)
                    .snapshots().listen((data) {
                      setState(() {
                        travel.startPos = data['start_pos'];
                        travel.endPos = data['end_pos'];
                        travel.startLat = double.parse(data['start_lat']);
                        travel.startLng = double.parse(data['start_lng']);
                        travel.endLat = double.parse(data['end_lat']);
                        travel.endLng = double.parse(data['end_lng']);

                        if (i == (travels.length - 1) && showSearchBar && _txtSearch.text != '')
                          checkSearchKey();
                      });
                });
              }

              /*setState(() {
                for (int i = 0 ; i < travels.length; i++) {
                  Travel travel = travels[i];
                  travel.trip = 'Trip lasted ' + Utils.convertToHours(travel.minutes) + ' h';
                }
              });*/
          }
      );
    });
  }

  void checkSearchKey() {
    for (int i = travels.length - 1 ; i >= 0 ; i--) {
      Travel travel = travels[i];
      if (travel.startPos.toLowerCase().contains(_txtSearch.text.toLowerCase()) == false && travel.endPos.toLowerCase().contains(_txtSearch.text.toLowerCase()) == false) {
        setState(() {
          travels.removeAt(i);
        });
      }
    }
  }
}

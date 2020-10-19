import 'package:gllyd_driver/model/circuit.dart';

class Travel {
  String route;
  String trip;
  String date;
  String day;
  int minutes;
  int circuit;
  String startPos;
  String endPos;
  String  fullDate;
  double distance;
  double startLat;
  double startLng;
  double endLat;
  double endLng;
  double bearing;
  List<Circuit> circuitArray = new List();

  Travel(
      {this.route, this.trip, this.date, this.day,
        this.minutes, this.startPos, this.endPos,
        this.fullDate, this.circuit, this.distance,
        this.startLat, this.startLng, this.endLat, this.endLng, this.bearing,
      });
}
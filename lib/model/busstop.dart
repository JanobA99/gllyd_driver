
class BusStop {

  String routeId;
  String stopId;
  double lat;
  double lng;
  String label;
  bool isStart;
  bool isReturn;

  BusStop(
      {this.routeId, this.stopId, this.lat, this.lng, this.label, this.isStart, this.isReturn});
}
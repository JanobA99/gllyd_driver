import 'package:google_maps_flutter/google_maps_flutter.dart';

class Steps {
  LatLng startLocation;
  LatLng endLocation;

  Steps({this.startLocation, this.endLocation});

  factory Steps.fromJson(Map<String, dynamic> json) {
    return new Steps(
        startLocation: new LatLng(json["start_location"]["lat"], json["start_location"]["lng"]),
        endLocation: new LatLng(json["end_location"]["lat"], json["end_location"]["lng"]));
  }

}
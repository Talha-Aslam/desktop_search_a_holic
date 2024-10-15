// This contain functions for api calls

// import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ApiCall {
  Future<Position> getCurrentLocation() async {
    var status = await Permission.location.status;

    PermissionStatus permission = await Permission.location.request();
    if (permission != PermissionStatus.granted) {
      print("Permission not granted");
      throw Exception('Location permission not granted');
    }
    Position position = '' as Position;
    return position;
  }
}

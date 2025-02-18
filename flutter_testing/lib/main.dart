import 'dart:async';
import 'GeoDataClass.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
  return await Geolocator.getCurrentPosition();
}

double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
  // Convert degrees to radians
  double phi1 = lat1 * pi / 180;
  double phi2 = lat2 * pi / 180;
  double deltaLambda = (lon2 - lon1) * pi / 180;

  // Compute the bearing
  double y = sin(deltaLambda) * cos(phi2);
  double x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);

  double bearing = atan2(y, x);

  // Convert bearing from radians to degrees
  bearing = bearing * 180 / pi;

  // Normalize the bearing to be between 0 and 360 degrees
  if (bearing < 0) {
    bearing += 360;
  }

  return bearing;
}



Future<GeoData> _determineDistance(GeoData locationToCompare) async {
    Position userPos = await _determinePosition();
    locationToCompare.distance = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, locationToCompare.latitude, locationToCompare.longitude);
    locationToCompare.bearing = calculateBearing(userPos.latitude, userPos.longitude,locationToCompare.latitude, locationToCompare.longitude);
    return locationToCompare;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _location = "";
  String _distance = "";
  double? _bearing;
  Future<void> _getLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _location =
            "Lat: ${position.latitude}, Long: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _location = "Error: $e";
      });
    }
  }
  Future<void> _getDistance() async {
    try {
      GeoData testLocation = GeoData(name: "Paris", latitude: 48.8575, longitude: 2.3514);
      GeoData distanceVal = await _determineDistance(testLocation);
      setState(() {
        _distance =
            "${distanceVal.distance} meters to ${distanceVal.name}";
        _bearing = distanceVal.bearing;
      });
    } catch (e) {
      setState(() {
        _distance = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Current Position is: ',
            ),
            Text(
              _location,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              _distance,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_bearing != null) Text(
              "$_bearing",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_bearing != null) 
              Transform.rotate(
                angle: (_bearing! * pi / 180), //need bearings in rads
                child: Image.asset('lib/assets/stock_arrow.jpg',width: 100,height: 100,),
              )          
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
        onPressed: _getLocation,
        tooltip: 'Access Location',
        child: const Icon(Icons.add),
      ),
      FloatingActionButton(
        onPressed: _getDistance,
        tooltip: 'Calculate Distance',
        child: const Icon(Icons.add_home),
      ) // This trailing comma makes auto-formatting nicer for build methods.
  ]));
  }
}

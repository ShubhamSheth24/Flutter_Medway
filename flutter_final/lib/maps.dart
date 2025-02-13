import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

const String googleApiKey =
    "YOUR_GOOGLE_MAPS_API_KEY"; // Replace with your API Key

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  late GoogleMapController _mapController;
  LatLng myCurrentLocation = const LatLng(19.0760, 72.8777); // Default Mumbai
  LatLng hospitalLocation = const LatLng(19.0990, 72.8740); // Example hospital
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isLocationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      setState(() {
        isLocationPermissionGranted = true;
      });
      _getUserLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Location permission is required to access your location.'),
        ),
      );
    }
  }

  // Get user's live location
  Future<void> _getUserLocation() async {
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Updates when the user moves 5 meters
      );

      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        setState(() {
          myCurrentLocation = LatLng(position.latitude, position.longitude);
          _updateMarkers();
          _fetchRoute(); // Get road-based polyline whenever location updates
        });
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // Fetch road-based route from hospital to user
  Future<void> _fetchRoute() async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${hospitalLocation.latitude},${hospitalLocation.longitude}&destination=${myCurrentLocation.latitude},${myCurrentLocation.longitude}&key=$googleApiKey&mode=driving";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["routes"].isNotEmpty) {
        String encodedPolyline =
            data["routes"][0]["overview_polyline"]["points"];
        List<LatLng> polylineCoords = _decodePolyline(encodedPolyline);

        setState(() {
          polylines.clear(); // Clear old routes before adding a new one
          polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.blue,
              width: 6,
              points: polylineCoords,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
              jointType: JointType.round,
            ),
          );
        });
      } else {
        print("No route found");
      }
    } else {
      print("Error fetching route: ${response.body}");
    }
  }

  // Decode polyline points from Google API
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  // Update markers (User & Hospital)
  void _updateMarkers() {
    markers.clear();

    markers.add(
      Marker(
        markerId: const MarkerId("CurrentLocation"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: myCurrentLocation,
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId("Hospital"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: hospitalLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: myCurrentLocation,
          zoom: 15,
        ),
        markers: markers,
        polylines: polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _fetchRoute(); // Load route once the map is ready
        },
      ),
    );
  }
}

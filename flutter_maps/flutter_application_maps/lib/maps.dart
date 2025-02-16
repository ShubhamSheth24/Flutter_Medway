import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  LatLng myCurrentLocation = const LatLng(19.0760, 72.8777); // Default location
  bool isLocationPermissionGranted = false;
  Set<Marker> markers = {}; // Set to hold markers

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
      // Handle denied permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permission is required to access your current location.'),
        ),
      );
    }
  }

  // Get user's current location and track live updates
  Future<void> _getUserLocation() async {
    try {
      // Request location updates
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy
            .high, // Use `accuracy` instead of `desiredAccuracy`
        distanceFilter: 10, // Update location every 10 meters
      );

      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        setState(() {
          // Update the current location
          myCurrentLocation = LatLng(position.latitude, position.longitude);

          // Update the marker
          markers.clear(); // Clear previous markers
          markers.add(
            Marker(
              markerId: const MarkerId("CurrentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: myCurrentLocation,
            ),
          );
        });
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: myCurrentLocation,
          zoom: 15,
        ),
        markers: markers, // Add markers to the map
        myLocationEnabled: true, // Enable showing the user's current location
        myLocationButtonEnabled: true, // Enable the "my location" button
        onMapCreated: (GoogleMapController controller) {
          // Optionally, you can use the controller to interact with the map
        },
      ),
    );
  }
}



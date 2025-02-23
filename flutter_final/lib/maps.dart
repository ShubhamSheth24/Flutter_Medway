import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

const String googleApiKey = "AIzaSyDhXcWeIuh9yG1aQ2AKvYCDGN6bVJL1RJk"; // Replace with your API Key

class AmbulanceBookingScreen extends StatefulWidget {
  const AmbulanceBookingScreen({super.key});

  @override
  State<AmbulanceBookingScreen> createState() => _AmbulanceBookingScreenState();
}

class _AmbulanceBookingScreenState extends State<AmbulanceBookingScreen> {
  late GoogleMapController _mapController;
  LatLng currentLocation = const LatLng(19.0760, 72.8777); // Default: Mumbai
  String address = "Fetching address...";

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      _getUserLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required!')),
      );
    }
  }

  // Get user location
  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
      _fetchAddress(position.latitude, position.longitude);
    });
  }

  // Fetch address from coordinates
  Future<void> _fetchAddress(double lat, double lng) async {
    final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["results"].isNotEmpty) {
        setState(() {
          address = data["results"][0]["formatted_address"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(target: currentLocation, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                position: currentLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            },
            circles: {
              Circle(
                circleId: const CircleId("accuracyCircle"),
                center: currentLocation,
                radius: 100, // Adjust as needed
                fillColor: Colors.blue.withOpacity(0.2),
                strokeWidth: 1,
                strokeColor: Colors.blue,
              ),
            },
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search location, ZIP code...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.black54),
                ),
                onSubmitted: (value) {
                  // Handle search logic if needed
                },
              ),
            ),
          ),

          // Address Confirmation Card
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Confirm your address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      // Handle booking confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ambulance booked successfully!')),
                      );
                    },
                    child: const Text("Confirm Location", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:google_maps_webservice/places.dart';

// const String googleApiKey = "AIzaSyDhXcWeIuh9yG1aQ2AKvYCDGN6bVJL1RJk"; // Replace with your API Key
// final places = GoogleMapsPlaces(apiKey: googleApiKey);

// class AmbulanceBookingScreen extends StatefulWidget {
//   const AmbulanceBookingScreen({super.key});

//   @override
//   State<AmbulanceBookingScreen> createState() => _AmbulanceBookingScreenState();
// }

// class _AmbulanceBookingScreenState extends State<AmbulanceBookingScreen> {
//   late GoogleMapController _mapController;
//   LatLng currentLocation = const LatLng(19.0760, 72.8777); // Default: Mumbai
//   String address = "Fetching address...";

//   @override
//   void initState() {
//     super.initState();
//     _requestLocationPermission();
//   }

//   // Request location permission
//   Future<void> _requestLocationPermission() async {
//     final status = await Permission.location.request();
//     if (status == PermissionStatus.granted) {
//       _getUserLocation();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Location permission is required!')),
//       );
//     }
//   }

//   // Get user location
//   Future<void> _getUserLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       currentLocation = LatLng(position.latitude, position.longitude);
//       _mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
//       _fetchAddress(position.latitude, position.longitude);
//     });
//   }

//   // Fetch address from coordinates
//   Future<void> _fetchAddress(double lat, double lng) async {
//     final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data["results"].isNotEmpty) {
//         setState(() {
//           address = data["results"][0]["formatted_address"];
//         });
//       }
//     }
//   }

//   // Search for a location
//   Future<void> _searchLocation() async {
//     Prediction? p = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: googleApiKey,
//       mode: Mode.overlay,
//     );
//     if (p != null) {
//       PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
//       LatLng newLocation = LatLng(
//         detail.result.geometry!.location.lat,
//         detail.result.geometry!.location.lng,
//       );
//       setState(() {
//         currentLocation = newLocation;
//         address = detail.result.formattedAddress!;
//         _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Google Map
//           GoogleMap(
//             initialCameraPosition: CameraPosition(target: currentLocation, zoom: 15),
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             onMapCreated: (controller) {
//               _mapController = controller;
//             },
//             markers: {
//               Marker(
//                 markerId: const MarkerId("currentLocation"),
//                 position: currentLocation,
//                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//               ),
//             },
//             circles: {
//               Circle(
//                 circleId: const CircleId("accuracyCircle"),
//                 center: currentLocation,
//                 radius: 100, // Adjust as needed
//                 fillColor: Colors.blue.withOpacity(0.2),
//                 strokeWidth: 1,
//                 strokeColor: Colors.blue,
//               ),
//             },
//           ),

//           // Search Bar
//           Positioned(
//             top: 50,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
//               ),
//               child: TextField(
//                 decoration: const InputDecoration(
//                   hintText: "Search location, ZIP code...",
//                   border: InputBorder.none,
//                   icon: Icon(Icons.search, color: Colors.black54),
//                 ),
//                 onTap: _searchLocation, // Trigger search on tap
//               ),
//             ),
//           ),

//           // Address Confirmation Card
//           Positioned(
//             bottom: 30,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Confirm your address",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, color: Colors.red),
//                       const SizedBox(width: 5),
//                       Expanded(
//                         child: Text(
//                           address,
//                           style: const TextStyle(fontSize: 14),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       minimumSize: const Size(double.infinity, 45),
//                     ),
//                     onPressed: () {
//                       // Handle booking confirmation
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Ambulance booked successfully!')),
//                       );
//                     },
//                     child: const Text("Confirm Location", style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

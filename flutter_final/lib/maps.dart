// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;

// const String googleApiKey = "AIzaSyDhXcWeIuh9yG1aQ2AKvYCDGN6bVJL1RJk"; // Replace with your API Key

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
//                 onSubmitted: (value) {
//                   // Handle search logic if needed
//                 },
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

const String googleApiKey =
    "AIzaSyDhXcWeIuh9yG1aQ2AKvYCDGN6bVJL1RJk"; // Replace with your Google API Key

class AmbulanceBookingScreen extends StatefulWidget {
  const AmbulanceBookingScreen({super.key});

  @override
  State<AmbulanceBookingScreen> createState() => _AmbulanceBookingScreenState();
}

class _AmbulanceBookingScreenState extends State<AmbulanceBookingScreen> {
  late GoogleMapController _mapController;
  LatLng currentLocation = const LatLng(19.0760, 72.8777); // Default: Mumbai
  LatLng? destinationLocation;
  String pickupAddress = "Fetching address...";
  String? destinationAddress;
  Set<Polyline> polylines = {};
  final TextEditingController _searchController = TextEditingController();

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
      _fetchAddress(position.latitude, position.longitude, isPickup: true);
    });
  }

  // Fetch address from coordinates
  Future<void> _fetchAddress(double lat, double lng,
      {required bool isPickup}) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Geocode Response: ${data.toString()}"); // Debugging
      if (data["results"].isNotEmpty) {
        setState(() {
          if (isPickup) {
            pickupAddress = data["results"][0]["formatted_address"];
          } else {
            destinationAddress = data["results"][0]["formatted_address"];
          }
        });
      } else {
        setState(() {
          if (isPickup)
            pickupAddress = "No address found";
          else
            destinationAddress = "No address found";
        });
      }
    } else {
      debugPrint("Geocode Error: ${response.statusCode} - ${response.body}");
    }
  }

  // Fetch place suggestions from Google Places API
  Future<List<String>> _getPlaceSuggestions(String query) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&types=geocode";
    final response = await http.get(Uri.parse(url));

    debugPrint("Places API URL: $url"); // Debugging
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Places API Response: ${data.toString()}"); // Debugging
      if (data["status"] == "OK" && data["predictions"].isNotEmpty) {
        return (data["predictions"] as List)
            .map((prediction) => prediction["description"] as String)
            .toList();
      } else {
        debugPrint("No predictions found: ${data["status"]}");
        return [];
      }
    } else {
      debugPrint("Places API Error: ${response.statusCode} - ${response.body}");
      return [];
    }
  }

  // Fetch place details and update map
  Future<void> _onPlaceSelected(String place) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(place)}&key=$googleApiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Geocode Place Response: ${data.toString()}"); // Debugging
      if (data["results"].isNotEmpty) {
        final location = data["results"][0]["geometry"]["location"];
        setState(() {
          destinationLocation = LatLng(location["lat"], location["lng"]);
          destinationAddress = place;
          _mapController.animateCamera(
              CameraUpdate.newLatLngZoom(destinationLocation!, 15));
          _fetchRoute();
        });
      }
    } else {
      debugPrint(
          "Geocode Place Error: ${response.statusCode} - ${response.body}");
    }
  }

  // Fetch route between current location and destination
  Future<void> _fetchRoute() async {
    if (destinationLocation == null) return;

    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${destinationLocation!.latitude},${destinationLocation!.longitude}&key=$googleApiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Directions API Response: ${data.toString()}"); // Debugging
      if (data["routes"].isNotEmpty) {
        final points = data["routes"][0]["overview_polyline"]["points"];
        final List<LatLng> polylineCoordinates = _decodePolyline(points);

        setState(() {
          polylines = {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          };
          _mapController.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                currentLocation.latitude < destinationLocation!.latitude
                    ? currentLocation.latitude
                    : destinationLocation!.latitude,
                currentLocation.longitude < destinationLocation!.longitude
                    ? currentLocation.longitude
                    : destinationLocation!.longitude,
              ),
              northeast: LatLng(
                currentLocation.latitude > destinationLocation!.latitude
                    ? currentLocation.latitude
                    : destinationLocation!.latitude,
                currentLocation.longitude > destinationLocation!.longitude
                    ? currentLocation.longitude
                    : destinationLocation!.longitude,
              ),
            ),
            100, // Padding
          ));
        });
      }
    } else {
      debugPrint(
          "Directions API Error: ${response.statusCode} - ${response.body}");
    }
  }

  // Decode polyline points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to homepage
          },
        ),
        title:
            const Text('Book Ambulance', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: currentLocation, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                position: currentLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
              ),
              if (destinationLocation != null)
                Marker(
                  markerId: const MarkerId("destination"),
                  position: destinationLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
            },
            polylines: polylines,
            circles: {
              Circle(
                circleId: const CircleId("accuracyCircle"),
                center: currentLocation,
                radius: 100,
                fillColor: Colors.blue.withOpacity(0.2),
                strokeWidth: 1,
                strokeColor: Colors.blue,
              ),
            },
          ),

          // Search Bar with Autocomplete
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: TypeAheadField<String>(
                suggestionsCallback: (pattern) async {
                  if (pattern.isEmpty) return [];
                  return await _getPlaceSuggestions(pattern);
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSelected: (String suggestion) {
                  _searchController.text = suggestion;
                  _onPlaceSelected(suggestion);
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: _searchController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: "Enter destination...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.black54),
                    ),
                  );
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
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pickup Address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          pickupAddress,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (destinationAddress != null) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Destination Address",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_pin, color: Colors.red),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            destinationAddress!,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: destinationLocation == null
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ambulance booked successfully!')),
                            );
                          },
                    child: const Text("Book Ambulance",
                        style: TextStyle(color: Colors.white)),
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

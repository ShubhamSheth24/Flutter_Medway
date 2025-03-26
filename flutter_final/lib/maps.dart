// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_typeahead/flutter_typeahead.dart';

// const String googleApiKey =
//     "AIzaSyDhXcWeIuh9yG1aQ2AKvYCDGN6bVJL1RJk"; // Replace with your Google API Key

// class AmbulanceBookingScreen extends StatefulWidget {
//   const AmbulanceBookingScreen({super.key});

//   @override
//   State<AmbulanceBookingScreen> createState() => _AmbulanceBookingScreenState();
// }

// class _AmbulanceBookingScreenState extends State<AmbulanceBookingScreen> {
//   late GoogleMapController _mapController;
//   LatLng currentLocation = const LatLng(19.0760, 72.8777); // Default: Mumbai
//   LatLng? destinationLocation;
//   String pickupAddress = "Fetching address...";
//   String? destinationAddress;
//   Set<Polyline> polylines = {};
//   final TextEditingController _searchController = TextEditingController();

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
//       _fetchAddress(position.latitude, position.longitude, isPickup: true);
//     });
//   }

//   // Fetch address from coordinates
//   Future<void> _fetchAddress(double lat, double lng,
//       {required bool isPickup}) async {
//     final url =
//         "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       debugPrint("Geocode Response: ${data.toString()}"); // Debugging
//       if (data["results"].isNotEmpty) {
//         setState(() {
//           if (isPickup) {
//             pickupAddress = data["results"][0]["formatted_address"];
//           } else {
//             destinationAddress = data["results"][0]["formatted_address"];
//           }
//         });
//       } else {
//         setState(() {
//           if (isPickup)
//             pickupAddress = "No address found";
//           else
//             destinationAddress = "No address found";
//         });
//       }
//     } else {
//       debugPrint("Geocode Error: ${response.statusCode} - ${response.body}");
//     }
//   }

//   // Fetch place suggestions from Google Places API
//   Future<List<String>> _getPlaceSuggestions(String query) async {
//     final url =
//         "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&types=geocode";
//     final response = await http.get(Uri.parse(url));

//     debugPrint("Places API URL: $url"); // Debugging
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       debugPrint("Places API Response: ${data.toString()}"); // Debugging
//       if (data["status"] == "OK" && data["predictions"].isNotEmpty) {
//         return (data["predictions"] as List)
//             .map((prediction) => prediction["description"] as String)
//             .toList();
//       } else {
//         debugPrint("No predictions found: ${data["status"]}");
//         return [];
//       }
//     } else {
//       debugPrint("Places API Error: ${response.statusCode} - ${response.body}");
//       return [];
//     }
//   }

//   // Fetch place details and update map
//   Future<void> _onPlaceSelected(String place) async {
//     final url =
//         "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(place)}&key=$googleApiKey";
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       debugPrint("Geocode Place Response: ${data.toString()}"); // Debugging
//       if (data["results"].isNotEmpty) {
//         final location = data["results"][0]["geometry"]["location"];
//         setState(() {
//           destinationLocation = LatLng(location["lat"], location["lng"]);
//           destinationAddress = place;
//           _mapController.animateCamera(
//               CameraUpdate.newLatLngZoom(destinationLocation!, 15));
//           _fetchRoute();
//         });
//       }
//     } else {
//       debugPrint(
//           "Geocode Place Error: ${response.statusCode} - ${response.body}");
//     }
//   }

//   // Fetch route between current location and destination
//   Future<void> _fetchRoute() async {
//     if (destinationLocation == null) return;

//     final url =
//         "https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${destinationLocation!.latitude},${destinationLocation!.longitude}&key=$googleApiKey";
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       debugPrint("Directions API Response: ${data.toString()}"); // Debugging
//       if (data["routes"].isNotEmpty) {
//         final points = data["routes"][0]["overview_polyline"]["points"];
//         final List<LatLng> polylineCoordinates = _decodePolyline(points);

//         setState(() {
//           polylines = {
//             Polyline(
//               polylineId: const PolylineId("route"),
//               points: polylineCoordinates,
//               color: Colors.blue,
//               width: 5,
//             ),
//           };
//           _mapController.animateCamera(CameraUpdate.newLatLngBounds(
//             LatLngBounds(
//               southwest: LatLng(
//                 currentLocation.latitude < destinationLocation!.latitude
//                     ? currentLocation.latitude
//                     : destinationLocation!.latitude,
//                 currentLocation.longitude < destinationLocation!.longitude
//                     ? currentLocation.longitude
//                     : destinationLocation!.longitude,
//               ),
//               northeast: LatLng(
//                 currentLocation.latitude > destinationLocation!.latitude
//                     ? currentLocation.latitude
//                     : destinationLocation!.latitude,
//                 currentLocation.longitude > destinationLocation!.longitude
//                     ? currentLocation.longitude
//                     : destinationLocation!.longitude,
//               ),
//             ),
//             100, // Padding
//           ));
//         });
//       }
//     } else {
//       debugPrint(
//           "Directions API Error: ${response.statusCode} - ${response.body}");
//     }
//   }

//   // Decode polyline points
//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> points = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;

//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return points;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context); // Go back to homepage
//           },
//         ),
//         title:
//             const Text('Book Ambulance', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           // Google Map
//           GoogleMap(
//             initialCameraPosition:
//                 CameraPosition(target: currentLocation, zoom: 15),
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             onMapCreated: (controller) {
//               _mapController = controller;
//             },
//             markers: {
//               Marker(
//                 markerId: const MarkerId("currentLocation"),
//                 position: currentLocation,
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                     BitmapDescriptor.hueBlue),
//               ),
//               if (destinationLocation != null)
//                 Marker(
//                   markerId: const MarkerId("destination"),
//                   position: destinationLocation!,
//                   icon: BitmapDescriptor.defaultMarkerWithHue(
//                       BitmapDescriptor.hueRed),
//                 ),
//             },
//             polylines: polylines,
//             circles: {
//               Circle(
//                 circleId: const CircleId("accuracyCircle"),
//                 center: currentLocation,
//                 radius: 100,
//                 fillColor: Colors.blue.withOpacity(0.2),
//                 strokeWidth: 1,
//                 strokeColor: Colors.blue,
//               ),
//             },
//           ),

//           // Search Bar with Autocomplete
//           Positioned(
//             top: 10,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black12, blurRadius: 5)
//                 ],
//               ),
//               child: TypeAheadField<String>(
//                 suggestionsCallback: (pattern) async {
//                   if (pattern.isEmpty) return [];
//                   return await _getPlaceSuggestions(pattern);
//                 },
//                 itemBuilder: (context, String suggestion) {
//                   return ListTile(
//                     title: Text(suggestion),
//                   );
//                 },
//                 onSelected: (String suggestion) {
//                   _searchController.text = suggestion;
//                   _onPlaceSelected(suggestion);
//                 },
//                 builder: (context, controller, focusNode) {
//                   return TextField(
//                     controller: _searchController,
//                     focusNode: focusNode,
//                     decoration: const InputDecoration(
//                       hintText: "Enter destination...",
//                       border: InputBorder.none,
//                       icon: Icon(Icons.search, color: Colors.black54),
//                     ),
//                   );
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
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black12, blurRadius: 5)
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Pickup Address",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, color: Colors.blue),
//                       const SizedBox(width: 5),
//                       Expanded(
//                         child: Text(
//                           pickupAddress,
//                           style: const TextStyle(fontSize: 14),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (destinationAddress != null) ...[
//                     const SizedBox(height: 10),
//                     const Text(
//                       "Destination Address",
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.location_pin, color: Colors.red),
//                         const SizedBox(width: 5),
//                         Expanded(
//                           child: Text(
//                             destinationAddress!,
//                             style: const TextStyle(fontSize: 14),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       minimumSize: const Size(double.infinity, 45),
//                     ),
//                     onPressed: destinationLocation == null
//                         ? null
//                         : () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content:
//                                       Text('Ambulance booked successfully!')),
//                             );
//                           },
//                     child: const Text("Book Ambulance",
//                         style: TextStyle(color: Colors.white)),
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
    "AIzaSyCGqVA17yZNyfoDIcowXcI6wBx8BP7fdOg"; // Replace with your actual API key

class AmbulanceBookingScreen extends StatefulWidget {
  const AmbulanceBookingScreen({super.key});

  @override
  State<AmbulanceBookingScreen> createState() => _AmbulanceBookingScreenState();
}

class _AmbulanceBookingScreenState extends State<AmbulanceBookingScreen> {
  late GoogleMapController _mapController;
  LatLng currentLocation = const LatLng(19.2500, 72.8591); // Dahisar default
  LatLng? closestHospitalLocation;
  String pickupAddress = "Fetching address...";
  String? hospitalAddress;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  final TextEditingController _searchController = TextEditingController();
  String? estimatedTime;
  String? distance;
  bool isAmbulanceBooked = false;

  // Sample hospitals in Dahisar area
  final List<Map<String, dynamic>> nearbyHospitals = [
    {'name': 'Karuna Hospital', 'location': const LatLng(19.2505, 72.8578)},
    {'name': 'Pragati Hospital', 'location': const LatLng(19.2450, 72.8600)},
    {'name': 'Ashoka Hospital', 'location': const LatLng(19.2530, 72.8630)},
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      await _getUserLocation();
    } else {
      setState(() {
        pickupAddress = "Location permission denied";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required!')),
      );
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        markers.add(
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: currentLocation,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: "Your Location"),
          ),
        );
        _mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
      });
      await _fetchAddress(position.latitude, position.longitude,
          isPickup: true);
      await _findClosestHospital();
    } catch (e) {
      setState(() {
        pickupAddress = "Error fetching location: $e";
      });
    }
  }

  Future<void> _fetchAddress(double lat, double lng,
      {required bool isPickup}) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Geocoding Response: $data"); // Debug API response
        if (data["results"].isNotEmpty) {
          setState(() {
            if (isPickup) {
              pickupAddress = data["results"][0]["formatted_address"];
            } else {
              hospitalAddress = data["results"][0]["formatted_address"];
            }
          });
        } else {
          setState(() {
            if (isPickup) {
              pickupAddress = "No address found";
            } else {
              hospitalAddress = "No address found";
            }
          });
        }
      } else {
        setState(() {
          if (isPickup) {
            pickupAddress = "Error fetching address: ${response.statusCode}";
          } else {
            hospitalAddress = "Error fetching address: ${response.statusCode}";
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isPickup) {
          pickupAddress = "Error: $e";
        } else {
          hospitalAddress = "Error: $e";
        }
      });
    }
  }

  Future<List<String>> _getPlaceSuggestions(String query) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&types=geocode&location=${currentLocation.latitude},${currentLocation.longitude}&radius=10000";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "OK") {
          return (data["predictions"] as List)
              .map((prediction) => prediction["description"] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _onPlaceSelected(String place) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(place)}&key=$googleApiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["results"].isNotEmpty) {
          final location = data["results"][0]["geometry"]["location"];
          setState(() {
            closestHospitalLocation = LatLng(location["lat"], location["lng"]);
            hospitalAddress = place;
          });
          await _fetchRoute(closestHospitalLocation!, currentLocation);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting place: $e')),
      );
    }
  }

  Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey";
    print("Directions API URL: $url"); // Debug URL
    try {
      final response = await http.get(Uri.parse(url));
      print("Directions API Status: ${response.statusCode}"); // Debug status
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Directions API Response: $data"); // Debug full response
        if (data["status"] == "OK" && data["routes"].isNotEmpty) {
          final points = data["routes"][0]["overview_polyline"]["points"];
          final duration = data["routes"][0]["legs"][0]["duration"]["text"];
          final dist = data["routes"][0]["legs"][0]["distance"]["text"];
          final List<LatLng> polylineCoordinates = _decodePolyline(points);

          setState(() {
            estimatedTime = duration;
            distance = dist;
            polylines.clear(); // Clear previous polylines
            polylines.add(
              Polyline(
                polylineId: PolylineId("route_${destination.latitude}"),
                points: polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            );
            _mapController.animateCamera(CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  origin.latitude < destination.latitude
                      ? origin.latitude
                      : destination.latitude,
                  origin.longitude < destination.longitude
                      ? origin.longitude
                      : destination.longitude,
                ),
                northeast: LatLng(
                  origin.latitude > destination.latitude
                      ? origin.latitude
                      : destination.latitude,
                  origin.longitude > destination.longitude
                      ? origin.longitude
                      : destination.longitude,
                ),
              ),
              100,
            ));
          });
        } else {
          // Fallback: Draw a straight line if no route is found
          setState(() {
            polylines.clear();
            polylines.add(
              Polyline(
                polylineId:
                    PolylineId("fallback_route_${destination.latitude}"),
                points: [origin, destination],
                color: Colors.red,
                width: 5,
                patterns: [PatternItem.dash(20), PatternItem.gap(10)],
              ),
            );
            estimatedTime = "N/A";
            distance =
                "${(Geolocator.distanceBetween(origin.latitude, origin.longitude, destination.latitude, destination.longitude) / 1000).toStringAsFixed(1)} km";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No route found: ${data["status"]}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching route: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching route: $e')),
      );
    }
  }

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

  Future<void> _findClosestHospital() async {
    double minDistance = double.infinity;
    Map<String, dynamic>? closestHospital;

    for (var hospital in nearbyHospitals) {
      double dist = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        hospital['location'].latitude,
        hospital['location'].longitude,
      );
      if (dist < minDistance) {
        minDistance = dist;
        closestHospital = hospital;
      }
    }

    if (closestHospital != null) {
      setState(() {
        closestHospitalLocation = closestHospital?['location'] as LatLng;
        markers.add(
          Marker(
            markerId: MarkerId(closestHospital?['name'] as String),
            position: closestHospitalLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow:
                InfoWindow(title: "${closestHospital?['name']} (Linked)"),
          ),
        );
      });
      await _fetchAddress(
        closestHospitalLocation!.latitude,
        closestHospitalLocation!.longitude,
        isPickup: false,
      );
      await _fetchRoute(closestHospitalLocation!, currentLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Ambulance'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: currentLocation, zoom: 14),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: markers,
            polylines: polylines,
          ),
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
                suggestionsCallback: _getPlaceSuggestions,
                itemBuilder: (context, String suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSelected: _onPlaceSelected,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: _searchController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: "Search destination...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  );
                },
              ),
            ),
          ),
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
                  Text("Pickup: $pickupAddress"),
                  if (hospitalAddress != null) ...[
                    const SizedBox(height: 10),
                    Text("Linked Hospital: $hospitalAddress"),
                  ],
                  if (isAmbulanceBooked &&
                      estimatedTime != null &&
                      distance != null) ...[
                    const SizedBox(height: 10),
                    Text("Distance: $distance"),
                    Text("ETA: $estimatedTime"),
                  ],
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: closestHospitalLocation == null
                        ? null
                        : () async {
                            setState(() {
                              isAmbulanceBooked = true;
                            });
                            await _fetchRoute(
                                closestHospitalLocation!, currentLocation);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ambulance booked successfully!')),
                            );
                          },
                    child: const Text("Book Ambulance"),
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

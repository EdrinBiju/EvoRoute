import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:frontend/core/theme/app_pallete.dart';

class BusPage extends StatefulWidget {
  final dynamic bus;
  final String userStartingLocation;
  BusPage({Key? key, required this.bus, required this.userStartingLocation}) : super(key: key);

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> with TickerProviderStateMixin {
  LatLng? _busLocation;
  LatLng? _userLocation;
  Timer? _timer;
  final MapController _mapController = MapController();
  bool _autoCenter = true; // Auto-centering is enabled by default

  // List to hold polyline points for the road route.
  List<LatLng> _routePolylinePoints = [];

  // For day highlighting.
  final List<String> _allDays = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];
  final List<String> _allDayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  Map<String, int> stopFares = {};
  Map<String, String> arrivalTimes = {};
  final double averageSpeed = 60.0;

  @override
  void initState() {
    super.initState();
    _fetchFares();
    _calculateArrivalTimes();
    _fetchBusLocation();
    _fetchUserLocation();
    _fetchRoute(); // Fetch the road route from your API.
    // Update locations every 5 seconds.
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchBusLocation();
      _fetchUserLocation();
      // Optionally, refresh the route periodically.
      // _fetchRoute();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBusLocation() async {
    try {
      final response = await http.get(Uri.parse(
          '$url/bus-location/${widget.bus["bus_no"]}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          _busLocation = LatLng(data['latitude'], data['longitude']);
        });
        _fitMapToBounds();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load bus location'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching bus location: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _fetchUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _fitMapToBounds();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching user location: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Fetch the road route from your Flask API.
  /// The API is expected to use a query parameter "id".
  Future<void> _fetchRoute() async {
    try {
      final response = await http.get(Uri.parse(
          '$url/coordinates?id=${widget.bus["_id"]}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assume data is a list of objects with "lat" and "lng" keys.
        List<LatLng> routePoints = (data as List)
            .map((item) => LatLng(item['lat'], item['lng']))
            .toList();
        // Use OSRM to get the road route:
        if (routePoints.isNotEmpty) {
          // Create a list of "lng,lat" strings.
          List<String> coordStrings = routePoints
              .map((pt) => "${pt.longitude},${pt.latitude}")
              .toList();
          final osrmUrl =
              "http://router.project-osrm.org/route/v1/driving/${coordStrings.join(';')}?overview=full&geometries=geojson";
          final osrmResponse = await http.get(Uri.parse(osrmUrl));
          if (osrmResponse.statusCode == 200) {
            final osrmData = json.decode(osrmResponse.body);
            List<dynamic> routeCoords =
                osrmData['routes'][0]['geometry']['coordinates'];
            List<LatLng> polylinePoints =
                routeCoords.map((point) => LatLng(point[1], point[0])).toList();
            setState(() {
              _routePolylinePoints = polylinePoints;
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load road route'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load route coordinates'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching route: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Smoothly animate the map to the destination center and zoom level.
  void animateMapMove(LatLng destCenter, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.center.latitude,
      end: destCenter.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.center.longitude,
      end: destCenter.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.zoom,
      end: destZoom,
    );

    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  /// Compute the bounds for both the bus and user locations,
  /// and animate the map to fit them within view.
  void _animateFitBounds() {
    if (_busLocation == null || _userLocation == null) return;

    // Create LatLngBounds that include both the bus and user
    final bounds = LatLngBounds.fromPoints([
      _busLocation!,
      _userLocation!,
    ]);

    // Fit the map to the computed bounds with padding
    _mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(30), // Add padding for better visibility
        maxZoom: 16, // Optional: Limit max zoom level
      ),
    );
  }

  /// Only animate recentering if auto-centering is enabled.
  void _fitMapToBounds() {
    if (!_autoCenter) return;
    _animateFitBounds();
  }

  void _recenterMap() {
    setState(() {
      _autoCenter = true;
    });
    _fitMapToBounds();
  }

  void _openFullscreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenMapPage(
          busLocation: _busLocation,
          userLocation: _userLocation,
          routePolylinePoints: _routePolylinePoints,
        ),
      ),
    );
  }


  String _formatTime(String rawTime) {
    try {
      final parsedTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(rawTime, true);
      final istTime = parsedTime.add(Duration(hours: 5, minutes: 30));
      return DateFormat('hh:mm a').format(istTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? labelColor, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: labelColor ?? Color(0xFF9E9E9E))),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: valueColor ?? Colors.white))),
        ],
      ),
    );
  }

  Future<void> _fetchFares() async {
    final routeId = widget.bus['_id'];
    final urls = Uri.parse('$url/calculate_fare');
    
    try {
      final response = await http.post(
        urls,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': routeId, 'startingLocation': widget.userStartingLocation}),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> fareData = jsonDecode(response.body);
        setState(() {
          stopFares = {for (var stop in fareData) stop['stop']: stop['fare']};
        });
      }
    } catch (e) {
      print('Error fetching fare data: \$e');
    }
  }

  void _calculateArrivalTimes() {
    try {
      List<String> stopLocations = List<String>.from(widget.bus['stop_locations']);
      List<String> stopKmsStr = List<String>.from(widget.bus['stop_kms']);
      List<double> stopDistances = stopKmsStr.map((s) => double.parse(s)).toList();

      // Convert start time from GMT to IST
      DateTime startTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(widget.bus['start_time'], true);
      startTime = startTime.add(Duration(hours: 5, minutes: 30));

      Map<String, String> tempArrivalTimes = {};
      String busType = widget.bus['bus_type'];
      double averageSpeed = _getBusSpeed(busType);

      const int stopDelayMinutes = 2; // Delay at each stop for entry/exit

      // Store first stop (starting location) with formatted time
      tempArrivalTimes[widget.bus['starting_location']] = DateFormat('hh:mm a').format(startTime);

      // Process stop locations
      for (int i = 0; i < stopLocations.length; i++) {
        double distance = stopDistances[i];
        int travelTime = (distance / averageSpeed * 60).toInt(); // Convert to minutes
        startTime = startTime.add(Duration(minutes: travelTime + stopDelayMinutes)); // Add stop delay

        tempArrivalTimes[stopLocations[i]] = DateFormat('hh:mm a').format(startTime);
      }

      // Add final destination arrival time
      double finalDistance = double.parse(widget.bus['destination_km']);
      int finalTravelTime = (finalDistance / averageSpeed * 60).toInt();
      startTime = startTime.add(Duration(minutes: finalTravelTime));

      tempArrivalTimes[widget.bus['destination_location']] = DateFormat('hh:mm a').format(startTime);

      setState(() {
        arrivalTimes = tempArrivalTimes;
      });
    } catch (e) {
      print('Error calculating arrival times: $e');
    }
  }

  double _getBusSpeed(String busType) {
    switch (busType) {
      case "City/Ordinary":
        return 40.0;
      case "Fast Passenger/LSFP":
        return 50.0;
      case "Express/Super Express":
        return 55.0;
      case "Super Deluxe/Semi Sleeper":
        return 60.0;
      case "Multi Axle Volvo":
        return 80.0;
      case "Low Floor Non A/C":
        return 38.0;
      case "Super Air Express":
        return 65.0;
      case "Luxury/Hi-Tech/Ac":
        return 70.0;
      case "Single Axle Volvo":
        return 75.0;
      case "Super Fast Passenger":
        return 58.0;
      case "Low Floor A/C":
        return 42.0;
      case "City Fast":
        return 45.0;
      default:
        return 50.0; 
    }
  }

  /// Builds route display with stops, fares, and arrival times
  Widget _buildRouteColumn({required String start, required List<String> stops, required String destination}) {
  final routeLocations = [start, ...stops, destination];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Headers for Route, Fare, and Arrival
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Route', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            Expanded(
                child: Center(
                    child: Text('Fare', style: TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold)))),
            Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Arrival   ', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
      Divider(color: Colors.white24, thickness: 1),

      // Bus Stops
      for (int i = 0; i < routeLocations.length; i++) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    i == 0
                        ? Icons.radio_button_checked
                        : (i == routeLocations.length - 1 ? Icons.location_on : Icons.arrow_downward),
                    color: i == 0
                        ? Colors.lightGreenAccent
                        : (i == routeLocations.length - 1 ? Colors.redAccent : Colors.cyanAccent),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routeLocations[i],
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: stopFares.containsKey(routeLocations[i])
                    ? Text(
                        '₹${stopFares[routeLocations[i]]}',
                        style: TextStyle(color: Colors.amberAccent, fontSize: 15, fontWeight: FontWeight.bold),
                      )
                    : SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: arrivalTimes.containsKey(routeLocations[i])
                    ? Text(
                        arrivalTimes[routeLocations[i]]!,
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 15),
                      )
                    : SizedBox.shrink(),
              ),
            ),
          ],
        ),
        if (i < routeLocations.length - 1) SizedBox(height: 6),
      ],
    ],
  );
}


  Widget _buildDaysRow(List<String>? busDays) {
    final selectedDays = (busDays == null || busDays.isEmpty) ? [] : busDays;
    final selectedIndexes = <int>[];
    for (int i = 0; i < _allDays.length; i++) {
      if (selectedDays.contains(_allDays[i])) {
        selectedIndexes.add(i);
      }
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(_allDays.length, (index) {
        final letter = _allDayLetters[index];
        final isSelected = selectedIndexes.contains(index);
        return Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppPallete.gradient3 : const Color.fromARGB(255, 233, 77, 66), //Color(0xFF76FF03)
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(letter,
              style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black,
                  fontWeight: FontWeight.bold)),
        );
      }),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 300,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _busLocation ?? LatLng(0, 0),
                zoom: 15,
                interactiveFlags: InteractiveFlag.all,
                onPositionChanged: (MapPosition position, bool hasGesture) {
                  if (hasGesture && _autoCenter) {
                    setState(() {
                      _autoCenter = false;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                // Polyline layer for the road route.
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    if (_routePolylinePoints.isNotEmpty)
                      Polyline(
                        points: _routePolylinePoints,
                        strokeWidth: 4.0,
                        color: Colors.purple,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (_busLocation != null)
                      Marker(
                        point: _busLocation!,
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.orangeAccent, Colors.deepOrange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
                          ),
                          child: Center(
                            child: Icon(Icons.directions_bus, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.withOpacity(0.8),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Icon(Icons.person, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    // Start marker using Icons.trip_origin (green).
                    if (_routePolylinePoints.isNotEmpty)
                      Marker(
                        point: _routePolylinePoints.first,
                        width: 30,
                        height: 30,
                        child: Icon(Icons.radio_button_checked, color: Colors.green, size: 28),
                      ),
                    // Destination marker using Icons.location_on (red).
                    if (_routePolylinePoints.isNotEmpty)
                      Marker(
                        point: _routePolylinePoints.last,
                        width: 30,
                        height: 30,
                        child: Icon(Icons.location_on, color: Colors.red, size: 28),
                      ),
                  ],
                ),
              ],
            ),
            if (_busLocation == null || _userLocation == null)
              Positioned.fill(child: Center(child: CircularProgressIndicator())),
            // Top-right: fullscreen button.
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: "bus_fullscreen",
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _openFullscreenMap,
                child: Icon(Icons.fullscreen, color: Colors.black),
              ),
            ),
            // Bottom-right: recenter button.
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: "bus_recenter",
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _recenterMap,
                child: Icon(Icons.my_location, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busNumber = widget.bus['bus_no'] ?? 'N/A';
    final startingLocation = widget.bus['starting_location'] ?? 'N/A';
    final destinationLocation = widget.bus['destination_location'] ?? 'N/A';
    final busType = widget.bus['bus_type'] ?? 'N/A';
    final startTime = widget.bus['start_time'] != null ? _formatTime(widget.bus['start_time']) : 'N/A';
    final reachTime = widget.bus['reach_time'] != null ? _formatTime(widget.bus['reach_time']) : 'N/A';
    final stops = widget.bus['stop_locations'] is List
        ? (widget.bus['stop_locations'] as List).map((s) => s.toString()).toList()
        : <String>[];
    final days = widget.bus['days'] is List
        ? (widget.bus['days'] as List).map((d) => d.toString()).toList()
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8, // Adds a subtle shadow effect
        title: Row(
          mainAxisSize: MainAxisSize.min, // Keeps it compact
          children: [
            Icon(Icons.directions_bus, color: Colors.white, size: 26), // Bus icon
            SizedBox(width: 8),
            Text(
              'Bus Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient, // Maintains dark theme
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)), // Slight curve
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Bus Details Container.
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!, width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('Bus #$busNumber',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Divider(height: 24, color: Colors.white24, thickness: 1),
                      _buildDetailRow('Bus Type', busType),
                      SizedBox(height: 12),
                      _buildDetailRow('Start Time', startTime),
                      _buildDetailRow('Reach Time', reachTime),
                      SizedBox(height: 12),
                      _buildDetailRow('Bording', widget.userStartingLocation),
                      SizedBox(height: 12),
                      _buildRouteColumn(start: startingLocation, stops: stops, destination: destinationLocation),
                      SizedBox(height: 12),
                      Text('Trip Days',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9E9E9E))),
                      SizedBox(height: 8),
                      _buildDaysRow(days),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Map Widget.
              _buildMap(),
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenMapPage extends StatefulWidget {
  final LatLng? busLocation;
  final LatLng? userLocation;
  final List<LatLng> routePolylinePoints;

  const FullscreenMapPage({
    Key? key,
    required this.busLocation,
    required this.userLocation,
    required this.routePolylinePoints,
  }) : super(key: key);

  @override
  _FullscreenMapPageState createState() => _FullscreenMapPageState();
}

class _FullscreenMapPageState extends State<FullscreenMapPage> with TickerProviderStateMixin {
  final MapController _fsMapController = MapController();
  bool _autoCenter = true;

  /// Smoothly animate the map to a new center and zoom.
  void animateMapMove(LatLng destCenter, double destZoom) {
    final latTween = Tween<double>(
      begin: _fsMapController.center.latitude,
      end: destCenter.latitude,
    );
    final lngTween = Tween<double>(
      begin: _fsMapController.center.longitude,
      end: destCenter.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _fsMapController.zoom,
      end: destZoom,
    );

    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _fsMapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  void _animateFitBounds() {
    if (widget.busLocation == null || widget.userLocation == null) return;
    final center = LatLng(
      (widget.busLocation!.latitude + widget.userLocation!.latitude) / 2,
      (widget.busLocation!.longitude + widget.userLocation!.longitude) / 2,
    );
    final distance = Distance().as(LengthUnit.Kilometer, widget.busLocation!, widget.userLocation!);
    double destZoom;
    if (distance < 1) {
      destZoom = 16;
    } else if (distance < 5) {
      destZoom = 14;
    } else if (distance < 10) {
      destZoom = 13;
    } else {
      destZoom = 12;
    }
    destZoom -= 0.5; // Apply a slight zoom out for padding.
    animateMapMove(center, destZoom);
  }

  void _fitMapToBounds() {
    if (!_autoCenter) return;
    if (widget.busLocation == null || widget.userLocation == null) return;
    _animateFitBounds();
  }

  void _recenterMap() {
    setState(() {
      _autoCenter = true;
    });
    _fitMapToBounds();
  }

  void _minimizeMap() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToBounds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _fsMapController,
            options: MapOptions(
              center: widget.busLocation ?? LatLng(0, 0),
              zoom: 15,
              interactiveFlags: InteractiveFlag.all,
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture && _autoCenter) {
                  setState(() {
                    _autoCenter = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              // Polyline layer for the road route.
              PolylineLayer(
                polylineCulling: false,
                polylines: [
                  if (widget.routePolylinePoints.isNotEmpty)
                    Polyline(
                      points: widget.routePolylinePoints,
                      strokeWidth: 4.0,
                      color: Colors.purple,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (widget.busLocation != null)
                    Marker(
                      point: widget.busLocation!,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.orangeAccent, Colors.deepOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
                        ),
                        child: Center(child: Icon(Icons.directions_bus, color: Colors.white, size: 18)),
                      ),
                    ),
                  if (widget.userLocation != null)
                    Marker(
                      point: widget.userLocation!,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withOpacity(0.8),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(child: Icon(Icons.person, color: Colors.white, size: 16)),
                      ),
                    ),
                  // Start marker using Icons.trip_origin.
                  if (widget.routePolylinePoints.isNotEmpty)
                    Marker(
                      point: widget.routePolylinePoints.first,
                      width: 30,
                      height: 30,
                      child: Icon(Icons.radio_button_checked, color: Colors.green, size: 28),
                    ),
                  // Destination marker using Icons.location_on.
                  if (widget.routePolylinePoints.isNotEmpty)
                    Marker(
                      point: widget.routePolylinePoints.last,
                      width: 30,
                      height: 30,
                      child: Icon(Icons.location_on, color: Colors.red, size: 28),
                    ),
                ],
              ),
            ],
          ),
          // Top-right: minimize button.
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "fs_minimize",
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _minimizeMap,
              child: Icon(Icons.fullscreen_exit, color: Colors.black),
            ),
          ),
          // Bottom-right: recenter button.
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "fs_recenter",
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _recenterMap,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

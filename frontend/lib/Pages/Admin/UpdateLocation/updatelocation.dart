import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateLocationPage extends StatefulWidget {
  @override
  _UpdateLocationPageState createState() => _UpdateLocationPageState();
}

class _UpdateLocationPageState extends State<UpdateLocationPage> {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> filteredLocations = [];
  int? expandedIndex;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    final response = await http.get(Uri.parse('$url/alllocations'));
    if (response.statusCode == 200) {
      setState(() {
        locations = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        locations.sort((a, b) => a['name'].compareTo(b['name']));
        filteredLocations = List.from(locations);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch locations'), backgroundColor: Colors.red),
      );
    }
  }

  void _filterLocations(String query) {
    setState(() {
      filteredLocations = locations.where((location) {
        return location['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _updateLocation(int index) async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMap(
          initialLocation: LatLng(filteredLocations[index]['latitude'], filteredLocations[index]['longitude']),
          initialName: filteredLocations[index]['name'],
        ),
      ),
    );

    if (updatedData != null) {
      await _sendUpdateRequest(index, updatedData);
    }
  }

  Future<void> _sendUpdateRequest(int index, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$url/updatelocation'),
      body: jsonEncode({
        'id': filteredLocations[index]["_id"],
        'name': updatedData['name'],
        'latitude': updatedData['latitude'],
        'longitude': updatedData['longitude'],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        filteredLocations[index]['name'] = updatedData['name'];
        filteredLocations[index]['latitude'] = updatedData['latitude'];
        filteredLocations[index]['longitude'] = updatedData['longitude'];
        locations.sort((a, b) => a['name'].compareTo(b['name']));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location updated successfully'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update location'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_location_alt, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'Update Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterLocations,
              decoration: InputDecoration(
                labelText: 'Search Location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                final location = filteredLocations[index];
                final isExpanded = expandedIndex == index;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(location["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Lat: ${location["latitude"]}, Lng: ${location["longitude"]}"),
                        leading: IconButton(
                          icon: Icon(isExpanded ? Icons.expand_less : Icons.visibility, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              expandedIndex = isExpanded ? null : index;
                            });
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _updateLocation(index),
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          height: 150,
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(location["latitude"], location["longitude"]),
                              zoom: 14.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(location["latitude"], location["longitude"]),
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class FullScreenMap extends StatefulWidget {
  final LatLng initialLocation;
  final String initialName;

  FullScreenMap({required this.initialLocation, required this.initialName});

  @override
  _FullScreenMapState createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  String _locationName = "";
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
    _locationName = widget.initialName;
    _nameController.text = _locationName;
  }

  void _updateLocation(LatLng newLocation) {
    setState(() {
      _selectedLocation = newLocation;
    });
  }

  void _showUpdateConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Update"),
          content: Text("Are you sure you want to update this location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'latitude': double.parse(_selectedLocation!.latitude.toStringAsFixed(10)),
                  'longitude': double.parse(_selectedLocation!.longitude.toStringAsFixed(10)),
                });
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _selectedLocation,
              zoom: 14.0,
              onTap: (_, point) => _updateLocation(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _isEditing
                        ? TextField(
                            controller: _nameController,
                            autofocus: true,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Enter location name",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          )
                        : Text(_locationName, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (_isEditing) _locationName = _nameController.text;
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _showUpdateConfirmation, // Open confirmation dialog
              child: Text("Update", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
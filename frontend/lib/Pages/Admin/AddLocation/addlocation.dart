import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final TextEditingController _locationController = TextEditingController();
  LatLng? _selectedLocation;
  final MapController _mapController = MapController(); // Initialize MapController

  void _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectLocationPage()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLocation = result;
        Future.delayed(Duration(milliseconds: 300), () {
          _mapController.move(_selectedLocation!, 14.0); // Move map after update
        });
      });
    }
  }

  void _addLocation() async {
    if (_locationController.text.isEmpty || _selectedLocation == null) return;

    final response = await http.post(
      Uri.parse('$url/addlocation'),
      body: jsonEncode({
        'name': _locationController.text,
        'latitude': double.parse(_selectedLocation!.latitude.toStringAsFixed(10)),
        'longitude': double.parse(_selectedLocation!.longitude.toStringAsFixed(10)),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location added successfully'), backgroundColor: Colors.green),
      );
      _locationController.clear();
      setState(() => _selectedLocation = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add location'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8, // Adds a subtle shadow effect
        title: Row(
          mainAxisSize: MainAxisSize.min, // Keeps it compact
          children: [
            Icon(Icons.add_location_alt, color: Colors.white, size: 26), // Bus icon
            SizedBox(width: 8),
            Text(
              'Add Location',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Enter location name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.location_on, color: Colors.redAccent, size: 36),
                  onPressed: _openMap,
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_selectedLocation != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                  child: FlutterMap(
                    mapController: _mapController, // Assign MapController here
                    options: MapOptions(
                      center: _selectedLocation!,
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
                            point: _selectedLocation!,
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _addLocation,
                child: Text('Add Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  LatLng? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(10.8505, 76.2711),
          zoom: 6.0,
          onTap: (_, latLng) {
            setState(() => _selectedPoint = latLng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          if (_selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedPoint!,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.check, color: Colors.white),
        onPressed: () {
          if (_selectedPoint != null) {
            Navigator.pop(context, _selectedPoint);
          }
        },
      ),
    );
  }
}

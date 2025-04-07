import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteLocationPage extends StatefulWidget {
  const DeleteLocationPage({super.key});

  @override
  _DeleteLocationPageState createState() => _DeleteLocationPageState();
}

class _DeleteLocationPageState extends State<DeleteLocationPage> {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> filteredLocations = [];
  int? expandedIndex;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    searchController.addListener(_filterLocations);
  }

  Future<void> _fetchLocations() async {
    final response = await http.get(Uri.parse('$url/alllocations'));
    if (response.statusCode == 200) {
      setState(() {
        locations = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        locations.sort((a, b) => a["name"].compareTo(b["name"]));
        filteredLocations = locations;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch locations'), backgroundColor: Colors.red),
      );
    }
  }

  void _filterLocations() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredLocations = locations.where((location) {
        return location["name"].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Location?'),
        content: Text('Are you sure you want to delete this location?'),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteLocation(index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocation(int index) async {
    final response = await http.delete(
      Uri.parse('$url/deletelocation/${filteredLocations[index]["_id"]}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        locations.removeWhere((location) => location["_id"] == filteredLocations[index]["_id"]);
        filteredLocations.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location deleted successfully'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete location'), backgroundColor: Colors.red),
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
            Icon(Icons.wrong_location, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'Delete Location',
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
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(index),
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
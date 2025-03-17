import 'package:flutter/material.dart';
import 'package:frontend/Pages/Employee/Update/updateroute.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class ListRoutePage extends StatefulWidget {
  const ListRoutePage({super.key});

  @override
  _ListRoutePageState createState() => _ListRoutePageState();
}

class _ListRoutePageState extends State<ListRoutePage> {
  List<dynamic> busRoutes = [];
  bool isLoading = true;
  final String apiUrl = "$url/allbuses"; // API endpoint

  @override
  void initState() {
    super.initState();
    fetchBuses();
  }

  Future<void> fetchBuses() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          busRoutes = responseData['data']; // Extracting 'data' array
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load bus routes");
      }
    } catch (e) {
      print("Error fetching buses: $e");
      setState(() {
        isLoading = false;
      });
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
            Icon(Icons.update, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'Update Bus Route',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : busRoutes.isEmpty
              ? Center(child: Text("No bus routes available", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: busRoutes.length,
                  itemBuilder: (context, index) {
                    var bus = busRoutes[index];
                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Icon(Icons.directions_bus, color: Colors.white),
                        title: Text(
                          "${bus['bus_no']} | ${bus['starting_location']} → ${bus['destination_location']}",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${bus['bus_type']} • Start: ${_formatTime(bus['start_time'])}",
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateRoutePage(busData: bus),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTime(String time) {
    final parsedTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(time, true);
    final istTime = parsedTime.add(Duration(hours: 5, minutes: 30));
    return DateFormat('hh:mm a').format(istTime);
  }
}

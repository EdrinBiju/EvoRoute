import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/constant.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:intl/intl.dart';

class DeleteRoutePage extends StatefulWidget {
  const DeleteRoutePage({super.key});

  @override
  _DeleteRoutePageState createState() => _DeleteRoutePageState();
}

class _DeleteRoutePageState extends State<DeleteRoutePage> {
  List<dynamic> busRoutes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  Future<void> _fetchBuses() async {
    try {
      final response = await http.get(Uri.parse("$url/allroutes"));
      if (response.statusCode == 200) {
        setState(() {
          busRoutes = jsonDecode(response.body)['data']; // Extracting data array
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load buses');
      }
    } catch (e) {
      print("Error fetching buses: $e");
      setState(() => isLoading = false);
    }
  }

  void _deleteBus(String routeId) async {
    bool confirmDelete = await _showDeleteConfirmation();
    if (!confirmDelete) return;

    try {
      final response = await http.post(
        Uri.parse("$url/deleteroute"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": routeId}), // Sending _id in payload
      );

      if (response.statusCode == 200) {
        setState(() {
          busRoutes.removeWhere((route) => route['_id'] == routeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bus route deleted successfully!")),
        );
      } else {
        throw Exception("Failed to delete bus route");
      }
    } catch (e) {
      print("Error deleting bus: $e");
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this bus route?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8, // Adds depth
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep_outlined, color: Colors.white, size: 26), // Bus icon
            SizedBox(width: 8),
            Text(
              'Delete Bus Route',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)), // Rounded bottom
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
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(Icons.directions_bus, color: Colors.white),
                        title: Text(
                          "${bus['bus_no']} | ${bus['starting_location']} → ${bus['destination_location']}",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(bus['bus_type'], style: TextStyle(color: Colors.grey)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow("Bus Number", bus['bus_no']),
                                _buildDetailRow("Start Time", _formatTime(bus['start_time'])),
                                _buildDetailRow("Reach Time", _formatTime(bus['reach_time'])),
                                _buildDetailRow("Days", _shortenDays(bus['days'])),
                                Divider(color: Colors.white),
                                Text("Stops:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Column(
                                  children: List.generate(bus['stop_locations'].length, (i) {
                                    return _buildDetailRow(bus['stop_locations'][i], "");
                                  }),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                    onPressed: () => _deleteBus(bus['_id']),
                                    child: Text("Delete Route", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    final parsedTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(time, true);
    final istTime = parsedTime.add(Duration(hours: 5, minutes: 30));
    return DateFormat('hh:mm a').format(istTime);
  }

  String _shortenDays(List<dynamic> days) {
    Map<String, String> shortDays = {
      "Monday": "Mon",
      "Tuesday": "Tue",
      "Wednesday": "Wed",
      "Thursday": "Thu",
      "Friday": "Fri",
      "Saturday": "Sat",
      "Sunday": "Sun"
    };
    return days.map((day) => shortDays[day] ?? day).join(", ");
  }
}

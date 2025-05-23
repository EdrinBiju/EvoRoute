import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/Pages/Users/Buses/bus_details.dart';
import 'package:intl/intl.dart';

class FindBusPage extends StatelessWidget {
  final List<dynamic> buses;
  final String userStartingLocation;
  const FindBusPage({super.key, required this.buses, required this.userStartingLocation});

  String _formatTime(String rawTime) {
    try {
      // Parse the incoming date string
      final parsedTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(rawTime, true);
      // Convert UTC to IST (UTC+5:30)
      final istTime = parsedTime.add(Duration(hours: 5, minutes: 30));
      // Format to hh:mm AM/PM
      return DateFormat('hh:mm a').format(istTime);
    } catch (e) {
      return 'Invalid Time';
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
            Icon(Icons.directions_bus, color: Colors.white, size: 26), // Best icon for available buses
            SizedBox(width: 8),
            Text(
              'Available Buses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)), // Stylish rounded bottom
          ),
        ),
      ),
      body: buses.isEmpty
          ? Center(
              child: Text(
                'No buses found for the selected route.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white60,
                    ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 16.0), // Add gap before the first bus data
              child: ListView.builder(
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  final bus = buses[index];
                  final startLocation = bus['starting_location'] ?? 'Unknown';
                  final destination = bus['destination_location'] ?? 'Unknown';
                  final type = bus['bus_type'] ?? 'Unknown';
                  final time = _formatTime(bus['start_time'] ?? '');

                  return GestureDetector(
                    onTap: () {
                      // Navigate to BusPage when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusPage(bus: bus, userStartingLocation: userStartingLocation,),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12.0), // Rounded corners
                        border: Border.all(color: Colors.white30, width: 1), // Light border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Start: $startLocation',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white60,
                                      ),
                                  overflow: TextOverflow.ellipsis, // Handles long texts
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  'Destination: $destination',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white60,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$type',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.blueAccent,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  'Time: $time',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.greenAccent,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

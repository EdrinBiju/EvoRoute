import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';

class BusPage extends StatelessWidget {
  final dynamic bus;

  BusPage({super.key, required this.bus});

  // For day highlighting: full day name -> single-letter abbreviation in order: S M T W T F S
  // You can reorder or rename if your week starts differently.
  final List<String> _allDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  final List<String> _allDayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Converts raw UTC time to IST, formatted "hh:mm a"
  String _formatTime(String rawTime) {
    try {
      final parsedTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(rawTime, true);
      final istTime = parsedTime.add(Duration(hours: 5, minutes: 30));
      return DateFormat('hh:mm a').format(istTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  // Builds a label-value row with custom styling
  Widget _buildDetailRow(String label, String value, {Color? labelColor, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: labelColor ?? Color(0xFF9E9E9E),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the vertical route (start -> stops -> destination)
  Widget _buildRouteColumn({
    required String start,
    required List<String> stops,
    required String destination,
  }) {
    // Combine them into a single list: start, stops..., destination
    final routeLocations = [start, ...stops, destination];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < routeLocations.length; i++) ...[
          Row(
            children: [
              // A small vertical line or arrow icon for style
              Icon(
                i == 0
                    ? Icons.radio_button_checked
                    : (i == routeLocations.length - 1
                        ? Icons.location_on
                        : Icons.arrow_downward),
                color: i == 0
                    ? Colors.lightGreenAccent
                    : (i == routeLocations.length - 1
                        ? Colors.redAccent
                        : Colors.cyanAccent),
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  routeLocations[i],
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
          if (i < routeLocations.length - 1) SizedBox(height: 6),
        ],
      ],
    );
  }

  // Builds the row of days S M T W T F S, highlighting the bus days
  Widget _buildDaysRow(List<String>? busDays) {
    // If busDays is not a List, fallback to an empty list
    final selectedDays = (busDays == null || busDays.isEmpty) ? [] : busDays;
    // Convert full day name to index
    // e.g. Sunday -> 0, Monday -> 1, etc.
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
          width: 30, // Make each letter box 30px wide
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.amberAccent : Colors.redAccent,//Colors.black45,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            letter,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black,//Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract details
    final busNumber = bus['bus_no'] ?? 'N/A';
    final startingLocation = bus['starting_location'] ?? 'N/A';
    final destinationLocation = bus['destination_location'] ?? 'N/A';
    final busType = bus['bus_type'] ?? 'N/A';
    final startTime =
        bus['start_time'] != null ? _formatTime(bus['start_time']) : 'N/A';
    final reachTime =
        bus['reach_time'] != null ? _formatTime(bus['reach_time']) : 'N/A';
    final stops = bus['stop_locations'] is List
        ? (bus['stop_locations'] as List).map((s) => s.toString()).toList()
        : <String>[];
    final days = bus['days'] is List
        ? (bus['days'] as List).map((d) => d.toString()).toList()
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Details'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
          ),
        ),
      ),
      backgroundColor: Colors.black,// Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              // A vertical gradient for a stylish background
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Bus #$busNumber',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(
                    height: 24,
                    color: Colors.white24,
                    thickness: 1,
                  ),

                  // Bus Type
                  _buildDetailRow('Bus Type', busType),
                  SizedBox(height: 12),

                  // Times
                  // Text(
                  //   'Timings',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xFF9E9E9E),
                  //   ),
                  // ),
                  // SizedBox(height: 4),
                  _buildDetailRow('Start Time', startTime),
                  _buildDetailRow('Reach Time', reachTime),
                  SizedBox(height: 12),

                  // Route
                  Text(
                    'Route',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  SizedBox(height: 4),
                  _buildRouteColumn(
                    start: startingLocation,
                    stops: stops,
                    destination: destinationLocation,
                  ),
                  SizedBox(height: 12),

                  // Trip Days
                  Text(
                    'Trip Days',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDaysRow(days),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

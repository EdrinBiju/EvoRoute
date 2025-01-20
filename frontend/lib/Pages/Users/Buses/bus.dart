import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:intl/intl.dart';

class BusPage extends StatelessWidget {
  final dynamic bus;

  const BusPage({Key? key, required this.bus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Details'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
          ),
        ), // Dark grey app bar for contrast
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[600]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Starting Location
                    _buildTextRow(
                      'Start : ',
                      bus['starting_location'],
                      // fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    
                    // Destination Location
                    _buildTextRow(
                      'Destination : ',
                      bus['destination_location'],
                    ),
                    SizedBox(height: 8),
                    
                    // Bus Type
                    _buildTextRow(
                      'Type : ',
                      bus['bus_type'],
                    ),
                    SizedBox(height: 8),
                    
                    // Start Time
                    _buildTextRow(
                      'Start Time : ',
                      _formatTime(bus['start_time'] ?? ''),
                    ),
                    SizedBox(height: 8),
                    
                    // Stop Locations Header
                    Text(
                      'Stops : ',
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Stop Locations List
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (bus['stop_locations'] as List<dynamic>)
                          .map((stop) => _buildTextRow(
                                '',
                                stop,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF121212), // Dark background for the page
    );
  }

  // Helper function to create a styled text row
  Widget _buildTextRow(String label, String value, {FontWeight fontWeight = FontWeight.normal}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9E9E9E), // Lighter grey for labels
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: fontWeight,
              color: Colors.white, // White text for values
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Function to format raw time string into desired format
  String _formatTime(String rawTime) {
    try {
      // Parse the incoming date string
      final parsedTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(rawTime, true);
      return DateFormat('hh:mm a').format(parsedTime); // Format to hh:mm AM/PM
    } catch (e) {
      return 'Invalid Time';
    }
  }
}

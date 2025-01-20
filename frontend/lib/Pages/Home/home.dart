import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> locations = ['City A', 'City B', 'City C', 'City D'];
  final List<String> busTypes = ['Ordinary', 'Fast', 'Super Fast', 'Swift'];

  String? selectedStartLocation;
  String? selectedDestinationLocation;
  final Map<String, bool> selectedBusTypes = {
    'Ordinary': false,
    'Fast': false,
    'Super Fast': false,
    'Swift': false,
  };

  void _searchBuses() {
    // Call your API to fetch available buses
    print('Start Location: $selectedStartLocation');
    print('Destination Location: $selectedDestinationLocation');
    print('Selected Bus Types: ${selectedBusTypes.entries.where((e) => e.value).map((e) => e.key).toList()}');

    // Navigate to the results page
    Navigator.pushNamed(context, '/busResults');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EvoRoute'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
            
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Your Bus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Starting Location Dropdown
            SizedBox(
              width: double.infinity, // Ensures the dropdown matches the button width
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Starting Location',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                value: selectedStartLocation,
                items: locations
                    .map(
                      (location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStartLocation = value;
                  });
                },
                // Ensuring menu alignment
                menuMaxHeight: 200, // Optional, set to control height
                isExpanded: false, // Ensures dropdown menu matches width
              ),
            ),

            const SizedBox(height: 20),
            // Destination Location Dropdown
            SizedBox(
              // width: double.infinity, // Ensures the dropdown matches the parent width
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Destination Location',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                value: selectedDestinationLocation,
                items: locations
                    .map(
                      (location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDestinationLocation = value;
                  });
                },
                menuMaxHeight: 200,
                isExpanded: false, // Ensures menu matches dropdown width
              ),
            ),
            const SizedBox(height: 20),
            // Bus Types Checkboxes
            const Text(
              'Select Bus Types:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: busTypes.map((busType) {
                return CheckboxListTile(
                  title: Text(busType),
                  value: selectedBusTypes[busType],
                  onChanged: (value) {
                    setState(() {
                      selectedBusTypes[busType] = value ?? false;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppPallete.gradient1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _searchBuses,
                child: const Text(
                  "Search",
                  style: TextStyle(
                    color: AppPallete.whiteColor,
                    fontWeight: FontWeight.bold,
                  ), // Ensure text is visible
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

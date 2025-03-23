import 'package:flutter/material.dart';
import 'package:frontend/Pages/Users/Buses/find_bus.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/core/constants/constant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? id;

  List<String> locations = [];
  List<String> busTypes = [];

  bool _isLoadingLocations = true; // For showing a loader if needed
  bool _isLoadingBusTypes = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Retrieve the passed arguments
    final arguments = ModalRoute.of(context)!.settings.arguments as Map?;
    setState(() {
      id = arguments?['id'];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Fetch locations from API
    _fetchBusTypes();
  }

  String? selectedStartLocation;
  String? selectedDestinationLocation;
  final Map<String, bool> selectedBusTypes = {
    'Ordinary': false,
    'Fast': false,
    'Super Fast': false,
    'Swift': false,
  };

  // Fetch locations from API
  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('$url/locations'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); 
        // Assuming the response is something like ["Aanakkampoyil", "Angamaly", ...]
        if (data is List) {
          setState(() {
            locations = data.map((e) => e.toString()).toList();
            _isLoadingLocations = false;
          });
        } else {
          // Handle unexpected response structure
          setState(() {
            _isLoadingLocations = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid response from server')),
          );
        }
      } else {
        // Handle non-200 response
        setState(() {
          _isLoadingLocations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations')),
        );
      }
    } catch (e) {
      // Handle exception
      setState(() {
        _isLoadingLocations = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching locations: $e')),
      );
    }
  }

  // Fetch bus types from API
  Future<void> _fetchBusTypes() async {
    try {
      final response = await http.get(Uri.parse('$url/bus_types'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            busTypes = data.map((e) => e.toString()).toList();
            _isLoadingBusTypes = false;
          });
        } else {
          setState(() => _isLoadingBusTypes = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid response for bus types')),
          );
        }
      } else {
        setState(() => _isLoadingBusTypes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bus types')),
        );
      }
    } catch (e) {
      setState(() => _isLoadingBusTypes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bus types: $e')),
      );
    }
  }

  void _searchBuses() async {
    if (selectedStartLocation == null || selectedDestinationLocation == null) {
      // Show an error if locations are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both start and destination locations.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if at least one bus type is selected
    final selectedBusTypeKeys = selectedBusTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedBusTypeKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one bus type.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare data
    final data = {
      'startLocation': selectedStartLocation,
      'destinationLocation': selectedDestinationLocation,
      'busTypes': selectedBusTypeKeys,
    };

    try {
      // Send POST request to Flask API
      final response = await http.post(
        Uri.parse('$url/findbus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Parse response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> buses = jsonResponse['buses'];

        // Navigate to FindBusPage with results
        if (buses.isNotEmpty) {
          // Successfully fetched buses
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FindBusPage(buses: buses, userStartingLocation: selectedStartLocation ?? ''),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No buses found for the selected criteria.')),
          );
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching buses: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle connection error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to the server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to handle location selection
  Future<void> _selectLocation(String locationType) async {
    final selectedLocation = await showSearch<String>(
      context: context,
      delegate: LocationSearchDelegate(locations),
    );

    if (selectedLocation != null) {
      setState(() {
        if (locationType == 'start') {
          if (selectedLocation != ''){
            selectedStartLocation = selectedLocation;
          }
        } else {
          if (selectedLocation != ''){
            selectedDestinationLocation = selectedLocation;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient, // Applying theme gradient
          ),
        ),
        elevation: 5, // Adds subtle depth
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Smooth bottom edges
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          tooltip: 'Home',
          onPressed: () {
            Navigator.pushNamed(context, '/home', arguments: {'id': id,});
          },
        ),
        title: const Text(
          'EvoRoute',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontSize: 38,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white, // Ensuring visibility
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String choice) {
              if (choice == 'Settings') {
                Navigator.pushNamed(
                  context, 
                  '/settings', 
                  arguments: {
                    'id': id,
                  },
                );
              } else if (choice == 'Logout') {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                // const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 14, color: Colors.redAccent),
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingLocations || _isLoadingBusTypes
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Let's Find Your Bus...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    ListTile(
                      title: Text(
                        selectedStartLocation ?? 'Select Starting Location',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.search, color: Colors.white),
                      onTap: () => _selectLocation('start'),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppPallete.gradient2, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ListTile(
                      title: Text(
                        selectedDestinationLocation ?? 'Select Destination Location',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.search, color: Colors.white),
                      onTap: () => _selectLocation('destination'),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppPallete.gradient2, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Select Bus Types:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: busTypes.map((busType) {
                        return CheckboxListTile(
                          title: Text(busType),
                          value: selectedBusTypes[busType] ?? false,
                          onChanged: (value) {
                            setState(() {
                              selectedBusTypes[busType] = value ?? false;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.darkThemeGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.all(16),
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
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

// Search delegate for location search
class LocationSearchDelegate extends SearchDelegate<String> {
  final List<String> locations;

  LocationSearchDelegate(this.locations);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = locations
        .where((location) => location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results.map<Widget>((location) {
        return ListTile(
          title: Text(location),
          onTap: () {
            close(context, location);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = locations
        .where((location) => location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions.map<Widget>((location) {
        return ListTile(
          title: Text(location),
          onTap: () {
            close(context, location);
          },
        );
      }).toList(),
    );
  }
}

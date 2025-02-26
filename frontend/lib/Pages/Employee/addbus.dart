import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/core/constants/constant.dart';

class AddBusPage extends StatefulWidget {
  const AddBusPage({super.key});

  @override
  _AddBusPageState createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Bus Number, Start Time and Reach Time
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _reachTimeController = TextEditingController();

  String? startingLocation;
  String? destinationLocation;
  String? selectedBusType; // Variable for selected bus type
  List<String> stopLocations = ['']; // Ensure at least one stop location is visible initially
  List<String> stopKMs = ['']; // Corresponding KM values for each stop

  List<String> locations = [];
  List<String> busTypes = [];

  bool _isLoadingLocations = true; // For showing a loader if needed
  bool _isLoadingBusTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Fetch locations from API
    _fetchBusTypes();
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _startTimeController.dispose();
    _reachTimeController.dispose();
    super.dispose();
  }

  // Fetch locations from API
  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('http://$IP:$PORT/locations'));
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
      final response = await http.get(Uri.parse('http://$IP:$PORT/bus_types'));
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

  // Function to add a bus
  Future<void> _addBus() async {
    // Validate that all required fields are filled.
    if (_busNumberController.text.isEmpty ||
        startingLocation == null ||
        destinationLocation == null ||
        selectedBusType == null ||
        stopLocations.isEmpty ||
        stopLocations.any((stop) => stop.isEmpty) ||
        stopKMs.isEmpty ||
        stopKMs.any((km) => km.isEmpty) ||
        _startTimeController.text.isEmpty ||
        _reachTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields and select all locations'))
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://$IP:$PORT/addbus'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bus_number': _busNumberController.text,
        'starting_location': startingLocation,
        'destination_location': destinationLocation,
        'bus_type': selectedBusType,
        'stop_locations': stopLocations,
        'stop_kms': stopKMs,
        'start_time': _startTimeController.text,
        'reach_time': _reachTimeController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bus added successfully')));
      Navigator.pushNamed(context, '/employee');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add bus')));
    }
  }

  // Function to add a stop
  void _addStop() {
    setState(() {
      stopLocations.add('');
      stopKMs.add('');
    });
  }

  // Function to handle stop location selection
  void _selectStopLocation(int index) async {
    final selected = await showSearch<String>(
      context: context,
      delegate: LocationSearchDelegate(locations),
    );
    if (selected != null) {
      setState(() {
        stopLocations[index] = selected;
      });
    }
  }

  // Function to remove a stop location
  void _removeStop(int index) {
    setState(() {
      stopLocations.removeAt(index);
      stopKMs.removeAt(index);
    });
  }

  // Validator for the time fields to ensure they are in 12-hour format
  String? _validateTime(String? value) {
    final timeRegExp = RegExp(r'^(0?[1-9]|1[0-2]):([0-5][0-9])\s?(AM|PM)$');
    if (value == null || value.isEmpty) {
      return 'Please enter a time';
    } else if (!timeRegExp.hasMatch(value)) {
      return 'Please enter a valid time (hh:mm AM/PM)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Bus'),
        backgroundColor: AppPallete.gradient1,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingLocations && _isLoadingBusTypes
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Bus Number field
                    TextFormField(
                      controller: _busNumberController,
                      decoration: InputDecoration(
                        labelText: 'Bus Number',
                        labelStyle: AppPallete.whiteText,
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.gradient2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.gradient3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter Bus Number';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Start location searchable dropdown
                    ListTile(
                      title: Text(startingLocation ?? 'Select Starting Location', style: AppPallete.whiteText),
                      trailing: Icon(Icons.search, color: AppPallete.whiteColor),
                      onTap: () async {
                        final selected = await showSearch<String>(
                          context: context,
                          delegate: LocationSearchDelegate(locations),
                        );
                        if (selected != null && selected != '') {
                          setState(() {
                            startingLocation = selected;
                          });
                        }
                      },
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppPallete.gradient2, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Bus Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedBusType,
                      decoration: InputDecoration(
                        labelText: 'Select Bus Type',
                        labelStyle: AppPallete.whiteText,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.gradient2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: busTypes.map((busType) {
                        return DropdownMenuItem<String>(
                          value: busType,
                          child: Text(busType, style: AppPallete.whiteText),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBusType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a bus type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Stop locations list with KM field and delete button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stop Locations', style: AppPallete.whiteText),
                        SizedBox(height: 8),
                        ...List.generate(stopLocations.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                // Select Stop Location Container
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () => _selectStopLocation(index),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppPallete.gradient2, width: 1.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              stopLocations[index].isEmpty ? 'Select Stop Location' : stopLocations[index],
                                              style: AppPallete.whiteText,
                                            ),
                                          ),
                                          Icon(Icons.search, color: AppPallete.whiteColor),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                // KM Text Field
                                Container(
                                  width: 62,
                                  child: TextFormField(
                                    initialValue: stopKMs[index],
                                    decoration: InputDecoration(
                                      labelText: 'KM',
                                      labelStyle: AppPallete.whiteText,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: AppPallete.gradient2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: AppPallete.gradient3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      stopKMs[index] = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Enter KM';
                                      if (int.tryParse(value) == null) return 'Enter a valid number';
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Delete Button
                                IconButton(
                                  icon: Icon(Icons.delete, color: AppPallete.whiteColor),
                                  onPressed: () => _removeStop(index),
                                ),
                              ],
                            ),
                          );
                        }),
                        SizedBox(height: 16),
                        // "Add More Stops" Button
                        InkWell(
                          onTap: _addStop,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: AppPallete.gradient2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Add More Stops',
                                style: AppPallete.whiteText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Destination location searchable dropdown
                    ListTile(
                      title: Text(destinationLocation ?? 'Select Destination Location', style: AppPallete.whiteText),
                      trailing: Icon(Icons.search, color: AppPallete.whiteColor),
                      onTap: () async {
                        final selected = await showSearch<String>(
                          context: context,
                          delegate: LocationSearchDelegate(locations),
                        );
                        if (selected != null && selected != '') {
                          setState(() {
                            destinationLocation = selected;
                          });
                        }
                      },
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppPallete.gradient2, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Start Time and Reach Time in one row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      // Dark ColorScheme
                                      colorScheme: ColorScheme.dark(
                                        primary: Colors.blue,  // Purple accent
                                        onSurface: Colors.white,     // White text on dark
                                        surface: Color(0xFF1E1E1E),  // Dialog background
                                      ),
                                      // TimePicker-specific theming
                                      timePickerTheme: TimePickerThemeData(
                                        dialBackgroundColor: Color(0xFF1E1E1E),
                                        dialHandColor: Colors.blue,
                                        hourMinuteTextColor: Colors.white,
                                        hourMinuteShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        dayPeriodTextColor: Colors.white,
                                        dayPeriodShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      // Global text styles
                                      textTheme: TextTheme(
                                        bodyMedium: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                // Convert pickedTime to "hh:mm AM/PM"
                                final now = DateTime.now();
                                final dt = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                final formattedTime =
                                    TimeOfDay.fromDateTime(dt).format(context); // e.g. "09:15 AM"

                                setState(() {
                                  // Assign to your controller or variable
                                  _startTimeController.text = formattedTime;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _startTimeController,
                                decoration: InputDecoration(
                                  labelText: 'Start Time',
                                  labelStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                                  ),
                                ),
                                // Optional validation
                                validator: _validateTime,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Reach Time
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      // Dark ColorScheme
                                      colorScheme: ColorScheme.dark(
                                        primary: Colors.blue,  // Purple accent
                                        onSurface: Colors.white,     // White text on dark
                                        surface: Color(0xFF1E1E1E),  // Dialog background
                                      ),
                                      // TimePicker-specific theming
                                      timePickerTheme: TimePickerThemeData(
                                        dialBackgroundColor: Color(0xFF1E1E1E),
                                        dialHandColor: Colors.blue,
                                        hourMinuteTextColor: Colors.white,
                                        hourMinuteShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        dayPeriodTextColor: Colors.white,
                                        dayPeriodShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      // Global text styles
                                      textTheme: TextTheme(
                                        bodyMedium: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                final now = DateTime.now();
                                final dt = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                final formattedTime =
                                    TimeOfDay.fromDateTime(dt).format(context); // e.g. "10:20 PM"

                                setState(() {
                                  _reachTimeController.text = formattedTime;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _reachTimeController,
                                decoration: InputDecoration(
                                  labelText: 'Reach Time',
                                  labelStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                                  ),
                                ),
                                validator: _validateTime,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Add Bus Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _addBus();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Text('Add Bus', style: AppPallete.whiteText),
                    ),
                  ],
                ),
              ),
      ),
      backgroundColor: AppPallete.backgroundColor, // Dark background for the page
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

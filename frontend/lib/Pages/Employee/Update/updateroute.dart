import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/core/constants/constant.dart';
import 'package:intl/intl.dart';

class UpdateRoutePage extends StatefulWidget {
  final Map<String, dynamic> busData;
  const UpdateRoutePage({super.key, required this.busData});

  @override
  _UpdateRoutePageState createState() => _UpdateRoutePageState();
}

class _UpdateRoutePageState extends State<UpdateRoutePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Bus Number, Start Time and Reach Time
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _reachTimeController = TextEditingController();
  final TextEditingController _destinationKMController = TextEditingController();

  String? routeId;
  String? startingLocation;
  String? destinationLocation;
  String? selectedBusType; // Variable for selected bus type
  List<String> stopLocations = ['']; // Ensure at least one stop location is visible initially
  List<String> stopKMs = ['']; // Corresponding KM values for each stop

  List<String> locations = [];
  List<String> busTypes = [];
  List<String> selectedDays = [];

  bool _isLoadingLocations = true; // For showing a loader if needed
  bool _isLoadingBusTypes = true;

  final List<String> allDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  String _formatTime(String time) {
    final parsedTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(time, true);
    final istTime = parsedTime.add(Duration(hours: 5, minutes: 30));
    return DateFormat('hh:mm a').format(istTime);
  }

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Fetch locations from API
    _fetchBusTypes();
    _busNumberController.text = widget.busData['bus_no'] ?? '';
    _startTimeController.text = _formatTime(widget.busData['start_time']);
    _reachTimeController.text = _formatTime(widget.busData['reach_time']);
    _destinationKMController.text = widget.busData['destination_km'] ?? '';

    routeId = widget.busData["_id"];
    startingLocation = widget.busData['starting_location'];
    destinationLocation = widget.busData['destination_location'];
    selectedBusType = widget.busData['bus_type'];

    stopLocations = List<String>.from(widget.busData['stop_locations'] ?? []);
    stopKMs = List<String>.from(widget.busData['stop_kms'] ?? []);

    selectedDays = List<String>.from(widget.busData['days'] ?? []);
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _startTimeController.dispose();
    _reachTimeController.dispose();
    _destinationKMController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
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
            SnackBar(content: Text('Invalid response from server')),
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
        _reachTimeController.text.isEmpty ||
        selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields and select all locations'))
      );
      return;
    }
    try{
      final response = await http.put(
        Uri.parse('$url/updateroute'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': routeId,
          'bus_number': _busNumberController.text,
          'starting_location': startingLocation,
          'destination_location': destinationLocation,
          'destination_km': _destinationKMController.text,
          'bus_type': selectedBusType,
          'stop_locations': stopLocations,
          'stop_kms': stopKMs,
          'start_time': _startTimeController.text,
          'reach_time': _reachTimeController.text,
          'days': selectedDays,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar(responseBody['message'] ?? 'Route updated successfully', Colors.green);
        Navigator.pushNamed(context, '/employee');
      } else if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'No changes found')));
        //Navigator.pushNamed(context, '/employee');
      }else {
        _showSnackBar(responseBody['error'] ?? 'Failed to update route', Colors.red);
      }

    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
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
        centerTitle: true,
        elevation: 8, // Adds depth
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.update_outlined, color: Colors.white, size: 26), // Bus icon
            SizedBox(width: 8),
            Text(
              'Update Route Entry',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingLocations && _isLoadingBusTypes
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Bus Number field
                    SizedBox(height: 6),
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

                    // Days of the Week Selection (Trip Days)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Trip Days', style: AppPallete.whiteText),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: allDays.map((day) {
                            final isSelected = selectedDays.contains(day);
                            return ChoiceChip(
                              label: Text(day,
                                  style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white)),
                              selected: isSelected,
                              selectedColor: AppPallete.gradient3,
                              backgroundColor: AppPallete.gradient2,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedDays.add(day);
                                  } else {
                                    selectedDays.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (selectedDays.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Please select at least one day',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
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
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (value) {
                                      stopKMs[index] = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Enter KM';
                                      if (double.tryParse(value) == null) return 'Enter a valid number';
                                      if (double.parse(value) <= 0) return 'Enter a positive number';
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
                            padding: EdgeInsets.symmetric(vertical: 8.0),
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

                    Row(
                      children: [
                        Expanded(
                          flex: 3, // Adjusting width for destination field
                          child: ListTile(
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
                        ),
                        SizedBox(width: 8), // Space between fields
                        Container(
                          width: 62, // Fixed width for KM field
                          child: TextFormField(
                            controller: _destinationKMController,
                            style: AppPallete.whiteText,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'KM',
                              labelStyle: AppPallete.whiteText,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppPallete.gradient2, width: 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppPallete.gradient3, width: 2.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Enter KM';
                              if (double.tryParse(value) == null) return 'Enter a valid number';
                              if (double.parse(value) <= 0) return 'Enter a positive number';
                              return null;
                            },
                          ),
                        ),
                      ],
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

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.darkThemeGradient,
                        // gradient: LinearGradient(
                        //   colors: [Color(0xFFBB86FC), Color(0xFF3700B3)],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _addBus();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        child: Text(
                          'Update Bus Route',
                          style: AppPallete.whiteText.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
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

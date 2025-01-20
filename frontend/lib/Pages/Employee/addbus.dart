import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBusPage extends StatefulWidget {
  const AddBusPage({super.key});

  @override
  _AddBusPageState createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _startTimeController = TextEditingController();

  String? startingLocation;
  String? destinationLocation;
  String? selectedBusType; // Variable for selected bus type
  List<String> stopLocations = ['']; // Ensuring one stop location is visible initially

  // List of locations
  final List<String> locations = ['Aanakkampoyil', 'Angamaly', 'Areekode', 'Bharananganam', 'Chalakudy', 'Elappara', 'Erattupetta', 'Kattappana', 'Koothattukulam', 'Kunnamkulam', 'Manjeri', 'Mukkam', 'Muvattupuzha', 'Pala', 'Pattambi', 'Peramangalam', 'Perinthalmanna', 'Perumbavoor', 'Puthukad', 'Thiruvambady', 'Thrissur', 'Vagamon', 'Adimali', 'Adoor', 'Alappuzha', 'Aluva', 'Anachal', 'Attingal', 'Ayoor', 'Bangalore', 'Chadayamangalam', 'Changanassery', 'Changaramkulam ', 'Chengannur', 'Cherthala', 'Chinnar ', 'Edappal', 'Ernakulam', 'Ettumanoor', 'Haripad', 'Kallar', 'Kalpetta', 'Kannur', 'Kanthalloor', 'Karunagappalli', 'Kayamkulam', 'Kilimanoor', 'Kollam', 'Kothamangalam', 'Kottakkal', 'Kottarakkara', 'Kottayam', 'Koyilandy', 'Kozhikode', 'Kozhikode University', 'Kudiyanmala', 'Kuravilangad', 'Kuttipuram', 'Marayoor', 'Mavelikara', 'Munnar', 'Mysore', 'Neyyattinkara', 'Palakkayam Thattu', 'Palani', 'Pandalam', 'Sultan Bathery', 'Taliparamba', 'Thalassery', 'Thamarassery', 'Thiruvalla', 'Thodupuzha', 'Trivandrum', 'Udumalaipettai', 'Vadakara', 'Valanchery ', 'Vattappara', 'Venjarammoodu', 'Vytilla Hub', 'Adivaram', 'Ambalapuzha', 'Anchal', 'Chathannoor', 'Erumeli', 'Guruvayoor', 'Kakkad', 'Kanjirappally', 'Kodungallur', 'Konni', 'Kozhenchery', 'Kulathupuzha', 'Madathara', 'Mananthavady', 'Mannarkkad', 'Meenangadi', 'Nedumangad', 'Padinjarathara', 'Palakkad', 'Palode', 'Paravoor North', 'Pathanamthitta', 'Pathanapuram', 'Peroorkada', 'Punalur', 'Ranny', 'Shoranur', 'Thenmala', 'Triprayar', 'Vadanappally', 'Vythiri', 'Wadakkanchery', 'Alakode', 'Alathur', 'Alur', 'Amrita Hospital', 'Aryanad', 'Atholy', 'Charummood', 'Cheruthoni', 'Chettikulangara ', 'Chingavanam', 'Chittoor', 'Choondal', 'Cochin University', 'Coimbatore', 'Edappally', 'Eramalloor', 'Gudalur', 'Idukki', 'Irinjalakuda', 'Kaduthuruthy', 'Kalavoor', 'Kaliyakkavilai', 'Kanhangad', 'Kanyakumari', 'Kasargode', 'Kattakada', 'Kazhakkoottam', 'Kollur', 'kottiyam', 'Kulamavu', 'Kumily', 'Kundara', 'Kuttikkanam', 'Kuttiyadi', 'Kuzhalmannam', 'Mangalore', 'Mannuthy', 'Moolamattom', 'Mundakkayam', 'Nadathara', 'Naduvattam', 'Nagercoil', 'Nedumbassery South', 'Nedumkandam', 'Nilakkal', 'Nilambur', 'Nilamel', 'Ooty', 'Painavu', 'Pamba', 'Panamaram', 'Panjikkal', 'Pappanamcode', 'Parassala', 'Paravur', 'Pattikkad', 'Payyanur', 'Peerumedu', 'Perambra', 'Perikkalloor', 'Piravom', 'Ponkunnam', 'Ponnani', 'Pulpally ', 'Salem', 'Senkottai', 'Shenkottai', 'Sullia', 'Thenkasi', 'Thottilpalam', 'Thrippunithura', 'Tirunelveli', 'Tirur', 'Udayagiri', 'Udupi', 'Vadakkencherry', 'Vadaserikara ', 'Vaikom', 'Valakom', 'Vandiperiyar', 'Vannappuram', 'Vembayam', 'Agali', 'Anaikatti', 'Bandhaduka', 'Cherupuzha', 'Chittarikkal ', 'Konnakad', 'Odayanchal', 'Panathur', 'Poovam', 'Rajapuram', 'Vellarikundu ', 'Annamanada', 'Attukal', 'Balaramapuram', 'Edathva ', 'Hosur', 'Kadalundi Kadavu', 'Kalamassery', 'Kaniyapuram', 'Mala', 'Malappuram', 'Nedumbassery', 'Niravilpuzha', 'Ottapalam', 'Parappanangadi', 'Pathirippalla', 'Pengamuck', 'Pollachi', 'Poovar', 'Seetha Mount', 'Tanur', 'Thiruvilwamala', 'Varapuzha', 'Vellamunda', 'Vellanad', 'Vizhinjam', 'Mallappally', 'Palakkayam ', 'Tiruppur', 'Azhakiyakavu', 'chavakkad', 'Chelachuvadu', 'cherthala bypass', 'Cumbum', 'Kunnamangalam', 'Mankada', 'Mankamkuzhy', 'Nenmara', 'Neriamangalam', 'Nirmala City', 'Pulamanthole', 'Ramanattukara', 'Aster Medcity', 'Manimala', 'Nedumudy', 'Karette', 'Marthandam', 'Thuckalay', 'Andipatti', 'Madurai', 'Theni', 'Usilampatti', 'Chengalpattu', 'Chennai', 'Iritty', 'Kuthuparamba', 'Mattannur', 'Nadavayal', 'Padichira', 'Pampady', 'Payyavoor', 'Puthunagaram', 'Thalayolaparambu', 'Thanjavur', 'Thavalam', 'Thirunelly', 'Tindivanam', 'Trichy', 'Ulliyeri', 'Velankanni', 'Villupuram', 'Wandoor', 'Arookutty', 'Arthunkal', 'Chellanam', 'Cherai', 'Kangayam', 'Kannamaly', 'Karur', 'Njarackal', 'Athankarai Mosque', 'Koodankulam', 'Athur', 'Cuddalore', 'Karipur', 'Mahe', 'Neyveli', 'Pondicherry', 'Dindigul', 'Gundlupete', 'Mandya', 'Mercara', 'Nadapuram', 'Virajpet', 'Kurinji', 'Vettikavala', 'Thaloor', 'Vazhikkadavu', 'Chandanakampara', 'Sreekandapuram', 'Veliyanad', 'Parippally', 'Chennad', 'Cherambadi', 'Choladi BS', 'Mettupalayam', 'Chullimanoor', 'Kottavasal', 'Coonoor', 'Ukkadam', 'Walayar', 'East Fort City Ride', 'East Fort', 'Karukachal', 'Puthuppally', 'Kaipally', 'Kundapura', 'Karavaloor', 'Vithura', 'Kattikkulam', 'Rajapalayam', 'Kunnonni', 'Munambam', 'Nanjangode', 'Pallickathodu', 'Vellarada', 'Poochakkal', 'Purapuzha', 'Technopark'];

  // List of bus types
  final List<String> busTypes = ['Ordinary', 'Fast', 'Super Fast', 'Swift'];

  @override
  void dispose() {
    _startTimeController.dispose();
    super.dispose();
  }

  // Function to add a bus
  Future<void> _addBus() async {
    // Check if all required fields are filled and at least one stop location is selected
    if (startingLocation == null ||
        destinationLocation == null ||
        stopLocations.isEmpty ||
        stopLocations.any((stop) => stop.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill all required fields and select all locations')));
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/addbus'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'starting_location': startingLocation,
        'destination_location': destinationLocation,
        'stop_locations': stopLocations,
        'start_time': _startTimeController.text,
        'bus_type': selectedBusType, // Send the bus type
      }),
    );

    if (response.statusCode == 201) {
      // Show a success message or do something with the response
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bus added successfully')));
      Navigator.pushNamed(context, '/employee');
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add bus')));
    }
  }

  // Function to add a stop
  void _addStop() {
    setState(() {
      stopLocations.add('');
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
    });
  }

  // Validator for the start time to ensure it's in 12-hour format
  String? _validateTime(String? value) {
    final timeRegExp = RegExp(r'^(0?[1-9]|1[0-2]):([0-5][0-9])\s?(AM|PM)$');
    if (value == null || value.isEmpty) {
      return 'Please enter a start time';
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              SizedBox(height: 16), // Adding gap

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
              SizedBox(height: 16), // Adding gap

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
              SizedBox(height: 16), // Adding gap

              // Stop locations list with the option to add more
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stop Locations', style: AppPallete.whiteText),
                  SizedBox(height: 8), // Adding gap
                  // Ensure at least one stop location is visible
                  ...List.generate(stopLocations.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: ListTile(
                        title: GestureDetector(
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
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: AppPallete.whiteColor),
                          onPressed: () => _removeStop(index),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16), // Adding gap
                  // Always show at least one "Add Stop Location" button
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
              SizedBox(height: 16), // Adding gap

              // Start time input field
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  labelStyle: AppPallete.whiteText,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppPallete.gradient2),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                validator: _validateTime,
              ),
              SizedBox(height: 16), // Adding gap

              // Add bus button
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

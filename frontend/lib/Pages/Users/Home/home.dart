import 'package:flutter/material.dart';
import 'package:frontend/Pages/Users/Buses/find_bus.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> locations = ['Aanakkampoyil', 'Angamaly', 'Areekode', 'Bharananganam', 'Chalakudy', 'Elappara', 'Erattupetta', 'Kattappana', 'Koothattukulam', 'Kunnamkulam', 'Manjeri', 'Mukkam', 'Muvattupuzha', 'Pala', 'Pattambi', 'Peramangalam', 'Perinthalmanna', 'Perumbavoor', 'Puthukad', 'Thiruvambady', 'Thrissur', 'Vagamon', 'Adimali', 'Adoor', 'Alappuzha', 'Aluva', 'Anachal', 'Attingal', 'Ayoor', 'Bangalore', 'Chadayamangalam', 'Changanassery', 'Changaramkulam ', 'Chengannur', 'Cherthala', 'Chinnar ', 'Edappal', 'Ernakulam', 'Ettumanoor', 'Haripad', 'Kallar', 'Kalpetta', 'Kannur', 'Kanthalloor', 'Karunagappalli', 'Kayamkulam', 'Kilimanoor', 'Kollam', 'Kothamangalam', 'Kottakkal', 'Kottarakkara', 'Kottayam', 'Koyilandy', 'Kozhikode', 'Kozhikode University', 'Kudiyanmala', 'Kuravilangad', 'Kuttipuram', 'Marayoor', 'Mavelikara', 'Munnar', 'Mysore', 'Neyyattinkara', 'Palakkayam Thattu', 'Palani', 'Pandalam', 'Sultan Bathery', 'Taliparamba', 'Thalassery', 'Thamarassery', 'Thiruvalla', 'Thodupuzha', 'Trivandrum', 'Udumalaipettai', 'Vadakara', 'Valanchery ', 'Vattappara', 'Venjarammoodu', 'Vytilla Hub', 'Adivaram', 'Ambalapuzha', 'Anchal', 'Chathannoor', 'Erumeli', 'Guruvayoor', 'Kakkad', 'Kanjirappally', 'Kodungallur', 'Konni', 'Kozhenchery', 'Kulathupuzha', 'Madathara', 'Mananthavady', 'Mannarkkad', 'Meenangadi', 'Nedumangad', 'Padinjarathara', 'Palakkad', 'Palode', 'Paravoor North', 'Pathanamthitta', 'Pathanapuram', 'Peroorkada', 'Punalur', 'Ranny', 'Shoranur', 'Thenmala', 'Triprayar', 'Vadanappally', 'Vythiri', 'Wadakkanchery', 'Alakode', 'Alathur', 'Alur', 'Amrita Hospital', 'Aryanad', 'Atholy', 'Charummood', 'Cheruthoni', 'Chettikulangara ', 'Chingavanam', 'Chittoor', 'Choondal', 'Cochin University', 'Coimbatore', 'Edappally', 'Eramalloor', 'Gudalur', 'Idukki', 'Irinjalakuda', 'Kaduthuruthy', 'Kalavoor', 'Kaliyakkavilai', 'Kanhangad', 'Kanyakumari', 'Kasargode', 'Kattakada', 'Kazhakkoottam', 'Kollur', 'kottiyam', 'Kulamavu', 'Kumily', 'Kundara', 'Kuttikkanam', 'Kuttiyadi', 'Kuzhalmannam', 'Mangalore', 'Mannuthy', 'Moolamattom', 'Mundakkayam', 'Nadathara', 'Naduvattam', 'Nagercoil', 'Nedumbassery South', 'Nedumkandam', 'Nilakkal', 'Nilambur', 'Nilamel', 'Ooty', 'Painavu', 'Pamba', 'Panamaram', 'Panjikkal', 'Pappanamcode', 'Parassala', 'Paravur', 'Pattikkad', 'Payyanur', 'Peerumedu', 'Perambra', 'Perikkalloor', 'Piravom', 'Ponkunnam', 'Ponnani', 'Pulpally ', 'Salem', 'Senkottai', 'Shenkottai', 'Sullia', 'Thenkasi', 'Thottilpalam', 'Thrippunithura', 'Tirunelveli', 'Tirur', 'Udayagiri', 'Udupi', 'Vadakkencherry', 'Vadaserikara ', 'Vaikom', 'Valakom', 'Vandiperiyar', 'Vannappuram', 'Vembayam', 'Agali', 'Anaikatti', 'Bandhaduka', 'Cherupuzha', 'Chittarikkal ', 'Konnakad', 'Odayanchal', 'Panathur', 'Poovam', 'Rajapuram', 'Vellarikundu ', 'Annamanada', 'Attukal', 'Balaramapuram', 'Edathva ', 'Hosur', 'Kadalundi Kadavu', 'Kalamassery', 'Kaniyapuram', 'Mala', 'Malappuram', 'Nedumbassery', 'Niravilpuzha', 'Ottapalam', 'Parappanangadi', 'Pathirippalla', 'Pengamuck', 'Pollachi', 'Poovar', 'Seetha Mount', 'Tanur', 'Thiruvilwamala', 'Varapuzha', 'Vellamunda', 'Vellanad', 'Vizhinjam', 'Mallappally', 'Palakkayam ', 'Tiruppur', 'Azhakiyakavu', 'chavakkad', 'Chelachuvadu', 'cherthala bypass', 'Cumbum', 'Kunnamangalam', 'Mankada', 'Mankamkuzhy', 'Nenmara', 'Neriamangalam', 'Nirmala City', 'Pulamanthole', 'Ramanattukara', 'Aster Medcity', 'Manimala', 'Nedumudy', 'Karette', 'Marthandam', 'Thuckalay', 'Andipatti', 'Madurai', 'Theni', 'Usilampatti', 'Chengalpattu', 'Chennai', 'Iritty', 'Kuthuparamba', 'Mattannur', 'Nadavayal', 'Padichira', 'Pampady', 'Payyavoor', 'Puthunagaram', 'Thalayolaparambu', 'Thanjavur', 'Thavalam', 'Thirunelly', 'Tindivanam', 'Trichy', 'Ulliyeri', 'Velankanni', 'Villupuram', 'Wandoor', 'Arookutty', 'Arthunkal', 'Chellanam', 'Cherai', 'Kangayam', 'Kannamaly', 'Karur', 'Njarackal', 'Athankarai Mosque', 'Koodankulam', 'Athur', 'Cuddalore', 'Karipur', 'Mahe', 'Neyveli', 'Pondicherry', 'Dindigul', 'Gundlupete', 'Mandya', 'Mercara', 'Nadapuram', 'Virajpet', 'Kurinji', 'Vettikavala', 'Thaloor', 'Vazhikkadavu', 'Chandanakampara', 'Sreekandapuram', 'Veliyanad', 'Parippally', 'Chennad', 'Cherambadi', 'Choladi BS', 'Mettupalayam', 'Chullimanoor', 'Kottavasal', 'Coonoor', 'Ukkadam', 'Walayar', 'East Fort City Ride', 'East Fort', 'Karukachal', 'Puthuppally', 'Kaipally', 'Kundapura', 'Karavaloor', 'Vithura', 'Kattikkulam', 'Rajapalayam', 'Kunnonni', 'Munambam', 'Nanjangode', 'Pallickathodu', 'Vellarada', 'Poochakkal', 'Purapuzha', 'Technopark'];
  
  final List<String> busTypes = ['Ordinary', 'Fast', 'Super Fast', 'Swift'];

  String? selectedStartLocation;
  String? selectedDestinationLocation;
  final Map<String, bool> selectedBusTypes = {
    'Ordinary': false,
    'Fast': false,
    'Super Fast': false,
    'Swift': false,
  };

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
        Uri.parse('http://127.0.0.1:5000/findbus'),
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
              builder: (context) => FindBusPage(buses: buses),
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
        title: const Text('EvoRoute',style: TextStyle(fontFamily: 'Courier New', fontSize: 42, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
            
           ListTile(
              title: Text(
                selectedStartLocation ?? 'Select Starting Location',  // Default text when no location is selected
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.search, color: Colors.white),
              onTap: () => _selectLocation('start'),  // Trigger selection for starting location
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppPallete.gradient2, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // Destination Location Search Button
            ListTile(
              title: Text(
                selectedDestinationLocation ?? 'Select Destination Location',  // Default text when no location is selected
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.search, color: Colors.white),
              onTap: () => _selectLocation('destination'),  // Trigger selection for destination location
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppPallete.gradient2, width: 1.0),
                borderRadius: BorderRadius.circular(10),
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
                  value: selectedBusTypes[busType] ?? false, // Ensure value is never null
                  onChanged: (value) {
                    setState(() {
                      selectedBusTypes[busType] = value ?? false; // Use false as the default value
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
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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

import csv
import time
from geopy.geocoders import Nominatim

# Initialize the geocoder with a user agent (a brief identifier)
geolocator = Nominatim(user_agent="location_lookup")

# List of locations (add the complete list as provided)
locations = [
    'Aanakkampoyil', 'Angamaly', 'Areekode', 'Bharananganam', 'Chalakudy', 'Elappara',
    'Erattupetta', 'Kattappana', 'Koothattukulam', 'Kunnamkulam', 'Manjeri', 'Mukkam',
    'Muvattupuzha', 'Pala', 'Pattambi', 'Peramangalam', 'Perinthalmanna', 'Perumbavoor',
    'Puthukad', 'Thiruvambady', 'Thrissur', 'Vagamon', 'Adimali', 'Adoor', 'Alappuzha',
    'Aluva', 'Anachal', 'Attingal', 'Ayoor', 'Bangalore', 'Chadayamangalam',
    'Changanassery', 'Changaramkulam', 'Chengannur', 'Cherthala', 'Chinnar', 'Edappal',
    'Ernakulam', 'Ettumanoor', 'Haripad', 'Kallar', 'Kalpetta', 'Kannur', 'Kanthalloor',
    'Karunagappalli', 'Kayamkulam', 'Kilimanoor', 'Kollam', 'Kothamangalam', 'Kottakkal',
    'Kottarakkara', 'Kottayam', 'Koyilandy', 'Kozhikode', 'Kozhikode University',
    'Kudiyanmala', 'Kuravilangad', 'Kuttipuram', 'Marayoor', 'Mavelikara', 'Munnar',
    'Mysore', 'Neyyattinkara', 'Palakkayam Thattu', 'Palani', 'Pandalam',
    'Sultan Bathery', 'Taliparamba', 'Thalassery', 'Thamarassery', 'Thiruvalla',
    'Thodupuzha', 'Trivandrum', 'Udumalaipettai', 'Vadakara', 'Valanchery', 'Vattappara',
    'Venjarammoodu', 'Vytilla Hub', 'Adivaram', 'Ambalapuzha', 'Anchal', 'Chathannoor',
    'Erumeli', 'Guruvayoor', 'Kakkad', 'Kanjirappally', 'Kodungallur', 'Konni',
    'Kozhenchery', 'Kulathupuzha', 'Madathara', 'Mananthavady', 'Mannarkkad', 'Meenangadi',
    'Nedumangad', 'Padinjarathara', 'Palakkad', 'Palode', 'Paravoor North',
    'Pathanamthitta', 'Pathanapuram', 'Peroorkada', 'Punalur', 'Ranny', 'Shoranur',
    'Thenmala', 'Triprayar', 'Vadanappally', 'Vythiri', 'Wadakkanchery', 'Alakode',
    'Alathur', 'Alur', 'Amrita Hospital', 'Aryanad', 'Atholy', 'Charummood',
    'Cheruthoni', 'Chettikulangara', 'Chingavanam', 'Chittoor', 'Choondal',
    'Cochin University', 'Coimbatore', 'Edappally', 'Eramalloor', 'Gudalur', 'Idukki',
    'Irinjalakuda', 'Kaduthuruthy', 'Kalavoor', 'Kaliyakkavilai', 'Kanhangad',
    'Kanyakumari', 'Kasargode', 'Kattakada', 'Kazhakkoottam', 'Kollur', 'kottiyam',
    'Kulamavu', 'Kumily', 'Kundara', 'Kuttikkanam', 'Kuttiyadi', 'Kuzhalmannam',
    'Mangalore', 'Mannuthy', 'Moolamattom', 'Mundakkayam', 'Nadathara', 'Naduvattam',
    'Nagercoil', 'Nedumbassery South', 'Nedumkandam', 'Nilakkal', 'Nilambur', 'Nilamel',
    'Ooty', 'Painavu', 'Pamba', 'Panamaram', 'Panjikkal', 'Pappanamcode', 'Parassala',
    'Paravur', 'Pattikkad', 'Payyanur', 'Peerumedu', 'Perambra', 'Perikkalloor', 'Piravom',
    'Ponkunnam', 'Ponnani', 'Pulpally', 'Salem', 'Senkottai', 'Shenkottai', 'Sullia',
    'Thenkasi', 'Thottilpalam', 'Thrippunithura', 'Tirunelveli', 'Tirur', 'Udayagiri',
    'Udupi', 'Vadakkencherry', 'Vadaserikara', 'Vaikom', 'Valakom', 'Vandiperiyar',
    'Vannappuram', 'Vembayam', 'Agali', 'Anaikatti', 'Bandhaduka', 'Cherupuzha',
    'Chittarikkal', 'Konnakad', 'Odayanchal', 'Panathur', 'Poovam', 'Rajapuram',
    'Vellarikundu', 'Annamanada', 'Attukal', 'Balaramapuram', 'Edathva', 'Hosur',
    'Kadalundi Kadavu', 'Kalamassery', 'Kaniyapuram', 'Mala', 'Malappuram', 'Nedumbassery',
    'Niravilpuzha', 'Ottapalam', 'Parappanangadi', 'Pathirippalla', 'Pengamuck',
    'Pollachi', 'Poovar', 'Seetha Mount', 'Tanur', 'Thiruvilwamala', 'Varapuzha',
    'Vellamunda', 'Vellanad', 'Vizhinjam', 'Mallappally', 'Palakkayam', 'Tiruppur',
    'Azhakiyakavu', 'chavakkad', 'Chelachuvadu', 'cherthala bypass', 'Cumbum',
    'Kunnamangalam', 'Mankada', 'Mankamkuzhy', 'Nenmara', 'Neriamangalam', 'Nirmala City',
    'Pulamanthole', 'Ramanattukara', 'Aster Medcity', 'Manimala', 'Nedumudy', 'Karette',
    'Marthandam', 'Thuckalay', 'Andipatti', 'Madurai', 'Theni', 'Usilampatti',
    'Chengalpattu', 'Chennai', 'Iritty', 'Kuthuparamba', 'Mattannur', 'Nadavayal',
    'Padichira', 'Pampady', 'Payyavoor', 'Puthunagaram', 'Thalayolaparambu', 'Thanjavur',
    'Thavalam', 'Thirunelly', 'Tindivanam', 'Trichy', 'Ulliyeri', 'Velankanni',
    'Villupuram', 'Wandoor', 'Arookutty', 'Arthunkal', 'Chellanam', 'Cherai',
    'Kangayam', 'Kannamaly', 'Karur', 'Njarackal', 'Athankarai Mosque', 'Koodankulam',
    'Athur', 'Cuddalore', 'Karipur', 'Mahe', 'Neyveli', 'Pondicherry', 'Dindigul',
    'Gundlupete', 'Mandya', 'Mercara', 'Nadapuram', 'Virajpet', 'Kurinji',
    'Vettikavala', 'Thaloor', 'Vazhikkadavu', 'Chandanakampara', 'Sreekandapuram',
    'Veliyanad', 'Parippally', 'Chennad', 'Cherambadi', 'Choladi BS', 'Mettupalayam',
    'Chullimanoor', 'Kottavasal', 'Coonoor', 'Ukkadam', 'Walayar', 'East Fort City Ride',
    'East Fort', 'Karukachal', 'Puthuppally', 'Kaipally', 'Kundapura', 'Karavaloor',
    'Vithura', 'Kattikkulam', 'Rajapalayam', 'Kunnonni', 'Munambam', 'Nanjangode',
    'Pallickathodu', 'Vellarada', 'Poochakkal', 'Purapuzha', 'Technopark'
]

# Prepare a list to store the results
results = []

# Iterate through each location, query its coordinates, and pause between requests
for loc in locations:
    # Add ", India" to help refine the search for many of these places
    try:
        location = geolocator.geocode(f"{loc}, India", timeout=10)
    except Exception as e:
        print(f"Error geocoding {loc}: {e}")
        location = None
    if location:
        print(f"{loc}: {location.latitude}, {location.longitude}")
        results.append([loc, location.latitude, location.longitude])
    else:
        print(f"{loc}: Not Found")
        results.append([loc, None, None])
    # To respect the API usage policy, pause for a second between calls
    time.sleep(1)

# Write the results to a CSV file
with open("location_coordinates.csv", "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["Location", "Latitude", "Longitude"])
    writer.writerows(results)

print("CSV file 'location_coordinates.csv' created successfully!")

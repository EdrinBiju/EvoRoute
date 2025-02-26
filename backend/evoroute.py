from flask import Flask, request, jsonify
from flask_cors import CORS
import pymongo
from datetime import datetime, date, timedelta, timezone
import pytz
import random
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from flask import render_template

app = Flask(__name__)

CORS(app)

app.config['DEBUG'] = True

ist = pytz.timezone("Asia/Kolkata")

# Email Configuration
SMTP_SERVER = "smtp.gmail.com" 
SMTP_PORT = 587
EMAIL_SENDER = "evoroutebot@gmail.com"
EMAIL_PASSWORD = "huwj uvaz dmqk ehmz"

mongo = pymongo.MongoClient("mongodb+srv://testofunknown:Abc123@evoroute-database.m2aiy.mongodb.net/?retryWrites=true&w=majority&appName=evoroute-database")
# mongo = pymongo.MongoClient("mongodb://localhost:27017/evoroute")
evodb = mongo.evoroute

def clean_user_data(user):
    user['_id'] = str(user['_id'])
    return user

# Function to send OTP via email and save it in the database
def send_email(username, email):
    otp = str(random.randint(100000, 999999))  # Generate OTP
    expiration_time = datetime.now(timezone.utc) + timedelta(minutes=5)

    # Save OTP in the database
    evodb.otps.update_one(
        {"username": username},
        {"$set": {"otp": otp, "email": email, "expires_at": expiration_time}},
        upsert=True
    )

    with app.app_context():  # Push the application context
        subject = "Email Verification"
        body = render_template('email_template.html', otp=otp)  # Load HTML template

        msg = MIMEMultipart()
    msg["From"] = EMAIL_SENDER
    msg["To"] = email
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "html"))

    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(EMAIL_SENDER, EMAIL_PASSWORD)  # Use App Password here
        server.sendmail(EMAIL_SENDER, email, msg.as_string())
        server.quit()
        return True
    except Exception as e:
        print(f"Failed to send email to {email}: {e}")
        return False
    
@app.route('/')
def check_connection():
   if mongo:
      return("Mongodb connected")
   else: 
      return("Mongodb not connected")

@app.route('/login', methods = ['POST'])
def login():
   data = request.get_json()
   username = data.get('username')
   password = data.get('password')
   user = evodb.user.find_one({'username' : username})

   if not user or user['password'] != password:
        return jsonify({'error': 'Invalid username or password'}), 401
   
   user = clean_user_data(user)

   return jsonify({'type': user['type'], 'success': True}), 200

# API to send OTP (for registration and forgot password)
@app.route('/send-otp', methods=['POST'])
def send_otp():
    data = request.get_json()
    username = data.get("username")
    email = data.get("email")

    if not username:
        return jsonify({"error": "Username is required"}), 400

    user = evodb.user.find_one({"username": username})

    # Registration case: Ensure username and email are unique
    if email:
        if user:
            return jsonify({"error": "Username already exists"}), 400
        existing_email = evodb.user.find_one({"email": email})
        if existing_email:
            return jsonify({"error": "Email already registered"}), 400
    else:
        # Forgot password case: Ensure username exists
        if not user:
            return jsonify({"error": "Username not found"}), 404
        email = user["email"]  # Use the email associated with the username

    if send_email(username, email):
        return jsonify({"message": "OTP sent successfully"}), 200
    else:
        return jsonify({"error": "Failed to send OTP"}), 500

# API to verify OTP
@app.route('/verify-otp', methods=['POST'])
def verify_otp():
    data = request.get_json()
    username = data.get("username")
    email = data.get("email")
    otp = data.get("otp")

    otp_record = evodb.otps.find_one({"username": username, "email": email})

    if not otp_record:
        return jsonify({"error": "Invalid request"}), 400

    if str(otp_record["otp"]) != str(otp):
        return jsonify({"error": "Invalid OTP"}), 400

    if datetime.utcnow() > otp_record["expires_at"]:
        return jsonify({"error": "OTP expired"}), 400

    return jsonify({"message": "OTP verified successfully"}), 200

# API to register user after OTP verification
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")
    email = data.get("email")

    if not (username and password and email):
        return jsonify({"error": "All fields are required"}), 400

    if evodb.user.find_one({"username": username}):
        return jsonify({"error": "Username already exists"}), 400

    evodb.user.insert_one({
        "username": username,
        "password": password,
        "email": email,
        "type": "user"
    })

    return jsonify({"message": "Account created successfully"}), 200

@app.route('/forgot_password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    username = data.get('username')

    if not username:
        return jsonify({"error": "Username is required"}), 400

    # Find user in database
    user = evodb.user.find_one({"username": username})
    if not user:
        return jsonify({"error": "User not found"}), 404

    email = user.get("email")
    
    # Send OTP email
    if send_email(username, email):
        return jsonify({"message": "OTP sent successfully", "email": email}), 200
    else:
        return jsonify({"error": "Failed to send OTP"}), 500

@app.route('/reset-password', methods=['POST'])
def reset_password():
    data = request.get_json()
    username = data.get("username")
    new_password = data.get("new_password")

    if not (username and new_password):
        return jsonify({"error": "Username and new password are required"}), 400

    evodb.user.update_one({"username": username}, {"$set": {"password": new_password}})
    return jsonify({"message": "Password reset successful"}), 200

@app.route('/addbus', methods=['POST'])
def add_bus():
   # Get data from the request
   payload = request.get_json()

   # Validate incoming data
   required_fields = ['starting_location', 'destination_location', 'stop_locations', 'start_time', 'bus_type']
   for field in required_fields:
      if field not in payload:
         return jsonify({'error': f'{field} is required'}), 400

   # Prepare the data for insertion
   bus_data = {
      "bus_no": payload["bus_number"],
      "starting_location": payload["starting_location"],
      "destination_location": payload["destination_location"],
      "destination_km": payload["destination_km"],
      "stop_locations": payload["stop_locations"],
      "stop_kms": payload["stop_kms"],
      "start_time": ist.localize(datetime.combine(date.today(),datetime.strptime(payload["start_time"], "%I:%M %p").time())),
      "reach_time": ist.localize(datetime.combine(date.today(),datetime.strptime(payload["reach_time"], "%I:%M %p").time())),
      "bus_type": payload["bus_type"],
      "days": payload["days"],
   }

   # Insert data into the database
   try:
      result = evodb.bus_routes.insert_one(bus_data)
      return jsonify({"message": "Bus added successfully", "bus_id": str(result.inserted_id)}), 201
   except Exception as e:
      return jsonify({"error": f"An error occurred: {str(e)}"}), 500

@app.route('/findbus', methods=['POST'])
def find_bus():
   data = request.get_json()
   
   start_location = data.get('startLocation')
   destination_location = data.get('destinationLocation')
   bus_types = data.get('busTypes', [])
   
   if not start_location or not destination_location or not bus_types:
      return jsonify({'error': 'Missing required fields'}), 400

   # Query buses
   buses = list(evodb.bus_routes.find({ 
      "$and": [
         # Ensure start_location is in starting_location or stop_locations
         {"$or": [
               {"starting_location": start_location},
               {"stop_locations": start_location}
         ]},
         # Ensure destination_location is in destination_location or stop_locations
         {"$or": [
               {"destination_location": destination_location},
               {"stop_locations": destination_location}
         ]},
         # Filter by bus types
         {"bus_type": {"$in": bus_types}}
      ]
   }))

   filtered_buses = []

   for bus in buses:
      if start_location in bus['stop_locations'] and destination_location in bus['stop_locations']:
         if bus['stop_locations'].index(start_location) >= bus['stop_locations'].index(destination_location):
            continue
         else:
            filtered_buses.append(bus)
      else:
            filtered_buses.append(bus)
   # Prepare response
   for bus in buses:
      bus['_id'] = str(bus['_id'])  # Convert ObjectId to string for JSON serialization

   return jsonify({'buses': filtered_buses}) ,200

@app.route('/locations',methods=['GET'])
def get_locations(): 
   locations = list(evodb.locations.find({}, {"_id": 0, "name": 1}))  # Exclude _id from results
   location_list = [location["name"] for location in locations]  # Extract names
   return jsonify(location_list)

@app.route('/bus_types',methods=['GET'])
def get_types(): 
   bus_types = list(evodb.bus_types.find({}, {"_id": 0, "bus_type": 1}))  # Exclude _id from results
   bus_types_list = [bus_type["bus_type"] for bus_type in bus_types]  # Extract names
   return jsonify(bus_types_list)

@app.route('/allbuses',methods=['POST'])
def all_busses(): 
   pass

if __name__ == '__main__':
   app.run(debug=True, use_reloader=True) 
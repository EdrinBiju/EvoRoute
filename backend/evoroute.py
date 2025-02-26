from flask import Flask, request, jsonify
from flask_cors import CORS
import pymongo
from datetime import datetime

app = Flask(__name__)

CORS(app)

app.config['DEBUG'] = True

mongo = pymongo.MongoClient("mongodb+srv://testofunknown:Abc123@evoroute-database.m2aiy.mongodb.net/?retryWrites=true&w=majority&appName=evoroute-database")
# mongo = pymongo.MongoClient("mongodb://localhost:27017/evoroute")
evodb = mongo.evoroute

def clean_user_data(user):
    user['_id'] = str(user['_id'])
    return user

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

@app.route('/register', methods = ['POST'])
def register():
   data = request.get_json()
   username = data.get('username')
   password = data.get('password')

   check_user = evodb.user.find_one({'username' : username})

   if check_user:
      return "username already exists", 401
   
   user = {
       'username' : username,
       'password' : password,
       'type' : 'user'
   }
   insert = evodb.user.insert_one(user)

   return "Account created", 200

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
      "stop_locations": payload["stop_locations"],
      "stop_kms": payload["stop_kms"],
      "start_time": datetime.strptime(payload["start_time"], "%I:%M %p"),
      "reach_time": datetime.strptime(payload["start_time"], "%I:%M %p"),
      "bus_type": payload["bus_type"]
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
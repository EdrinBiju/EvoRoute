from flask import Flask, request, jsonify
from flask_cors import CORS
import pymongo

app = Flask(__name__)

CORS(app)

app.config['DEBUG'] = True

mongo = pymongo.MongoClient("mongodb+srv://testofunknown:Abc123@evoroute-database.m2aiy.mongodb.net/?retryWrites=true&w=majority&appName=evoroute-database")
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

   return jsonify({'data': user, 'success': True}), 200

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

if __name__ == '__main__':
   app.run(debug=True, use_reloader=True)
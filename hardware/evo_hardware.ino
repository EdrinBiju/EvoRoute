#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

// WiFi credentials
const char* ssid = "404 not found";
const char* password = "parayilla";

// API URL
const char* apiUrl = "http://3.80.100.134:5000/upload_gps";

// Define RX and TX pins for GPS
#define GPS_RX 12  // D5
#define GPS_TX 14  // D6
#define GPS_BAUD 9600

// Define RX and TX pins for SIM800L
#define SIM_RX 5   // D1
#define SIM_TX 4   // D2
#define SIM_BAUD 9600

// TinyGPS++ object
TinyGPSPlus gps;

// SoftwareSerial for GPS
SoftwareSerial gpsSerial(GPS_RX, GPS_TX);

// SoftwareSerial for SIM800L
SoftwareSerial simSerial(SIM_RX, SIM_TX);

// Function to connect to WiFi
void connectWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 20) {
    delay(1000);
    Serial.print(".");
    retries++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi Connection Failed!");
  }
}

// Function to send data over WiFi
bool sendToAPI_WiFi(float lat, float lon, String timestamp) {
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;
    
    String jsonData = "{";
    jsonData += "\"bus_no\":\"KL63B5623\",";
    jsonData += "\"latitude\":" + String(lat, 6) + ",";
    jsonData += "\"longitude\":" + String(lon, 6) + ",";
    jsonData += "\"timestamp\":\"" + timestamp + "\"";
    jsonData += "}";

    Serial.println("Sending JSON over WiFi: " + jsonData);

    http.begin(client, apiUrl);
    http.addHeader("Content-Type", "application/json");

    int httpResponseCode = http.POST(jsonData);
    Serial.print("WiFi HTTP Response code: ");
    Serial.println(httpResponseCode);

    http.end();

    return (httpResponseCode > 0);
  } else {
    Serial.println("WiFi Not Connected! Skipping WiFi API request...");
    return false;
  }
}

// Function to send data over SIM800L (GPRS)
bool sendToAPI_SIM(float lat, float lon, String timestamp) {
  String jsonData = "{";
  jsonData += "\"bus_no\":\"KL63B5623\",";
  jsonData += "\"latitude\":" + String(lat, 6) + ",";
  jsonData += "\"longitude\":" + String(lon, 6) + ",";
  jsonData += "\"timestamp\":\"" + timestamp + "\"";
  jsonData += "}";

  Serial.println("Sending JSON over SIM800L (GPRS): " + jsonData);

  simSerial.println("AT+SAPBR=3,1,\"Contype\",\"GPRS\"");
  delay(1000);
  simSerial.println("AT+SAPBR=3,1,\"APN\",\"your_apn\""); // Replace with your APN
  delay(1000);
  simSerial.println("AT+SAPBR=1,1");
  delay(3000);
  simSerial.println("AT+HTTPINIT");
  delay(1000);
  simSerial.println("AT+HTTPPARA=\"CID\",1");
  delay(1000);
  simSerial.println("AT+HTTPPARA=\"URL\",\"" + String(apiUrl) + "\"");
  delay(1000);
  simSerial.println("AT+HTTPPARA=\"CONTENT\",\"application/json\"");
  delay(1000);

  simSerial.print("AT+HTTPDATA=");
  simSerial.print(jsonData.length());
  simSerial.println(",10000");
  delay(1000);
  simSerial.println(jsonData);
  delay(3000);
  
  simSerial.println("AT+HTTPACTION=1");
  delay(10000);

  simSerial.println("AT+HTTPREAD");
  delay(3000);
  
  return true;
}

void setup() {
  Serial.begin(115200);
  gpsSerial.begin(GPS_BAUD);
  simSerial.begin(SIM_BAUD);

  Serial.println("Starting...");

  connectWiFi(); // Connect to WiFi

  // Initialize SIM800L
  simSerial.println("AT");
  delay(1000);
  simSerial.println("AT+CFUN=1");
  delay(1000);
  simSerial.println("AT+CREG?");
  delay(1000);
  simSerial.println("AT+CGATT=1");
  delay(1000);
}

void loop() {
  unsigned long start = millis();

  while (millis() - start < 1000) {
    while (gpsSerial.available() > 0) {
      gps.encode(gpsSerial.read());
    }
    
    if (gps.location.isUpdated()) {
      float lat = gps.location.lat();
      float lon = gps.location.lng();
      String timestamp = String(gps.date.year()) + "/" + String(gps.date.month()) + "/" + 
                         String(gps.date.day()) + " " + String(gps.time.hour()) + ":" + 
                         String(gps.time.minute()) + ":" + String(gps.time.second());

      Serial.print("LAT: ");
      Serial.println(lat, 6);
      Serial.print("LONG: "); 
      Serial.println(lon, 6);
      Serial.print("SPEED (km/h) = "); 
      Serial.println(gps.speed.kmph()); 
      Serial.print("ALT (min)= "); 
      Serial.println(gps.altitude.meters());
      Serial.print("HDOP = "); 
      Serial.println(gps.hdop.value() / 100.0); 
      Serial.print("Satellites = "); 
      Serial.println(gps.satellites.value()); 
      Serial.print("Time in UTC: ");
      Serial.println(timestamp);
      Serial.println("");

      // First try WiFi
      if (!sendToAPI_WiFi(lat, lon, timestamp)) {
        // If WiFi fails, use SIM800L
        sendToAPI_SIM(lat, lon, timestamp);
      }
    }
  }
}

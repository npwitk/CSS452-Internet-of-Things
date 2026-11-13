#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "Your SSID";
const char* password = "SSID Password";
const char* mqtt_server = "Raspberry Pi's IP";
const int mqtt_port = 1883;
const char* ClientID = "ClientPubSub";
const char* Topic = "/IoT/HomeSensors";
long lastMsg = 0;

WiFiClient ClientNode;
PubSubClient ClientESP(ClientNode);

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());    
  ClientESP.setServer(mqtt_server, mqtt_port); //Set the MQTT server and port.
  ConnectMQTT(); //Connect to the MQTT server.
}

void loop() {
  if (!ClientESP.connected()) {
    ConnectMQTT();
  }  
  long now = millis();
  if (now - lastMsg > 10000) {
    lastMsg = now;
    
    //Sensor Data
    String tempVal = String(random(100)); //Convert numbers to strings
    String humidVal = String(random(100)); 
    String lightVal = String(random(100)); 
    String pmVal = String(random(100));     
   
    //Create JSON payloadout to send to MQTT server
    //Refer to: JSON Style Guide
    String payloadString = "{";
    payloadString += "\"roomname\":";                         
    payloadString += "\"room1\"";
    payloadString += ",";   
    payloadString += "\"temp\":";                         
    payloadString += tempVal;
    payloadString += ",";
    payloadString += "\"humid\":";                         
    payloadString += humidVal;
    payloadString += ",";
    payloadString += "\"light\":";                         
    payloadString += lightVal;
    payloadString += ",";    
    payloadString += "\"pm\":";
    payloadString += pmVal;
    payloadString += "}";

    //Convert a string to char
    char payloadChar[200];   
    payloadString.toCharArray(payloadChar, 200);           
    ClientESP.publish(Topic, payloadChar);
    Serial.print("Pub: ");
    Serial.println(payloadChar);
  }
}

void ConnectMQTT() {
  while (!ClientESP.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect to the broker
    if (ClientESP.connect(ClientID, NULL, NULL)) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(ClientESP.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }  
}

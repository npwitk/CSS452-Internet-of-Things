// CSS452 Practical Final (example) - Q3
// Every 5 seconds, publish 5 random values (0-100) as JSON to the Raspberry Pi's MQTT broker:
//   {"V1":12,"V2":87,"V3":45,"V4":3,"V5":100}
// No circuit. The ESP32 and the Pi must be on the same Wi-Fi.
// Based on Lecture 10's Local_NodeRed_PubNode_JSON.ino.
#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "Your SSID";
const char* password = "SSID Password";
const char* mqtt_server = "Raspberry Pi's IP";     // Wi-Fi IP from: hostname -I
const int mqtt_port = 1883;
const char* ClientID = "ClientFiveValues_YOUR_ID"; // must be unique on the broker
const char* Topic = "/IoT/FiveValues_YOUR_ID";     // same topic as the Node-RED mqtt in node
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
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());

  ClientESP.setServer(mqtt_server, mqtt_port);
  ConnectMQTT();
}

void loop() {
  if (!ClientESP.connected()) {
    ConnectMQTT();
  }
  ClientESP.loop();

  long now = millis();
  if (now - lastMsg > 5000) {          // every 5 seconds
    lastMsg = now;

    // 5 random values between 0 and 100 (random(101) gives 0..100)
    String payloadString = "{";
    for (int i = 1; i <= 5; i++) {
      payloadString += "\"V";
      payloadString += i;
      payloadString += "\":";
      payloadString += random(101);
      if (i < 5) payloadString += ",";
    }
    payloadString += "}";

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
    if (ClientESP.connect(ClientID, NULL, NULL)) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(ClientESP.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

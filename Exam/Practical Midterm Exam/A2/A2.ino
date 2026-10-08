#include <WiFi.h>  // built into the ESP32 board package (nothing to install)
#include <PubSubClient.h>  // INSTALL FIRST: Library Manager -> "PubSubClient" by Nick O'Leary

const int ledPin = 26;  // LED

const char* ssid = "Nonprawich iPhone";  // your hotspot name (2.4 GHz only!)
const char* password = "Googlewifi11";
const char* mqtt_server = "broker.hivemq.com";  // public broker, no username/password
const int mqtt_port = 1883;  // 1883 = plain (unencrypted) MQTT
const char* ClientID = "Client_YourStudentID";  // must be UNIQUE on the broker (two boards = two IDs)
const char* Topic = "IoT2026ExamQ2";  // publisher and subscriber must use the exact same topic

unsigned long lastMsg = 0;  // last publish time

WiFiClient ClientNode;  // TCP connection used by MQTT
PubSubClient ClientESP(ClientNode);  // the MQTT client

void ConnectMQTT() {
  while (!ClientESP.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (ClientESP.connect(ClientID, NULL, NULL)) {  // NULL, NULL = no username/password
      Serial.println("connected");
      ClientESP.subscribe(Topic);  // (re)subscribe after every connect
    } else {
      Serial.print("failed, rc=");
      Serial.print(ClientESP.state());  // -2 = network/broker unreachable, 2 = bad client ID
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void callback(char* topic, byte* payload, unsigned int length) {  // called by ClientESP.loop() for each message
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  String ValString;
  for (int i = 0; i < length; i++) {  // payload is raw bytes, NOT a C string: build a String
    Serial.print((char)payload[i]);
    ValString += (char)payload[i];
  }
  Serial.println();
  if (ValString.equalsIgnoreCase("on")) {  // payload "on" / "off" (any case)
    digitalWrite(ledPin, HIGH);
  } else if (ValString.equalsIgnoreCase("off")) {
    digitalWrite(ledPin, LOW);
  }
}

void setup() {
  Serial.begin(115200);  // must match the Serial Monitor baud rate
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);  // start with LED off
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.mode(WIFI_STA);  // station = join an existing WiFi network
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {  // wait until connected
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());
  ClientESP.setServer(mqtt_server, mqtt_port);  // which broker to use
  ClientESP.setCallback(callback);  // function to run when a message arrives
  ConnectMQTT();
}

void loop() {
  if (!ClientESP.connected()) {  // reconnect if the broker dropped us
    ConnectMQTT();
  }
  ClientESP.loop();  // keeps the connection alive and delivers incoming messages
}

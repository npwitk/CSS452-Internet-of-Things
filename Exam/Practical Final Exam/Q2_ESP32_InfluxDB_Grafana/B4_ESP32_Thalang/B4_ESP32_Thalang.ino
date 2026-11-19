#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "Nonprawich iPhone";
const char* password = "REDACTEDDDD";
const char* mqtt_server = "172.20.10.4";   // the Pi's Wi-Fi IP:  hostname -I
const int mqtt_port = 1883;
const char* ClientID = "ESP32_Thalang";          // must be unique on the broker
const char* Topic = "/IoT/Phuket";               // same topic as the Node-RED mqtt in node
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

  randomSeed(esp_random());
  ClientESP.setServer(mqtt_server, mqtt_port);
  ConnectMQTT();
}

void loop() {
  if (!ClientESP.connected()) {
    ConnectMQTT();
  }
  ClientESP.loop();

  long now = millis();
  if (lastMsg == 0 || now - lastMsg > 10000) {   // every 10 seconds
    lastMsg = now;

    int air  = random(101);   // 0..100
    int wind = random(101);
    int sun  = random(101);

    String payloadString = "{";
    payloadString += "\"Farm\":\"Farm1\",";
    payloadString += "\"Air\":";  payloadString += air;  payloadString += ",";
    payloadString += "\"Wind\":"; payloadString += wind; payloadString += ",";
    payloadString += "\"Sun\":";  payloadString += sun;
    payloadString += "}";

    char payloadChar[200];
    payloadString.toCharArray(payloadChar, 200);
    if (ClientESP.publish(Topic, payloadChar)) {
      Serial.print("Sent to Pi: ");
    } else {
      Serial.print("Publish FAILED: ");
    }
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

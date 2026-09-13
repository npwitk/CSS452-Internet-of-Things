#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "Your SSID";
const char* password = "Your Password";
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 1883;

// ---- THE ONLY BLOCK THAT DIFFERS BETWEEN NODE1 AND NODE2 ----
const char* ClientID  = "Client_Node1_65010001";     // Node2 sketch: "Client_Node2_65010001"
const char* PubTopic  = "IoT/Node1_65010001";         // Node2 sketch: "IoT/Node2_65010001"
const char* SubTopic  = "IoT/Node2_65010001";         // Node2 sketch: "IoT/Node1_65010001"
// ---------------------------------------------------------------

long lastMsg = 0;
WiFiClient ClientNode;
PubSubClient ClientESP(ClientNode);

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println(WiFi.localIP());

  ClientESP.setServer(mqtt_server, mqtt_port);
  ClientESP.setCallback(callback);
  ConnectMQTT();

  pinMode(26, OUTPUT);
  digitalWrite(26, LOW);
}

void loop() {
  if (!ClientESP.connected()) { ConnectMQTT(); }
  ClientESP.loop();

  long now = millis();
  if (now - lastMsg > 2000) {
    lastMsg = now;
    char Val[8];
    dtostrf(analogRead(A0), 1, 0, Val);
    ClientESP.publish(PubTopic, Val);     // publish MY pot value on MY OWN topic
    Serial.print("Pub: "); Serial.println(Val);
  }
}

void ConnectMQTT() {
  while (!ClientESP.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (ClientESP.connect(ClientID, NULL, NULL)) {
      Serial.println("connected");
      ClientESP.setCallback(callback);
      ClientESP.subscribe(SubTopic);      // listen to the OTHER node's topic
    } else {
      Serial.print("failed, rc="); Serial.print(ClientESP.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived ["); Serial.print(topic); Serial.print("] ");
  String ValString;
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
    ValString += (char)payload[i];
  }
  int ValInt = ValString.toInt();
  Serial.print("Sub : "); Serial.println(ValInt);
  if (ValInt > 500) {
    digitalWrite(26, HIGH);   // driven by the OTHER node's pot value
  } else {
    digitalWrite(26, LOW);
  }
}
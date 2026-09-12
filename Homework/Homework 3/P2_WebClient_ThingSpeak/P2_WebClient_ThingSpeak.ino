#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid     = "npwitk";
const char* password = "aisfibre2010";

String apiKey = "5DKZTHVUI6O82D1V";
const char* server = "http://api.thingspeak.com/update";

const int potPin = 36;

void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    int potValue = analogRead(potPin);
    int randNumber = random(0, 100);

    String url = String(server) + "?api_key=" + apiKey +
                 "&field1=" + String(potValue) +
                 "&field2=" + String(randNumber);

    http.begin(url);
    int httpResponseCode = http.GET();

    if (httpResponseCode > 0) {
      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
    } else {
      Serial.print("Error sending data. Code: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("WiFi Disconnected");
  }

  delay(10000);
}

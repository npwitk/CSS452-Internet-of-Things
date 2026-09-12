#include <WiFi.h>

const int touchPin = 32;   // wire attached here

void setup() {
  Serial.begin(115200);
  Serial.println();

  // Task 1: connect to WiFi and show IP address
  WiFi.mode(WIFI_STA);
  WiFi.begin("Your_SSID", "Your_Password");
  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  // Task 2: if the wire is touched, restart the ESP32
  int touchValue = touchRead(touchPin);
  if (touchValue < 20) {          // threshold — tune based on testing (untouched ~30+, touched single digits)
    Serial.println("Touched! Restarting...");
    ESP.restart();
  }
  delay(200);
}
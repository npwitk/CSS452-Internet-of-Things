#include <WiFi.h>  // built into the ESP32 board package (nothing to install)

const int potPin = A5;  // potentiometer wiper: GPIO33 · A5 · ADC1 ch5 · touch T8
const int ledPin = 26;  // LED
const int output16 = 16;
const int output17 = 17;

const char* ssid = "Nonprawich iPhone";  // your hotspot name (2.4 GHz only!)
const char* password = "Googlewifi11";
WiFiServer server(80);  // HTTP uses port 80

String header;  // stores the HTTP request text
String output16State = "off";
String output17State = "off";
unsigned long currentTime = millis();
unsigned long previousTime = 0;
const long timeoutTime = 2000;  // drop a client after 2 s

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
  Serial.println(WiFi.localIP());  // type this IP into the browser
  pinMode(output16, OUTPUT);
  digitalWrite(output16, LOW);  // start off
  pinMode(output17, OUTPUT);
  digitalWrite(output17, LOW);  // start off
  server.begin();  // start listening for browsers
}

void loop() {
  if (analogRead(potPin) > 750) {  // knob past the threshold?
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  }
  WiFiClient client = server.available();  // did a browser connect?
  if (client) {
    currentTime = millis();
    previousTime = currentTime;
    Serial.println("New Client.");
    String currentLine = "";  // the line of the request we are reading now
    while (client.connected() && currentTime - previousTime <= timeoutTime) {
      currentTime = millis();
      if (client.available()) {
        char c = client.read();  // read the request one character at a time
        Serial.write(c);
        header += c;
        if (c == '\n') {
          if (currentLine.length() == 0) {  // empty line = end of the request, so reply now
            client.println("HTTP/1.1 200 OK");  // status line
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();  // blank line separates headers from the page
            if (header.indexOf("GET /16/on") >= 0) {  // which button was clicked? look for it in the request
              Serial.println("GPIO 16 on");
              output16State = "on";
              digitalWrite(output16, HIGH);
            } else if (header.indexOf("GET /16/off") >= 0) {
              Serial.println("GPIO 16 off");
              output16State = "off";
              digitalWrite(output16, LOW);
            } else if (header.indexOf("GET /17/on") >= 0) {
              Serial.println("GPIO 17 on");
              output17State = "on";
              digitalWrite(output17, HIGH);
            } else if (header.indexOf("GET /17/off") >= 0) {
              Serial.println("GPIO 17 off");
              output17State = "off";
              digitalWrite(output17, LOW);
            }
            client.println("<!DOCTYPE html><html>");
            client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            client.println("<link rel=\"icon\" href=\"data:,\">");
            client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");
            client.println(".button { background-color: #4CAF50; border: none; color: white; padding: 16px 40px;");
            client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            client.println(".button2 {background-color: #555555;}");
            client.println("</style></head>");
            client.println("<body><h1>ESP32 Web Server</h1>");
            client.println("<p>LED2 - State " + output16State + "</p>");
              client.println("<p><a href=\"/16/on\"><button class=\"button\">ON</button></a></p>");
              client.println("<p><a href=\"/16/off\"><button class=\"button button2\">OFF</button></a></p>");
            client.println("<p>LED3 - State " + output17State + "</p>");
              client.println("<p><a href=\"/17/on\"><button class=\"button\">ON</button></a></p>");
              client.println("<p><a href=\"/17/off\"><button class=\"button button2\">OFF</button></a></p>");
            client.println("</body></html>");
            client.println();  // response ends with another blank line
            break;
          } else {
            currentLine = "";
          }
        } else if (c != '\r') {
          currentLine += c;
        }
      }
    }
    header = "";  // clear for the next request
    client.stop();
    Serial.println("Client disconnected.");
    Serial.println("");
  }
}


// please trobuleshoot this code make dedicate on and off button for each switch
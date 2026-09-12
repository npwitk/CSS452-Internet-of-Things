#include <WiFi.h>

const char* ssid     = "npwitk";
const char* password = "aisfibre2010";

WiFiServer server(80);

String header;

const int output16 = 16;
const int output17 = 17;
const int output32 = 32;

String output16State = "off";
String output17State = "off";
String output32State = "off";

void setup() {
  Serial.begin(115200);

  pinMode(output16, OUTPUT);
  pinMode(output17, OUTPUT);
  pinMode(output32, OUTPUT);
  digitalWrite(output16, HIGH);
  digitalWrite(output17, HIGH);
  digitalWrite(output32, HIGH);

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

  server.begin();
}

void loop() {
  WiFiClient client = server.available();

  if (client) {
    Serial.println("New Client.");
    String currentLine = "";
    header = "";

    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        header += c;

        if (c == '\n') {
          if (currentLine.length() == 0) {

            if (header.indexOf("GET /16/on") >= 0) {
              output16State = "on";
              digitalWrite(output16, LOW);
            } else if (header.indexOf("GET /16/off") >= 0) {
              output16State = "off";
              digitalWrite(output16, HIGH);
            } else if (header.indexOf("GET /17/on") >= 0) {
              output17State = "on";
              digitalWrite(output17, LOW);
            } else if (header.indexOf("GET /17/off") >= 0) {
              output17State = "off";
              digitalWrite(output17, HIGH);
            } else if (header.indexOf("GET /32/on") >= 0) {
              output32State = "on";
              digitalWrite(output32, LOW);
            } else if (header.indexOf("GET /32/off") >= 0) {
              output32State = "off";
              digitalWrite(output32, HIGH);
            }

            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();

            client.println("<!DOCTYPE html><html>");
            client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            client.println("<link rel=\"icon\" href=\"data:,\">");

            client.println("<style>");
            client.println("html { font-family: Helvetica; display: block; margin: 0px auto; text-align: center;}");
            client.println(".button { background-color: #4CAF50; border: none; color: white; padding: 16px 40px;");
            client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            client.println(".button2 { background-color: #555555; }");
            client.println("</style>");
            client.println("</head>");

            client.println("<body>");
            client.println("<h1>ESP32 Web Server</h1>");

            client.println("<p>GPIO 16 - State " + output16State + "</p>");
            if (output16State == "off") {
              client.println("<p><a href=\"/16/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/16/off\"><button class=\"button button2\">OFF</button></a></p>");
            }

            client.println("<p>GPIO 17 - State " + output17State + "</p>");
            if (output17State == "off") {
              client.println("<p><a href=\"/17/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/17/off\"><button class=\"button button2\">OFF</button></a></p>");
            }

            client.println("<p>GPIO 32 - State " + output32State + "</p>");
            if (output32State == "off") {
              client.println("<p><a href=\"/32/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/32/off\"><button class=\"button button2\">OFF</button></a></p>");
            }

            client.println("</body></html>");

            client.println();
            break;
          } else {
            currentLine = "";
          }
        } else if (c != '\r') {
          currentLine += c;
        }
      }
    }

    header = "";
    client.stop();
    Serial.println("Client disconnected.");
    Serial.println("");
  }
}

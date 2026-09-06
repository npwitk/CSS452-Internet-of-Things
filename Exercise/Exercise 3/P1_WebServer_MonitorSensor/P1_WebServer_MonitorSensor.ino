#include <WiFi.h>

const char* ssid     = "npwitk";
const char* password = "aisfibre2010";

WiFiServer server(80);

String header;

const int potPin = 36;
int potValue = 0;

void setup() {
  Serial.begin(115200);

  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.println("IP address: ");
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

            potValue = analogRead(potPin);

            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();

            client.println("<!DOCTYPE html><html>");
            client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            client.println("<link rel=\"icon\" href=\"data:,\">");

            client.println("<style>");
            client.println("html { font-family: Helvetica, Arial, sans-serif; text-align: center; }");
            client.println("h1 { font-size: 48px; margin-top: 20px; margin-bottom: 30px; }");
            client.println("table { border-collapse: collapse; margin: 0 auto; }");
            client.println("th, td { border: 1px solid black; padding: 10px 30px; font-size: 22px; }");
            client.println("th { font-weight: bold; }");
            client.println("</style>");
            client.println("</head>");

            client.println("<body>");
            client.println("<h1>ESP32 WebServer</h1>");
            client.println("<table>");
            client.println("<tr><th>Sensor</th><th>Value</th></tr>");
            client.println("<tr><td>Potentiometer</td><td>" + String(potValue) + "</td></tr>");
            client.println("</table>");
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

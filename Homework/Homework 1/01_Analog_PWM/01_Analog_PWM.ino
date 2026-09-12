const int potPin = A0;  // Potentiometer pin
const int ledPin = 17;  // LED pin

// setting PWM properties
const int freq = 5000;
const int resolution = 8;

int potValue = 0;
int ledValue = 0;

void setup() {
  // configure LED PWM AND attach it to the pin in one call (new API)
  ledcAttach(ledPin, freq, resolution);
}

void loop() {
  potValue = analogRead(potPin);
  ledValue = map(potValue, 0, 4095, 0, 255);

  // changing the LED brightness with PWM — now takes the pin, not a channel
  ledcWrite(ledPin, ledValue);
}
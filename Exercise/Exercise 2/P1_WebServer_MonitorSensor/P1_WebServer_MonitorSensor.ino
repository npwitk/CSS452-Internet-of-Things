// set pin numbers
const int buttonPin = 34;  // the push button pin
const int led1Pin = 16;    // the LED1 pin
const int led2Pin = 17;    // the LED2 pin

int led1State = LOW;
int led2State = LOW;
unsigned long previousMillis = 0;
const long interval = 2000; // 2 second

void toggle() {
  led2State = !led2State;
  digitalWrite(led2Pin, led2State);
}

void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);
  attachInterrupt(digitalPinToInterrupt(buttonPin), toggle, FALLING);
}

void loop() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    led1State = !led1State;
    digitalWrite(led1Pin, led1State);
  }
}
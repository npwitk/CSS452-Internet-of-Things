const int buttonPin = 34;
const int led1Pin = 16;
const int led2Pin = 17;

int buttonState = LOW;
int led1State = LOW;
unsigned long previousMillis = 0;
const long interval = 2000;

void TimerLED(void * parameter) {
  for (;;) {
    Serial.print("TimerLED() running on core ");
    Serial.println(xPortGetCoreID());
    delay(100);
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      led1State = !led1State;
      digitalWrite(led1Pin, led1State);
    }
  }
  vTaskDelete(NULL);
}

void SwitchLED(void * parameter) {
  for (;;) {
    Serial.print("SwitchLED() running on core ");
    Serial.println(xPortGetCoreID());
    delay(100);
    buttonState = digitalRead(buttonPin);
    digitalWrite(led2Pin, buttonState == LOW ? HIGH : LOW);
  }
  vTaskDelete(NULL);
}

void setup() {
  Serial.begin(115200);
  pinMode(buttonPin, INPUT);
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);
  xTaskCreatePinnedToCore(TimerLED, "TimerLED", 1024, NULL, 1, NULL, 0);   // Core 0
  xTaskCreatePinnedToCore(SwitchLED, "SwitchLED", 1024, NULL, 1, NULL, 1); // Core 1
}

void loop() {}
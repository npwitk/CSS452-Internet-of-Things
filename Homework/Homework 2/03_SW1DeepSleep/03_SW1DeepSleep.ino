const int buttonPin = 34;  // SW
const int led1Pin = 16;
const int led2Pin = 17;
const int sw1Pin  = 26;    // SW1 - triggers deep sleep

int buttonState = LOW;
int led1State = LOW;
unsigned long previousMillis = 0;
const long interval = 2000;
#define TIME_TO_SLEEP 15   // seconds

volatile bool sleepRequested = false;

void requestSleep() {       // ISR — keep it short
  sleepRequested = true;
}

void TimerLED(void * parameter) {
  for (;;) {
    Serial.print("TimerLED() running on core ");
    Serial.println(xPortGetCoreID());
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      led1State = !led1State;
      digitalWrite(led1Pin, led1State);
    }
    delay(100);
  }
  vTaskDelete(NULL);
}

void SwitchLED(void * parameter) {
  for (;;) {
    Serial.print("SwitchLED() running on core ");
    Serial.println(xPortGetCoreID());

    buttonState = digitalRead(buttonPin);
    digitalWrite(led2Pin, buttonState == LOW ? HIGH : LOW);

    if (sleepRequested) {
      Serial.println("SW1 pressed -> entering deep sleep for 15s...");
      esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * 1000000);
      delay(100);               // let serial finish printing
      esp_deep_sleep_start();
    }
    delay(100);
  }
  vTaskDelete(NULL);
}

void setup() {
  Serial.begin(115200);
  pinMode(buttonPin, INPUT);
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);
  pinMode(sw1Pin, INPUT);

  attachInterrupt(digitalPinToInterrupt(sw1Pin), requestSleep, FALLING);

  xTaskCreatePinnedToCore(TimerLED, "TimerLED", 1024, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(SwitchLED, "SwitchLED", 1024, NULL, 1, NULL, 1);
}

void loop() {}
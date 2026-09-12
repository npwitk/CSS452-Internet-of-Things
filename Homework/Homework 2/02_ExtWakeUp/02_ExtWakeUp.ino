RTC_DATA_ATTR int bootCount = 0;

void setup() {
  esp_sleep_enable_ext0_wakeup(GPIO_NUM_32, LOW);  // wake when GPIO32 goes LOW

  Serial.begin(115200);
  delay(1000);
  ++bootCount;
  Serial.println("Boot number: " + String(bootCount));
  Serial.println("ESP32 will enter the deep sleep in 10 s.");
  delay(10000);

  Serial.println("... Now, in the deep sleep mode.");
  esp_deep_sleep_start();
  Serial.println("This sentence will never be printed.");
}

void loop() {}
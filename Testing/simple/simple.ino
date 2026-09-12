int a = 0;

void setup() {
  Serial.begin(115200);
}

void loop() {
  a = a + 1;
  Serial.println(a);
  delay(3000);
}
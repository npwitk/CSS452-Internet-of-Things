const int SW1_PIN  = 4;
const int LED1_PIN = 26;
const int LED2_PIN = 27;

void setup() {
  pinMode(SW1_PIN, INPUT_PULLUP);
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
}

void loop() {
  bool pressed = (digitalRead(SW1_PIN) == LOW);

  digitalWrite(LED1_PIN, pressed ? HIGH : LOW);
  digitalWrite(LED2_PIN, pressed ? LOW : HIGH);
}
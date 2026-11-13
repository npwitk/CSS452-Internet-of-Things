# Exercise 7 – Example 2: the Pi as broker and subscriber

- **ESP32:** upload `Lecture/Lecture 10/Local_RaspberryPi_PubSub.ino`. Wire the potentiometer to 3V3, A0 and GND, and LED2 to GPIO26 through 330 Ω.
- **Pi:** wire LED1 to GPIO22 (pin 15) through 330 Ω to GND. Import `Example2_Gauge_LED1/flow.json` and Deploy, then open `/ui`.

Turning the knob dims and brightens LED1, turns LED2 on above 500, and moves the gauge.

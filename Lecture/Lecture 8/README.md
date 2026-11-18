# Lecture 8 – Introduction to Raspberry Pi (gpiozero + guizero)

Run each script on the Pi in Thonny (**Run**), or from a terminal with `python3 <file>.py`. Press **Ctrl+C** to stop.

| Folder | Example | Circuit |
|---|---|---|
| `00_GPIO_Library_Comparison` | Turn an LED on for 5 s, written with RPi.GPIO and again with gpiozero | LED on GPIO18 (pin 12) → 330 Ω → GND |
| `01_LED_OnOff` | Example 1: LED on/off every 2 s (HW5-Q1) | LED on GPIO22 (pin 15) → 330 Ω → GND |
| `02_LED_Blink` | Example 2: `LED.blink()` | same |
| `03_PWMLED_Input` | Example 3: brightness from keyboard input (HW5-Q2) | same (PWM) |
| `04_Button_LED_Polling` | Example 4: LED follows the switch, polling (HW5-Q3) | switch GPIO18 (pin 12) ↔ GND with the internal pull-up, LED on GPIO22 |
| `05_Button_Events` | Example 5: the same with `when_pressed` / `when_released` | same |
| `06a_GUI_Slider_TextBox`, `06b_GUI_PushButton` | guizero building blocks | none |
| `06_GUI_OnOff` | Example 6: On/Off GUI buttons control the LED (HW5-Q4) | LED on GPIO22 |
| `07_GUI_Slider_PWM` | Example 7: a slider dims the LED | LED on GPIO22 (PWM) |
| `08_ThingSpeak_Random` | Example 8: send a random integer to ThingSpeak every minute (HW5-Q5) | none (needs internet) |

**ThingSpeak key (Example 8):** copy `config_example.py` to `config.py` and put your Write API Key in it. `config.py` is git-ignored, so the key is never committed.

**Pin numbers:** gpiozero uses **GPIO (BCM) numbers**, so `LED(22)` means GPIO22, which is physical pin 15. Each script's pin is set near its top; change it there if you wired a different pin.

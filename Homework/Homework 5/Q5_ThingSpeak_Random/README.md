# Q5 – Random Integer to ThingSpeak (Lecture Note 8, Example 8)

Every 60 seconds the Pi sends a random integer from 0 to 100 to ThingSpeak `field1`, with an HTTP POST to `https://api.thingspeak.com/update.json`.

## Circuit

None. The Pi must be connected to the Internet, through the notebook's Internet Sharing or through Wi-Fi.

## ThingSpeak setup

1. **Channels → New Channel**. Set Name to `Lect8 – Ex8` and Field 1 to `Random Integer`, leave the rest blank, and click **Save Channel**.
2. Open the **API Keys** tab and copy the **Write API Key**.

## API key (kept out of git)

```bash
cp config_example.py config.py
# then edit config.py:  KEY = '<your Write API Key>'
```

`config.py` is listed in the repo's `.gitignore`, so the real key is never committed. Only `config_example.py`, which holds a placeholder, is committed.

## Run

1. Open `Q5_ThingSpeak_Random.py` in Thonny on the Pi and click **Run**,
   or run `python3 Q5_ThingSpeak_Random.py` in a terminal.
2. The Shell prints `Number: <n>` once a minute. Let it run 5–6 minutes so the chart has several points.
3. Stop with the **Stop** button in Thonny, or Ctrl+C.

## Video "Q5" must show

- the Python code
- the graph of the random numbers in ThingSpeak (Field 1 Chart)

## Wiring

None. The Pi only needs an internet connection.

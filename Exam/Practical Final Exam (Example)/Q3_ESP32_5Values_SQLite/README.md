# Q3 – ESP32 → MQTT → Node-RED → SQLite (5 values every 5 s)

- The ESP32 publishes **5 random values (0–100) every 5 s** to the Pi's Mosquitto broker.
- Node-RED stores each message as one row in a 6-column SQLite table: `TheTime` plus 5 values.

## Wiring

None. The ESP32 only needs USB power and the **same Wi-Fi as the Pi**.

## Files

| File | What |
|---|---|
| [`Q3_ESP32_5Values/Q3_ESP32_5Values.ino`](Q3_ESP32_5Values/Q3_ESP32_5Values.ino) | ESP32 sketch, based on Lecture 10's `Local_NodeRed_PubNode_JSON.ino` |
| [`flow.json`](flow.json) | Node-RED flow: create table, mqtt in → json → function → sqlite insert, and a check-table button |
| [`create_table.sql`](create_table.sql) | Alternative: create the table from the terminal |

## Steps

1. **Pi:** Mosquitto running with `listener 1883` and `allow_anonymous true` (Lecture 10). Install `node-red-node-sqlite`.
2. **Node-RED:** import `flow.json`, change `YOUR_ID` in the mqtt in topic, then Deploy. The mqtt in node shows **connected**.
3. **Create the table once:** click **create table (click once)**. Clicking twice gives "table FiveValues already exists", which is harmless.
4. **ESP32:** in the sketch, set `ssid`, `password`, `mqtt_server` (the **Pi's Wi-Fi IP**) and the same `YOUR_ID` in `Topic` and `ClientID`. Upload, then open the Serial Monitor at 115200:
   ```
   Pub: {"V1":12,"V2":87,"V3":45,"V4":3,"V5":100}
   ```
5. **Check the data:** click **check table** (the result appears in the debug sidebar), or run on the Pi:
   ```bash
   sqlite3 /home/pi/ExamDB "select * from FiveValues;"
   ```

## Table

```sql
create table FiveValues (TheTime Timestamp, V1 integer, V2 integer, V3 integer, V4 integer, V5 integer);
```

The function node fills in the prepared statement:

```javascript
msg.params = { $TimeVal: Date.now(), $V1: msg.payload.V1, $V2: msg.payload.V2,
               $V3: msg.payload.V3, $V4: msg.payload.V4, $V5: msg.payload.V5 };
return msg;
```

```sql
insert into FiveValues (TheTime, V1, V2, V3, V4, V5) values ($TimeVal, $V1, $V2, $V3, $V4, $V5)
```

- **`json` node:** set its Action to **"Always convert to JavaScript Object"**. That way `msg.payload.V1` works whatever the mqtt in node sends.
  - **Why this matters:** if the **mqtt in** node's Output is "auto-detect (parsed JSON object…)", it has *already* turned the text into an object. A `json` node left on the default "Convert between JSON String & Object" then **flips it back into a string**. `msg.payload.V1` becomes `undefined`, and SQLite stores **`TheTime` with `V1–V5` all `null`**.
  - **Two ways to fix it:** set the `json` node to "Always convert to JavaScript Object" (what this flow now does), or set mqtt in's Output to "a String". If you're unsure, adding `if (typeof msg.payload === "string") msg.payload = JSON.parse(msg.payload);` as the first line of the function node also works.
- **`TheTime`:** `Date.now()` in milliseconds. For readable times: `select datetime(TheTime/1000,'unixepoch','localtime'), V1, V2, V3, V4, V5 from FiveValues;`
- **`random(101)`:** gives 0–100. `random(100)` would stop at 99.

## Demo checklist

1. Show the Arduino code and a screenshot of the flow with **all nodes** visible.
2. Show the table with `select * from FiveValues;`.
3. Wait **10 seconds** and show it again. There should be about 2 new rows, one every 5 s, which proves the Pi is receiving from the ESP32.

**If it doesn't connect:** `rc=-2` in the Serial Monitor means the ESP32 can't reach the Pi. Use the Pi's Wi-Fi IP, not `192.168.2.x`, and put both on the same Wi-Fi; a phone hotspot works well.

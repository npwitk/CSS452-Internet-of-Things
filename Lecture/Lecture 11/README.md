# Lecture 11 – Raspberry Pi: InfluxDB and Grafana

## Pi setup (once)

```bash
# InfluxDB v1
curl https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/influxdb-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/influxdb-archive-keyring.gpg] https://repos.influxdata.com/debian stable main" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt update && sudo apt install influxdb
sudo systemctl unmask influxdb && sudo systemctl enable influxdb && sudo systemctl start influxdb
sudo nano /etc/influxdb/influxdb.conf      # under [http]: remove the # before "enabled = true"
sudo systemctl restart influxdb

# Grafana
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update && sudo apt-get install -y grafana
sudo /bin/systemctl enable grafana-server && sudo /bin/systemctl start grafana-server
sudo grafana-cli admin reset-admin-password admin      # login admin / admin
```

Next, run `influx` and enter these InfluxQL commands:

```sql
create database InfluxTest
create user InfluxUser with password 'InfluxPW' with all privileges
grant all privileges on InfluxTest to InfluxUser
use InfluxTest
insert home,roomname=room1 temp=25,humid=50,light=65,pm=20
select * from home
```

Then set up Grafana at `http://<Pi IP>:3000`:

1. Add an InfluxDB data source: URL `http://localhost:8086`, database `InfluxTest`, user `InfluxUser` / `InfluxPW`, method POST.
2. Create a dashboard with 4 gauges. Each gauge queries `FROM home WHERE roomname = room1 SELECT field(temp) last()`, and likewise for humid, light and pm.

In Node-RED, install `node-red-contrib-influxdb` from **Manage palette**.

## Files

| File | What it is |
|---|---|
| `Home_Sensors_PubNode_JSON.ino` | ESP32 sketch. Publishes `{"roomname":"room1","temp":..,"humid":..,"light":..,"pm":..}` to `/IoT/HomeSensors` every few seconds. Put your SSID, password and the Pi's IP in the sketch. |
| `Example3_Insert_with_NodeRED/flow.json` | inject (room1/room2 JSON) → `Fields` function → `influxdb out` (measurement `home`) |
| `Example4_ESP32_JSON_to_InfluxDB/flow.json` | `mqtt in /IoT/HomeSensors` → `json` → `Fields` → `influxdb out`. Grafana's Room1 dashboard then updates live. |

For Example 5 (Room2), use the same flow and change `"room1"` to `"room2"` in the sketch.

The `Fields` function sends `[fields, tags]`, which `influxdb out` writes as one point:

```javascript
msg.payload = [{temp:msg.payload.temp, humid:msg.payload.humid, light:msg.payload.light, pm:msg.payload.pm},
               {roomname:msg.payload.roomname}];
return msg;
```

**Tested on:** InfluxDB 1.13.2, Grafana 13.3.1 and Node-RED 5.0.9 on a Raspberry Pi 4, with MQTT test messages published from a laptop in place of the ESP32.

-- CSS452 Lecture 10, Example 3: create Home1.db / table Room1 in the sqlite3 shell
-- Run on the Pi:  cd /home/pi && sqlite3 Home1.db < example3.sql
-- or open the shell with  sqlite3 Home1.db  and type the lines one by one.
CREATE TABLE Room1(id INTEGER PRIMARY KEY AUTOINCREMENT, date DATETIME, sensor1 REAL, sensor2 REAL, sensor3 REAL);
.tables
INSERT INTO Room1 (date, sensor1, sensor2, sensor3) VALUES (datetime("now"), 55, 29, 71);
SELECT * FROM Room1;

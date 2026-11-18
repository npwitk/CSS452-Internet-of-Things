-- Alternative to the "create table" inject: run once on the Pi
--   sqlite3 /home/pi/ExamDB < create_table.sql
create table FiveValues (TheTime Timestamp, V1 integer, V2 integer, V3 integer, V4 integer, V5 integer);
.tables

# CSS452 Exercise 5 - Hello World in Thonny on the Raspberry Pi
# Run it on camera to show that Thonny works on the Pi desktop (through VNC).
#
# Circuit: none.
# Run on the Pi: open in Thonny and click Run.

import platform
import socket

print("Hello World")
print("Host:", socket.gethostname())
print("Python:", platform.python_version())

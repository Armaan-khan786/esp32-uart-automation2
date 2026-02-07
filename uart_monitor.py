import serial
import time
import sys

PORT = sys.argv[1]     # passed from CI
BAUD = 115200
TIMEOUT = 10           # seconds

ser = serial.Serial(PORT, BAUD, timeout=1)
start = time.time()

print(f"Listening on {PORT}...")

found = False

while time.time() - start < TIMEOUT:
    line = ser.readline().decode(errors="ignore").strip()
    if line:
        print(line)
        if "UART TOGGLE TEST PASS" in line:
            found = True
            break

ser.close()

if found:
    print("✅ UART TOGGLE TEST PASS detected")
    sys.exit(0)
else:
    print("❌ UART TOGGLE TEST FAIL")
    sys.exit(1)

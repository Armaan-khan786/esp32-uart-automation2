from serial.tools import list_ports
import serial
import time
import sys

BAUD = 115200
READ_TIME = 10

def find_esp_ports():
    ports = []
    for p in list_ports.comports():
        if "CP210" in p.description or "CH340" in p.description:
            ports.append(p.device)
    return ports

ports = find_esp_ports()
print("Detected ESP32 ports:", ports)

if len(ports) < 2:
    print("ERROR: Less than 2 ESP32 boards detected")
    sys.exit(1)

test_passed = False

for port in ports:
    print(f"\n--- Listening on {port} ---")
    ser = serial.Serial(port, BAUD, timeout=1)
    time.sleep(2)

    start = time.time()
    while time.time() - start < READ_TIME:
        if ser.in_waiting:
            line = ser.readline().decode(errors="ignore").strip()
            print(f"{port} >> {line}")

            if "UART TOGGLE TEST PASS" in line:
                test_passed = True

    ser.close()

if not test_passed:
    print("\nUART TOGGLE TEST FAILED")
    sys.exit(1)

print("\nUART TOGGLE TEST PASSED")
sys.exit(0)

#!/usr/bin/env python3
import evdev
from evdev import ecodes
import time

def detect_key_code():
    """Simple key code detector"""
    print("Scanning for input devices...")
    
    devices = []
    for path in evdev.list_devices():
        try:
            device = evdev.InputDevice(path)
            devices.append(device)
            print(f"Found: {device.name} ({device.path})")
        except Exception as e:
            print(f"Error accessing {path}: {e}")
    
    if not devices:
        print("No accessible devices found!")
        return
    
    print(f"\nMonitoring {len(devices)} devices...")
    print("Press your PTT button (Ctrl+C to stop):")
    
    try:
        while True:
            for device in devices:
                try:
                    # Try to read a single event
                    events = device.read()
                    if events:
                        for event in events:
                            if event.type == ecodes.EV_KEY:
                                if event.value == 1:  # Key press
                                    print(f"\n*** KEY DETECTED ***")
                                    print(f"Code: {event.code}")
                                    print(f"Device: {device.name}")
                                    print(f"Path: {device.path}")
                                    return event.code
                except (BlockingIOError, OSError):
                    continue
            time.sleep(0.001)
    except KeyboardInterrupt:
        print("\nStopped.")
        return None

if __name__ == "__main__":
    detect_key_code()
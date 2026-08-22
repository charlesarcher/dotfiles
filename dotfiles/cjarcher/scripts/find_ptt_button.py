#!/usr/bin/env python3
import sys
import os
import fcntl
import evdev
from evdev import ecodes
import dbus
import time

def list_input_devices():
    devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
    print("Available input devices:")
    for i, device in enumerate(devices):
        caps = device.capabilities()
        ev_key_caps = caps.get(evdev.ecodes.EV_KEY, [])
        device_type = "Unknown"
        if ecodes.BTN_MOUSE in ev_key_caps and ecodes.BTN_LEFT in ev_key_caps:
            device_type = "Mouse"
        elif ecodes.KEY_A in ev_key_caps and ecodes.KEY_Z in ev_key_caps:
            device_type = "Keyboard"
        print(f"{i}: {device.name} (Type: {device_type}, Path: {device.path})")
    return devices

def find_key_code():
    """Monitor all devices to find the key code for your PTT button"""
    devices = list_input_devices()
    if not devices:
        print("No input devices found.")
        return None
    
    print("\nMonitoring all devices for key presses...")
    print("Press your PTT button to see its key code.")
    print("Press Ctrl+C to stop monitoring.\n")
    
    # Create a dictionary to track device names by path
    device_names = {device.path: device.name for device in devices}
    
    try:
        # Monitor all devices simultaneously
        for device in devices:
            # Set device to non-blocking mode
            fd = device.fileno()
            flag = fcntl.fcntl(fd, fcntl.F_GETFL)
            fcntl.fcntl(fd, fcntl.F_SETFL, flag | os.O_NONBLOCK)
        
        while True:
            for device in devices:
                try:
                    # Read events without blocking
                    for event in device.read_loop():
                        if event.type == ecodes.EV_KEY and event.value == 1:  # Key press only
                            device_name = device_names.get(device.path, "Unknown")
                            print(f"Key pressed: code={event.code}, device='{device_name}', path='{device.path}'")
                            return event.code
                except (BlockingIOError, OSError):
                    # No events available for this device, continue
                    continue
            time.sleep(0.01)  # Small delay to prevent CPU spinning
            
    except KeyboardInterrupt:
        print("\nMonitoring stopped.")
        return None

class MumbleRPC:
    def __init__(self):
        try:
            # Try to get the session bus address from environment
            bus_address = os.environ.get('DBUS_SESSION_BUS_ADDRESS')
            if bus_address:
                self.bus = dbus.bus.BusConnection(bus_address)
            else:
                self.bus = dbus.SessionBus()
            self.mumble_object = self.bus.get_object("net.sourceforge.mumble.mumble", "/")
            self.mumble_interface = dbus.Interface(self.mumble_object, "net.sourceforge.mumble.Mumble")
        except dbus.exceptions.DBusException as e:
            print(f"Warning: Could not connect to Mumble via DBus: {e}")
            print("Make sure Mumble is running and DBus is properly configured.")
            self.bus = None
            self.mumble_object = None
            self.mumble_interface = None

    def set_push_to_talk(self, active):
        if not self.mumble_interface:
            print(f"Mumble interface not available - cannot {'activate' if active else 'deactivate'} push-to-talk")
            return
            
        try:
            if active == True:
                self.mumble_interface.startTalking(True)
            else:
                self.mumble_interface.stopTalking(True)
            print(f"Push-to-talk {'activated' if active else 'deactivated'}")

        except dbus.exceptions.DBusException as e:
            print(f"Error communicating with Mumble: {e}")

def main():
    print("PTT Button Finder")
    print("================")
    
    # First find the key code
    ptt_key = find_key_code()
    if ptt_key is None:
        print("No key code detected. Exiting.")
        sys.exit(1)
    
    print(f"\nDetected PTT key code: {ptt_key}")
    
    # Now ask which device to use for monitoring
    devices = list_input_devices()
    if not devices:
        print("No input devices found.")
        sys.exit(1)

    print(f"\nSelect which device to monitor for key code {ptt_key}:")
    while True:
        try:
            selection = int(input("Enter the number of the device you want to use: "))
            if 0 <= selection < len(devices):
                device = devices[selection]
                break
            else:
                print("Invalid selection. Please try again.")
        except ValueError:
            print("Please enter a valid number.")
    
    print(f"Selected device: {device.name} (Path: {device.path})")
    print(f"Watching for key code: {ptt_key}")

    mumble_rpc = MumbleRPC()

    print("Starting PTT monitoring. Press Ctrl+C to exit.")
    try:
        for event in device.read_loop():
            if event.type == ecodes.EV_KEY:
                if event.code == ptt_key:
                    if event.value == 1:  # Key press
                        print("PTT key pressed")
                        mumble_rpc.set_push_to_talk(True)
                    elif event.value == 0:  # Key release
                        print("PTT key released")
                        mumble_rpc.set_push_to_talk(False)
    except KeyboardInterrupt:
        print("Script terminated by user")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
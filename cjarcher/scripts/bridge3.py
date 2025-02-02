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

def select_device(devices):
    while True:
        try:
            selection = int(input("Enter the number of the device you want to use: "))
            if 0 <= selection < len(devices):
                return devices[selection]
            else:
                print("Invalid selection. Please try again.")
        except ValueError:
            print("Please enter a valid number.")

class MumbleRPC:
    def __init__(self):
        self.bus = dbus.SessionBus()
        self.mumble_object = self.bus.get_object("net.sourceforge.mumble.mumble", "/")
        self.mumble_interface = dbus.Interface(self.mumble_object, "net.sourceforge.mumble.Mumble")

    def set_push_to_talk(self, active):
        try:
            if active == True:
                self.mumble_interface.startTalking(True)
            else:
                self.mumble_interface.stopTalking(True)
            print(f"Push-to-talk {'activated' if active else 'deactivated'}")

        except dbus.exceptions.DBusException as e:
            print(f"Error communicating with Mumble: {e}")

def main():
    devices = list_input_devices()
    if not devices:
        print("No input devices found.")
        sys.exit(1)

    device = select_device(devices)
    print(f"Selected device: {device.name} (Path: {device.path})")

    # Set the device to non-blocking mode
    fd = device.fileno()
    flag = fcntl.fcntl(fd, fcntl.F_GETFL)
    fcntl.fcntl(fd, fcntl.F_SETFL, flag | os.O_NONBLOCK)

    ptt_key = int(input("Enter the key code for your PTT button (e.g., 276 for mouse side button): "))
    print(f"Watching for key code: {ptt_key}")

    mumble_rpc = MumbleRPC()

    print("Starting event loop. Press Ctrl+C to exit.")
    try:
        for event in device.read_loop():
            if event.type == ecodes.EV_KEY:
                print(f"Key event detected: type={event.type}, code={event.code}, value={event.value}")
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

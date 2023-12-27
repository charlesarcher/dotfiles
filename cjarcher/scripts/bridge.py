import dbus

# This libinput is running from master, not what's in pip:
# git clone https://github.com/OzymandiasTheGreat/python-libinput.git
from libinput import LibInput, ContextType, EventType
from libinput.constant import ButtonState

# The CLI call that does the same "startTalking" dbus method
# gdbus call -e -d net.sourceforge.mumble.mumble -o / -m net.sourceforge.mumble.Mumble.startTalking

bus = dbus.SessionBus()
proxy_object = bus.get_object('net.sourceforge.mumble.mumble', '/')
startTalking = proxy_object.get_dbus_method('startTalking')
stopTalking = proxy_object.get_dbus_method('stopTalking')

li = LibInput(context_type=ContextType.UDEV)

# make sure you're part of the input group:
# sudo usermod -a -G input travis
# (log out and back in to activate)

# To find the button ID and libinput event device:
# libinput list-devices
# libinput debug-events

libinput_seat = 'seat0'
button = 276

device = li.assign_seat(libinput_seat)
for event in li.events:
    if event.type == EventType.POINTER_BUTTON:
        if event.button == button and event.button_state == ButtonState.PRESSED:
            print("start talking")
            startTalking()
        elif event.button == button and event.button_state == ButtonState.RELEASED:
            print("stop talking")
            stopTalking()

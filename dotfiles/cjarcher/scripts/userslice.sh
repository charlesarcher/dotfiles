#!/bin/bash
#small script to enable root access to x-windows system
xhost +SI:localuser:gamer

sudo -iu gamer $*

#disable root access after application terminates
xhost -SI:localuser:gamer
#print access status to allow verification that root access was removed
xhost

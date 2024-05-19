#!/bin/bash

export PATH=/opt/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/opt/cuda/lib64

#glxgears
#vkcube
#glxgears
steam -gamepadui -steamos3 -steampal -steamdeck -fullscreen

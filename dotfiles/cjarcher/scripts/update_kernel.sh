#!/bin/bash

MAKEFLAGS=-j48 _microarchitecture=28 _compiler=clang use_numa=y use_tracers=y yay -si linux-xanmod linux-xanmod-headers

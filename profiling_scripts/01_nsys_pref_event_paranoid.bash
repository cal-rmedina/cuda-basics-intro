#!/bin/bash

#--- bash script for changing pref_event_paranoid level ---
#
# It allows NVIDIA nsight-systems capture the GPU details while
# creating application profiling file.
# 
# MUST be run with super user privileges:
# $sudo bash 01_nsys_pref_event_paranoid.bash

## Option for nsys, perf_event_paranoid level must be 2 or less
cat /proc/sys/kernel/perf_event_paranoid
sh -c 'echo 2 >/proc/sys/kernel/perf_event_paranoid'
cat /proc/sys/kernel/perf_event_paranoid


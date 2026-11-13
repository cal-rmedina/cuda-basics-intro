#!/bin/bash
#--- check that the path is correct for your CUDA installation
path=/usr/local/cuda-13.4/bin/

#--- bash script for profiling CUDA application ---
#
# Runs NVIDIA nsight-systems generating *.nsys-rep creating application
# profiling file.

EXECUTABLE="main"
out_name="report"

if test -f "${EXECUTABLE}"; then
  echo "executable $EXECUTABLE exists, ncu-profiling executable"

  # Checking if there is a report already
  if test -f "${out_name}.ncu-rep"; then
    echo "${out_name}.ncu-rep already exists, profiling done before, delete for new profiling"
    exit 1 
  fi
  ${path}ncu --set full -c 3 --import-source yes -o ${out_name} ./${EXECUTABLE} 

else
  echo "${EXECUTABLE} doesn't exist, compile code for desired version!!!"
  exit 1
fi


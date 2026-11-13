#!/bin/bash

#--- bash script for profiling CUDA application ---
#
# Runs NVIDIA nsight-systems generating *.nsys-rep creating application
# profiling file.
# 

EXECUTABLE="main"
out_name="report"

if test -f "${EXECUTABLE}"; then
  echo "executable ${EXECUTABLE} exists, profiling executable"

  # Checking if there is a report already
  if test -f "${out_name}.nsys-rep"; then
    echo "${out_name}.nsys-rep already exists, profiling done before, delete for new profiling"
    exit 1 
  fi
  nsys profile -o ${out_name} ./${EXECUTABLE} 

else
  echo "${EXECUTABLE}${VERSION} doesn't exist, compile code for desired version!!!"
  exit 1
fi


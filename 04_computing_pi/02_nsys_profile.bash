#!/bin/bash

#--- bash script for profiling CUDA application ---
#
# Runs NVIDIA nsight-systems generating *.nsys-rep creating application
# profiling file.

#NCU_PATH=/usr/local/cuda/bin/
EXE_NAME="main"       # Executable name
OUT_NAME="test"       # Output file name (${OUT_NAME}.nsys-rep)

# Check if a custom executable name is provided as an argument
if [ $# -gt 0 ]; then
  EXE_NAME="$1"       # Set exe name to the first argument
fi

# Check if a custom output name is provided as an argument
if [ $# -gt 1 ]; then
  OUT_NAME="$2"       # Set output name to the second argument
fi

if test -f "$EXE_NAME"; then
  echo "Executable $EXE_NAME exists, profiling executable"

  # Checking if there is a report already
  if test -f "${OUT_NAME}.nsys-rep"; then
    read -p "Profiling report already exist, do you want to delete it and proceed with new profiling? (y/n): " choice
    case "$choice" in
    y|Y ) 
      rm "${OUT_NAME}.nsys-rep"
      echo "Deleted ${OUT_NAME}.nsys-rep. Proceeding with new profiling."
      ;;
    n|N ) 
      echo "Exiting without changes."
      exit 1 
      ;;
    * ) 
      echo "Invalid choice. Exiting."
      exit 1 
      ;;
    esac
  fi
  nsys profile -o ${OUT_NAME} ./${EXE_NAME}

else
  echo "$EXE_NAME doesn't exist, compile code for desired version!!!"
  exit 1
fi



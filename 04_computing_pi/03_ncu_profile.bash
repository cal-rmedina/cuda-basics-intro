#!/bin/bash

#--- Bash script for profiling CUDA application ---
#
# Runs NVIDIA nsight-systems generating *.ncu-rep creating application
# profiling file.

#NCU_PATH=/usr/local/cuda/bin/
EXE_NAME="main"				# Executable name
OUT_NAME="test"				# Output file name (${OUT_NAME}.ncu-rep)
KERNEL_NAME="adding_2_arrays_kernel"	# Kernel to be tested

# Check if a custom exe name is provided as an argument
if [ $# -gt 0 ]; then
  EXE_NAME="$1"       # Set exe name to the first argument
fi

# Check if a custom output name is provided as an argument
if [ $# -gt 1 ]; then
  OUT_NAME="$2"       # Set output name to the second argument
fi

# Check if a custom kernel name is provided as an argument
if [ $# -gt 2 ]; then
  KERNEL_NAME="$3"    # Set kernel name to the third argument
fi

if test -f "$EXE_NAME"; then
  echo "executable $EXE_NAME exists, ncu-profiling executable"

  # Checking if there is a report already
  if test -f "${OUT_NAME}.ncu-rep"; then
    read -p "Profiling report already exist, do you want to delete it and proceed with new profiling? (y/n): " choice
    case "$choice" in
    y|Y ) 
      rm "${OUT_NAME}.ncu-rep"
      echo "Deleted ${OUT_NAME}.ncu-rep. Proceeding with new profiling."
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
  # Checking if there is a report already
  if test -f "${OUT_NAME}.ncu-rep"; then
    echo "${OUT_NAME}.ncu-rep already exists, profiling done before, delete for new profiling"
    exit 1 
  fi

  ${NCU_PATH}ncu --set full --kernel-name ${KERNEL_NAME} --launch-skip 0 --launch-count 5 -o ${OUT_NAME} "./${EXE_NAME}"

else
  echo "$EXE_NAME doesn't exist, compile code for desired version!!!"
  exit 1
fi


#!/bin/bash

#--- bash script for profiling CUDA application ---
#
# Runs NVIDIA nsight-systems generating *.nsys-rep creating application
# profiling file.
# 
# out_name: output file name
# im_size:  samples sizes

## Images samples (ref, ws, mask, dest-mask) sizes
#    01 -  600x600  px
#    02 - 1200x1200 px
#    03 - 4200x4200 px
im_size=03

## Output profiling file name (out_name.nsys-rep)

path=/home/amedina/build/core-library/standalones/dic/test_nsys

DIC_EXE="digital-image-correlation"
out_name="dic_report"

if test -f "${DIC_EXE}"; then
  echo "executable ${DIC_EXE} exists, profiling executable"

  # Checking if there is a report already
  if test -f "${out_name}.nsys-rep"; then
    echo "${out_name}.nsys-rep already exists, profiling done before, delete for new profiling"
    exit 1 
  fi
#  nsys profile -o ${out_name} ./${DIC_EXE} --source-image ref-${im_size}.png --destination-image ws-${im_size}.png --source-mask mask-${im_size}.png --destination-mask dest-mask-${im_size}.png --subset-spacing 5 --initial-search-spacing 100 --image-border 100
  TMPDIR=$path nsys profile -o ${out_name} ./${DIC_EXE} --source-image ref-${im_size}.png --destination-image ws-${im_size}.png --source-mask mask-${im_size}.png --destination-mask dest-mask-${im_size}.png --subset-spacing 5 --initial-search-spacing 100 --image-border 100 --layer 1

else
  echo "${DIC_EXE}${VERSION} doesn't exist, compile code for desired version!!!"
  exit 1
fi


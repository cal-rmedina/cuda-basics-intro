#!/bin/bash
path=/usr/local/cuda/bin/

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
#im_size=1-01

DIC_EXE="digital-image-correlation"

out_name=dic_report

if test -f "${DIC_EXE}"; then
  echo "executable $DIC_EXE exists, ncu-profiling executable"

  # Checking if there is a report already
  if test -f "${out_name}.ncu-rep"; then
    echo "${out_name}.ncu-rep already exists, profiling done before, delete for new profiling"
    exit 1 
  fi
  ${path}ncu --set full -c 3 -s 1 -k regex:compute_gradients_per_tile_kernel --kernel-name-base demangled --import-source yes -o ${out_name} ./${DIC_EXE} --source-image ref-${im_size}.png --destination-image ws-${im_size}.png --source-mask mask-${im_size}.png --destination-mask dest-mask-${im_size}.png --subset-spacing 5 --initial-search-spacing 100 --image-border 100 --layers 1

else
  echo "${DIC_EXE} doesn't exist, compile code for desired version!!!"
  exit 1
fi


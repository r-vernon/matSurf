#!/bin/bash

export SUBJECTS_DIR="/scratch/home/r/rv519/matSurf/Data"

mri_label2vol --label '/scratch/home/r/rv519/matSurf/Data/R3517/R3517_RH_V1.label' \
  --temp '/scratch/home/r/rv519/matSurf/Data/R3517/mri/orig.mgz' \
  --proj frac 0 1 0.01 --subject R3517 --hemi rh --identity \
  --o '/scratch/home/r/rv519/matSurf/Data/R3517/R3517_RH_V1.nii.gz' 
  
mri_binarize --dilate 1 --erode 1 \
  --i '/scratch/home/r/rv519/matSurf/Data/R3517/R3517_RH_V1.nii.gz' \
  --o '/scratch/home/r/rv519/matSurf/Data/R3517/R3517_RH_V1.nii.gz' --min 1
  
mris_calc -o '/scratch/home/r/rv519/matSurf/Data/R3517/R3517_RH_V1.nii.gz' \
  '/scratch/home/r/rv519/matSurf/Data/R3517/R3517_RH_V1.nii.gz' \
  mul '/scratch/home/r/rv519/matSurf/Data/R3517/mri/rh.ribbon.mgz'

#!/bin/bash

# export CUDA_VISIBLE_DEVICES=`qstat -n $PBS_JOBID|awk 'END {split ($NF, a, "/"); printf ("%s\n", a[2])}'`

### for CMU rocks cluster ###
#PBS -q gpu
#PBS -j oe
#PBS -o log_ivector_recognition
#PBS -d .
#PBS -V
#PBS -l walltime=48:00:00

export CUDA_VISIBLE_DEVICES=compute-0-25/1



lid/train_ivector_extractor.sh --cmd run.pl --num-iters 5 exp/full_ubm_1024/final.ubm data/train exp/extractor_1024

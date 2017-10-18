#!/bin/bash
# Apache 2.0.
#
# An incomplete run.sh for this example.

#set -e
#uname -a

### for CMU rocks cluster ###
#PBS -q gpu
#PBS -j oe
#PBS -o log
#PBS -d /data/ASR5/srallaba/kaldi/egs/rsk_lid/v1
#PBS -V
#PBS -l walltime=48:00:00

export CUDA_VISIBLE_DEVICES=compute-0-25/1


. ./cmd.sh
. ./path.sh

mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc
gmm_mix_vtln=64
num_spk_vtln=100
num_spk_subset=500
gmm_mix=1024

#### Make the required files for the languages

if [ ! -f data/tmp/.data_copy.done ]; then
  #rm -r data/tmp
  local/make_data_for_lid.sh /data/ASR5/srallaba/projects/LID/Spanish_English/scripts/spanish spanish data/tmp/spanish
  local/make_data_for_lid.sh /data/ASR5/srallaba/projects/LID/Spanish_English/scripts/english english data/tmp/english
  touch data/tmp/.data_copy.done

fi

#### Combine the files and make the data directory

if [ ! -f data/train/.data_prep.done ]; then
  #rm -r data/train*
  utils/combine_data.sh data/train_unsplit data/tmp/spanish data/tmp/english
  # original utt2lang will remain in data/train_unsplit/.backup/utt2lang.
  utils/apply_map.pl -f 2 --permissive local/lang_map.txt  < data/train_unsplit/utt2lang  2>/dev/null > foo
  cp foo data/train_unsplit/utt2lang
  # Just keep printing stuff so that I know you are alive 
  echo "**Language count in training:**"
  awk '{print $2}' foo | sort | uniq -c | sort -nr
  rm foo

  #local/split_long_utts.sh --max-utt-len 120 data/train_unsplit data/train  
  cp -r data/train_unsplit data/train
  touch data/train/.data_prep.done

fi
 
#### Extract features

if [ ! -f $mfccdir/.extraction.done ]; then

  use_vtln=true
  if $use_vtln; then
    rm -r data/train_novtln
    cp -r data/train data/train_novtln
    steps/make_mfcc.sh --mfcc-config conf/mfcc_vtln.conf --nj 100 --cmd "$train_cmd" data/train_novtln exp/make_mfcc $mfccdir
    lid/compute_vad_decision.sh data/train_novtln exp/make_mfcc $mfccdir
    cat mfcc/raw_mfcc_train_novtln.*.scp | sort > data/train_novtln/feats.scp
    cat mfcc/vad*.scp | sort > data/train_novtln/vad.scp
  fi
  touch $mfccdir/.extraction.done

fi

if [ ! -f $mfccdir/.vtln.done ]; then

  utils/subset_data_dir.sh data/train_novtln $num_spk_vtln data/train_novtln_$num_spk_vtln
  steps/make_mfcc.sh --mfcc-config conf/mfcc_vtln.conf --nj 10 --cmd "$train_cmd" data/train_novtln_$num_spk_vtln exp/make_mfcc $mfccdir
  sid/train_diag_ubm.sh --nj 30 --cmd "$train_cmd" data/train_novtln_$num_spk_vtln $gmm_mix_vtln exp/diag_ubm_vtln
  lid/train_lvtln_model.sh --mfcc-config conf/mfcc_vtln.conf --nj 30 --cmd "$train_cmd" data/train_novtln_$num_spk_vtln exp/diag_ubm_vtln exp/vtln
  lid/get_vtln_wraps.sh --nj 100 --cmd "$train_cmd" data/train_novtln exp/vtln exp/train_warps 
  cp exp/train_warps/utt2warp data/train
  steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj 100 --cmd "$train_cmd" data/train exp/make_mfcc $mfccdir
  lid/compute_vad_decision.sh --nj 4 --cmd "$train_cmd" data/train exp/make_vad $vaddir
  touch $mfccdir/.vtln.done
  echo "VTLN wrapping done"    

fi


if [ ! -f $mfccdir/.ubm.done ]; then
  
  utils/subset_data_dir.sh data/train ${num_spk_subset} data/train_${num_spk_subset}
  lid/train_diag_ubm.sh --nj 30 --cmd "$train_cmd" data/train_$num_spk_subset $gmm_mix exp/diag_ubm_${num_spk_subset}_${gmm_mix}
  lid/train_full_ubm.sh --nj 30 --cmd "$train_cmd" data/train_$num_spk_subset $gmm_mix exp/full_ubm_${num_spk_subset}_${gmm_mix}
  lid/train_full_ubm.sh --nj 30 --cmd "$train_cmd" data/train $gmm_mix exp/full_ubm_$gmm_mix
  touch $mfccdir/.ubm.done 
fi

if [ ! -f $mfccdir/.ivector.done ]; then

  lid/train_ivector_extractor.sh --cmd "$train_cmd --mem 2G" --num-iters 5 exp/full_ubm_1024/final.ubm data/train exp/extractor_1024
  lid/extract_ivectors.sh --cmd "$train_cmd --mem 3G" --nj 50 exp/extractor_1024 data/train exp/ivectors_train
  touch $mfccdir/.ivector.done

fi

if [ ! -f exp/.regression.done ]; then

  lid/run_logistic_regression.sh --prior-scale 0.70 --conf conf/logistic-regression.conf 

fi


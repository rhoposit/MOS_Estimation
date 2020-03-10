#!/bin/bash

#
# Copyright 2019 CSTR, University of Edinburgh
#
# Authors: Erfan Loweimi, Joachim Fainberg, Jennifer Williams, 
#          Joanna Rownicka and Ondrej Klejch
# Apache 2.0.

# Description:
# This script extracts mfcc for ASV2019
# 

data_dir=data-xvector
feat_type=mfcc-hres-lf0-hf0
dataset=

# Config here ...
stage=0
nj=32
nj_split=3
write_utt2num_frames=false

. parse_options.sh || exit 1;
. ./cmd.sh

feat_config=conf/${feat_type}.conf
feat_dir=${feat_type}
vad_dir=${feat_dir}-vad

if [ $stage -le 0 ]; then
  echo "###################### Extracting MFCC features for ${dataset}... ######################"
  mkdir -p $feat_dir
  local/make_mfcc.sh --write-utt2num-frames $write_utt2num_frames \
      --mfcc-config $feat_config --nj $nj $data_dir/$dataset \
      exp/make_$feat_type/$dataset $feat_dir || exit 1;
  #utils/fix_data_dir.sh $data_dir/$dataset || exit 1;
  local/compute_vad_decision.sh --nj $nj_split --cmd "$train_cmd" \
    $data_dir/$dataset exp/make_${feat_type}-vad/$dataset $vad_dir || exit 1;
  #utils/fix_data_dir.sh $data_dir/$dataset || exit 1;
fi

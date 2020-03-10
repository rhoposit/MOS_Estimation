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
  steps/make_mfcc.sh --write-utt2num-frames $write_utt2num_frames \
      --mfcc-config $feat_config --nj $nj $data_dir/$dataset \
      exp/make_$feat_type/$dataset $feat_dir || exit 1;
  utils/fix_data_dir.sh $data_dir/$dataset || exit 1;
  local/compute_vad_decision.sh --nj $nj_split --cmd "$train_cmd" \
    $data_dir/$dataset exp/make_${feat_type}-vad/$dataset $vad_dir || exit 1;
  utils/fix_data_dir.sh $data_dir/$dataset || exit 1;
fi

# silence frames removed and sliding CMN applied
if [ $stage -le 1 ]; then
  echo "############ Preparing the features (CMN, silence removed) for ${dataset}... ############"
  local/nnet3/xvector/prepare_feats_for_egs.sh --nj $nj_split $data_dir/$dataset \
    $data_dir/${dataset}_no_sil ${feat_dir}_no_sil || exit 1;
fi

# just CMN
if [ $stage -le 2 ]; then
  echo "##################### Preparing the features (CMN) for ${dataset}... #####################"
  cmn_window=300
  data_dir_cmn=$data_dir/${dataset}_cmn
  mkdir -p $data_dir_cmn
  cp $data_dir/${dataset}/{spk2utt,utt2spk,utt2num_frames,wav.scp} $data_dir_cmn 
  cp -r $data_dir/${dataset}/split$nj_split $data_dir_cmn
  sdata_in=$data_dir_cmn/split$nj_split;

  $train_cmd JOB=1:$nj_split $data_dir_cmn/log/create_xvector_feats.JOB.log \
    apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=$cmn_window \
    scp:${sdata_in}/JOB/feats.scp ark,scp:$data_dir_cmn/xvector_feats_cmn.JOB.ark,$data_dir_cmn/xvector_feats_cmn.JOB.scp || exit 1;

  for n in $(seq $nj_split); do
    cat $data_dir_cmn/xvector_feats_cmn.$n.scp || exit 1;
  done > $data_dir_cmn/feats.scp || exit 1
fi

if [ $stage -le 3 ]; then
  # Now, we need to remove features that are too short after removing silence
  # frames.  We want atleast 5s (500 frames) per utterance.
  echo "### Removing utterances < 1s for features with CMN and silence removed for ${dataset}... ###"
  min_len=100
  cp -r $data_dir/${dataset}_no_sil $data_dir/${dataset}_no_sil_min${min_len}
  mv $data_dir/${dataset}_no_sil_min${min_len}/utt2num_frames $data_dir/${dataset}_no_sil_min${min_len}/utt2num_frames.bak
  awk -v min_len=${min_len} '$2 > min_len {print $1, $2}' $data_dir/${dataset}_no_sil_min${min_len}/utt2num_frames.bak > $data_dir/${dataset}_no_sil_min${min_len}/utt2num_frames
  utils/filter_scp.pl $data_dir/${dataset}_no_sil_min${min_len}/utt2num_frames $data_dir/${dataset}_no_sil_min${min_len}/utt2spk > $data_dir/${dataset}_no_sil_min${min_len}/utt2spk.new
  mv $data_dir/${dataset}_no_sil_min${min_len}/utt2spk.new $data_dir/${dataset}_no_sil_min${min_len}/utt2spk
  utils/fix_data_dir.sh $data_dir/${dataset}_no_sil_min${min_len} || exit 1;
fi



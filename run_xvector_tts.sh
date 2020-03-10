#!/bin/bash
#
# Copyright 2019 CSTR, University of Edinburgh
#
# Authors: Joanna Rownicka, Jennifer Williams
# Apache 2.0.
#########################################################


. ./cmd.sh
. ./path.sh

set -e

workdir=`pwd`
nj=32

######## x-vectors ########
nnet_dir=$workdir/xvector_nnet_1b_device_5
xvec_write_dir=$workdir/xvec5
mfccdir=$workdir/tts_data

################################ extract xvectors ################################

echo "Extracting MFCCs.."
utils/utt2spk_to_spk2utt.pl < tts_data/utt2spk > tts_data/spk2utt
utils/fix_data_dir.sh tts_data
local/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj 40 \
  tts_data/ tts_data/make_mfcc/ tts_data/mfcc
utils/fix_data_dir.sh tts_data

echo "Computing VAD decision.."
local/compute_vad_decision.sh $mfccdir || exit 1;
utils/fix_data_dir.sh $mfccdir || exit 1;

echo "Extracting xvectors.."
local/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 6G" --nj $nj \
  $nnet_dir $mfccdir $xvec_write_dir/xvectors_mfcc_lf0_hf0_device_5 || exit 1;
copy-vector scp:xvec5/xvectors_mfcc_lf0_hf0_device_5/xvector.scp ark,t:- > \
  xvec5/xvectors_mfcc_lf0_hf0_device_5.txt

# start with an utt2spk and a wav.scp in your data folder
utils/utt2spk_to_spk2utt.pl < data/utt2spk > data/spk2utt

# validate the directory (will check sorting issues)
# if there is an error with utt2spk or wav.scp as having duplicates or 
# not in sorted order, then use sort and uniq, and re-run this step
# EX: cat utt2spk | sort | uniq > hold
# mv hold utt2spk
# then re-run, also check wav.scp
utils/validate_data_dir.sh --no-text --no-feats data/


# the following set of commands use the pre-trained model 
# to extract x-vectors from the data

# make mfccs based on parameters on conf/mfcc.conf
utils/fix_data_dir.sh data/
steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj 40 data/ exp/make_mfcc/ mfcc

# make voice activity detection decisions based on parameters in conf/vad.conf
utils/fix_data_dir.sh data/
sid/compute_vad_decision.sh --nj 40 data/ exp/make_vad mfcc

# finally, extract the x-vectors based on chosen model
sid/nnet3/xvector/extract_xvectors.sh 0007_voxceleb_v2_1a/exp/xvector_nnet_1a/ data/ exp/xvectors

# get speakers, get utterances
copy-vector scp:exp/xvectors/spk_xvector.scp ark,t:- > final/spk_xvector.txt
copy-vector scp:exp/xvectors/xvector.scp ark,t:- > final/utts.txt

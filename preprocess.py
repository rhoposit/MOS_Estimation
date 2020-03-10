# Copyright 2019 CSTR, University of Edinburgh
#
# Authors: Jennifer Williams, Joanna Rownicka
# Apache 2.0.
#########################################################

import os, glob, sys
import numpy as np


# This is the location of the wav files to be scored
audio_path = "./wavs/"


# This section of code creates an utt2spk and wav.scp file
if not os.path.exists("tts_data"):
    os.makedirs("tts_data")
outfile1 = "./tts_data/utt2spk"
outfile2 = "./tts_data/wav.scp"
output1 = open(outfile1, "w")
output2 = open(outfile2, "w")
all_wavs = glob.glob(audio_path+"/*.wav")
for w in all_wavs:
    utt = w.split("/")[-1].split(".wav")[0]
    outstring = utt+" " + utt + "\n"
    output1.write(outstring)
    fullpath = os.path.abspath(w)
    outstr = utt+" /usr/bin/sox -t wav "+fullpath+" -b 16 -r 16000 -t wav - |\n"
    output2.write(outstr)
output1.close()
output2.close()



# This section of code runs the xvector extraction
if not os.path.exists("xvec5"):
    os.makedirs("xvec5")
os.system("./run_xvector_tts.sh --nj 32 || exit 1;")



# This section of code transforms the xvectors into .npy files for MOS scoring
print("Creating numpy representation of xvectors")
if not os.path.exists("xvec5/npy"):
    os.makedirs("xvec5/npy")
input = open("xvec5/xvectors_mfcc_lf0_hf0_device_5.txt", "r")
UTTS_RAW = input.read().split("]\n")[:-1]
input.close()
for i in range(0, len(UTTS_RAW)):
    uttID = UTTS_RAW[i].split(" ")[0]
    uttvec = np.array(UTTS_RAW[i].split(" ")[3:-1]).astype(np.float)
    utts_output_file = "xvec5/npy/"+uttID+".npy"
    np.save(utts_output_file, uttvec)

print("Processed data location: ./xvec5/npy/")
print("Preprocess complete.")

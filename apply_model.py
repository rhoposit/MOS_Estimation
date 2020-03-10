import glob, sys, os, time
import os.path
import numpy as np
from tqdm import tqdm
import scipy.stats
import pandas as pd
import tensorflow as tf
from tensorflow import keras
import model_rep
import random
random.seed(1984)
from tensorflow.keras.models import load_model



def get_mos_scores(feats, test_list, model_file, results_file):

    print("loading model: " + model_file)
    model = load_model(model_file)
    model.summary()
    MOS_Predicted=np.zeros([len(test_list),])
    df = pd.DataFrame(columns=['wav_file', 'predicted_mos'])

    print("scoring each processed wav file...")
    for i in tqdm(range(len(test_list))):

        filename=test_list[i]
        _input = np.array([np.load(filename)])
        _input = np.expand_dims(_input, axis=3)
        score=model.predict(_input, verbose=0, batch_size=1)
        MOS_Predicted[i]=score[0][0]
        basename = filename.split(".")[0].split("/")[-1]     
        df = df.append({'wav_file': basename, 
                        'predicted_mos': MOS_Predicted[i]},
                       ignore_index=True)
                       
    print("saving results to CSV file: "+results_file)
    df.to_csv(results_file, sep=',', index=False)
    return



###########################################################################
# this is the best LA model for the xvec5 feature
model = "pre_trained_model/xvec5.h5"

# a list of wav files that will be scored with the pre-trained model
test_list = glob.glob("xvec5/npy/*.npy")

# output of model, saved in CSV format: wav file, predicted score
results_file = "MOS_scored_wavs_xvec5.csv"

# directory where the pre-processed xvec features are located
feats_dir = "xvec5/npy/"
###########################################################################


# apply the trained model and save the results
get_mos_scores(feats_dir, test_list, model, results_file)
print("done.")


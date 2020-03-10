# MOS_Estimation
Apply a pre-trained model to wav files to obtain a MOS quality score
Based on work reported in: "Comparison of Speech Representations for Automatic Quality Estimation in Multi-Speaker Text-to-Speech Synthesis"
https://arxiv.org/abs/2002.12645


( Note this code was derived from https://github.com/lochenchou/MOSNet, https://arxiv.org/abs/1904.08352 )

# Dependency
Linux Ubuntu 16.04
- GPU: GeForce RTX 2080 Ti
- Driver version: 418.67
- CUDA version: 10.1

Python 3.5
- tensorflow-gpu==2.0.0-beta1 (cudnn=7.6.0)
- scipy
- pandas
- matplotlib
- librosa

### Environment set-up
For example,
```
conda create -n mosnet python=3.5
conda activate mosnet
pip install -r requirements.txt
conda install cudnn=7.6.0
```

### Other Requirements
- Kaldi installed (https://kaldi-asr.org/doc/install.html)
- sox installed (http://sox.sourceforge.net/)
- check that `KALDI_ROOT` variable is set in `path.sh`
- adjust commands in cmd.sh to suit your compute cluster/queue



# Usage
1. place all speech wavfiles into a directory in the current working directory and name it `./wavs`. These are the wavfiles that need a MOS score.
2. Run `python preprocess.py` to prepare the wav files. This extracts MFCCs and also extracts xvectors, and prepares the data for input to the neural network.
3. Run `python apply_model.py` to run the neural network and obtain a MOS score for each wav file
4. Final results will be provided in a CSV file in the current working directory `MOS_scored_wavs_xvec5.csv`


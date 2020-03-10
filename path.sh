export KALDI_ROOT="/home/s1738075/kaldi/"
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/irstlm/bin/:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && e$
. $KALDI_ROOT/tools/config/common_path.sh
export LD_LIBRARY_PATH=$KALDI_ROOT/tools/openfst-1.3.4/lib:$KALDI_ROOT/tools/openfst-1.3.4/lib/fst:$KALDI_ROOT/tools/irstlm/lib:$LD_LIBRARY_PATH
export LC_ALL=C

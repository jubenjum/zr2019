#!bin/bash

ABX_DIR="$PWD/eval/ABXpy" # ABX evaluation system

git clone https://github.com/bootphon/ABXpy.git $ABX_DIR
cd $ABX_DIR
git checkout zerospeech2019
#conda create -n abx --yes python=2.7 cython numpy scipy h5py=2.6.0 pandas pytest pytables matplotlib
source activate abx
pip install $HOME/misc/read_zrsc2019
pip install editdistance
pip install h5features
make install
make test

echo "Set up for ABX evaluation is done"

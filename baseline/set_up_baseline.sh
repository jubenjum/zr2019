#!bin/bash

# This is a necessary setup script before running the baseline
# two python environments will be created :
# 1 - tts : python 2.7 
# 2 - beer : python 3

BEER_DIR="$PWD/training/beer" # AUD system
OSSIAN_DIR="$PWD/training/ossian" # TTS system


#Install Miniconda and get database
#bash $HOME/misc/Miniconda3-latest-Linux-x86_64.sh -b

#Beer set up
git clone https://github.com/RobinAlgayres/beer.git $BEER_DIR
cd $BEER_DIR
conda env create -f condaenv.yml || exit 1
source activate beer
conda install -y -c pytorch pytorch || exit 1
python setup.py install || exit 1
pip install sklearn

#Ossian set up
git clone https://github.com/RobinAlgayres/Ossian.git $OSSIAN_DIR
cd $OSSIAN_DIR
conda env create -f patch_ossian/condaenv_ossian.yml || exit 1
source activate ossian
pip install $HOME/misc/read_zrsc2019
pip install bandmat || exit 1
pip install argparse || exit 1
HTK_USERNAME="robinalgayres"
HTK_PASSWORD="qt9vAh8m"
bash ./scripts/setup_tools.sh $HTK_USERNAME $HTK_PASSWORD

################## IF YOU WANT TO USE YOUR GPU FOR OSSIAN
# First intall nvidia-docker as explained in 
# https://marmelab.com/blog/2018/03/21/using-nvidia-gpu-within-docker-container.html
# 
# Then, you need to have a running CUDA and CUDNN library
# Be careful, theano looks in the wrong place for cudnn libraries and includes 
# You can do this to solve this issue:
#	cp usr/lib64/libcudnn* /usr/local/cuda/lib64/
#	cp usr/include/cudnn.h /usr/local/cuda/include/
# then run : python check_theano_gpu.py
# if the output is "used the gpu" then theano setup is completed.
# You can now change the GPU argument in baseline.sh to "use_gpu" in stage 4
# Note : BEER works only on CPU but can be paralleled on multiple CPUs.
##################

echo "Set up for baseline is done"

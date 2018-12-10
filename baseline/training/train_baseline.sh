#!bin/bash

set -e

# This is the script for ZS2019 Challenge's baseline
# It goes through these steps :
#	1) Training of BEER, an Acoustic Unit Discovery algorithm on 20hours of 
#       unannotated speech. 
#	2) Running BEER on 2 hours of unseen speech from a new single speaker.
#	3) Converting output of BEER to match OSSIAN input.
#	4) Training of OSSIAN, a TTS pipeline that will be trained on units discovered 
#	by BEER.


if [ "$#" -ne 3 ]; then 
	echo "usage: bash train_baseline.sh <baseline_dir> <database> <stage>"
	echo " eg : bash train_baseline.sh $HOME/baseline $HOME/databases/english_small/ 1 "
	exit
fi



#### VARIABLES

TRAINING_DIR="$1/training"

BEER_DIR="$TRAINING_DIR/beer/recipes/zrc2019"
OSSIAN_DIR="$TRAINING_DIR/ossian"
DB=$2
stage=$3

BEER_TRAINING_WAV="$DB/train/unit" # wav files for Beer's training
OSSIAN_TRAINING_WAV="$DB/train/voice" # wav files decoded by Beer to train Ossian
OSSIAN_PATCH_DIR="$OSSIAN_DIR/patch_ossian"
OSSIAN_CORPUS="$TRAINING_DIR/ossian_corpus"
OSSIAN_TRAINING_FILES="$TRAINING_DIR/tmp/ossian_files_training"
ONEHOT_FILES="$TRAINING_DIR/tmp/onehot_files"
mkdir -p $OSSIAN_TRAINING_FILES $ONEHOT_FILES $OSSIAN_CORPUS

####BEER TRAINING

if [ $stage -le 1 ]; then
	echo "Training Beer"
	source activate beer
	cd $BEER_DIR/
	bash train_beer.sh $BEER_TRAINING_WAV "clean" || exit 1
fi

####BEER DECODING

if [ $stage -le 2 ]; then	
	source activate beer
	cd $BEER_DIR
	# decoding data for Ossian training (step 4)
	bash decode_beer.sh $OSSIAN_TRAINING_WAV $ONEHOT_FILES "clean" || exit 1
	echo "Sentences for Ossian training at $OSSIAN_TRAINING_FILES"
fi

####CONVERTING BEER'S DECODING INTO OSSIAN'S INPUT FORMAT
if [ $stage -le 3 ]; then	
	source activate ossian
	cd $TRAINING_DIR
	# preparing corpus for Ossian's training
	
	TEXT_CORPORA="$TRAINING_DIR/tmp/text_corpora.txt"
	python scripts/onehot_to_ossian_format.py $ONEHOT_FILES $OSSIAN_TRAINING_FILES $TEXT_CORPORA
		
        mkdir -p $OSSIAN_CORPUS/english/speakers/zs19_data/txt
	mkdir -p $OSSIAN_CORPUS/english/speakers/zs19_data/wav
	mkdir -p $OSSIAN_CORPUS/english/text_corpora/wikipedia_10K_words
	cp $OSSIAN_TRAINING_WAV/* $OSSIAN_CORPUS/english/speakers/zs19_data/wav/
	cp $OSSIAN_TRAINING_FILES/* $OSSIAN_CORPUS/english/speakers/zs19_data/txt/
	cp $TEXT_CORPORA $OSSIAN_CORPUS/english/text_corpora/wikipedia_10K_words/text.txt
	python scripts/check_corpus.py $OSSIAN_CORPUS
	rm -r $OSSIAN_TRAINING_FILES $TEXT_CORPORA
	echo " Corpus for Ossian training is ready "
fi


####OSSIAN TRAINING
if [ $stage -le 4 ]; then
	source activate ossian
	cd $OSSIAN_DIR
	MODE="default" # choose "nodur" or default
	GPU="no_gpu" # choose "use_gpu" or "no_gpu"
	SPEAKER="V001"
	bash train_ossian.sh $TRAINING_DIR "ossian_corpus" $MODE $GPU $SPEAKER || exit 1
	rm -r $OSSIAN_CORPUS
fi


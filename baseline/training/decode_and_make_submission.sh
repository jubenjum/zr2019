#!bin/bash

set -e

# This script decodes all sentences from databases/english/test and synthesizes sentences from databases/english/synthesis

if [ "$#" -ne 2 ]; then 
	echo "usage: bash decode_and_submit.sh <home_dir> <submission_dir> "
	echo " eg : bash decode_and_submit.sh /home/zs2019 /home/zs2019/submission "
	exit
fi

#### VARIABLES

MAIN_DIR=$1
BEER_DIR="$MAIN_DIR/baseline/training/beer/recipes/zrc2019"
OSSIAN_DIR="$MAIN_DIR/baseline/training/ossian"
TEST_WAV="$MAIN_DIR/databases/english/test/"
FILELIST_FOR_SYNTHESIS="$MAIN_DIR/databases/english/synthesis.txt"

SUBMISSION_DIR="$2/english"
EMBEDDINGS_AND_SYNTHESIS="$SUBMISSION_DIR/test/"
EMBEDDINGS_TO_SYNTHESIZE="$MAIN_DIR/baseline/training/tmp/embeddings_to_synthesize"
OSSIAN_FILES="$MAIN_DIR/baseline/training/tmp/ossian_files"

mkdir -p $EMBEDDINGS_AND_SYNTHESIS $EMBEDDINGS_TO_SYNTHESIZE $OSSIAN_FILES
touch $SUBMISSION_DIR/../metadata

####DECODING NEW SENTENCES WITH BEER

source activate beer
cd $BEER_DIR
bash decode_beer.sh $TEST_WAV $EMBEDDINGS_AND_SYNTHESIS "clean" || exit 1

#### SYNTHETISING SPEECH FROM DECODED SENTENCES

# Changing format for Ossian
IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat < "$FILELIST_FOR_SYNTHESIS"); do
  echo "cp $i"
  filename=$(basename $i)
  filename="${filename%.*}".txt
  cp $EMBEDDINGS_AND_SYNTHESIS/$filename $EMBEDDINGS_TO_SYNTHESIZE 
done

cd "$MAIN_DIR/baseline/training/"
python scripts/onehot_to_ossian_format.py $EMBEDDINGS_TO_SYNTHESIZE $OSSIAN_FILES

# Synthesizing speech
source activate ossian
cd $OSSIAN_DIR
bash speak.sh $OSSIAN_FILES $EMBEDDINGS_AND_SYNTHESIS || exit 1
rm -r "$MAIN_DIR/baseline/training/tmp"

zip -r $2.zip $2

echo "$TEST_WAV is decoded in $EMBEDDINGS_AND_SYNTHESIS"
echo "Synthesized files are in $EMBEDDINGS_AND_SYNTHESIS"
echo "The submission folder should be validated with $HOME/validate.sh before evaluation"

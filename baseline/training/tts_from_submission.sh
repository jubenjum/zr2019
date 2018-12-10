#!bin/bash

set -e

# This script synthesize speech from embeddings in a submission. 
# You need to specify a filelist of files you want to synthesize from the submission

if [ "$#" -ne 3 ]; then 
	echo "usage: bash decode_and_submit.sh <home_dir> <dest_dir> <filelist>"
        echo ''
        echo "--Dest_dir will contain all synthesized files"
        echo "--The filelist must contain the absolute path to all files to synthesize."
        echo "These files must have the right format"
	echo " eg : bash decode_and_submit.sh /home/zs2019 dest/ filelist.txt"
	exit
fi

#### VARIABLES

MAIN_DIR=$1
OSSIAN_DIR="$MAIN_DIR/baseline/training/ossian"
DEST_DIR=$MAIN_DIR/baseline/training/$2
FILELIST_FOR_SYNTHESIS=$3
OSSIAN_FILES="$MAIN_DIR/baseline/training/tmp/ossian_files"
TMP_DIR="$MAIN_DIR/baseline/training/tmp/embeddings_for_synthesis"

mkdir -p $DEST_DIR $TMP_DIR $OSSIAN_FILES

source activate ossian

# Copying embeddings to synthesize
IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat < "$FILELIST_FOR_SYNTHESIS"); do
  echo "cp $i"
  cp $i $TMP_DIR
done

# Formating to Ossian format
cd "$MAIN_DIR/baseline/training/"
python scripts/onehot_to_ossian_format.py $TMP_DIR $OSSIAN_FILES $HOME/testcorpoa.txt
# Synthesizing speech
cd $OSSIAN_DIR
bash speak.sh $OSSIAN_FILES $DEST_DIR || exit 1
rm -r "$MAIN_DIR/baseline/training/tmp"

echo "Synthesized files are in $EMBEDDINGS_AND_SYNTHESIS"

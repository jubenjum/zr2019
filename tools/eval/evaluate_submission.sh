#!bin/bash

set -e

# This is the script for ZS2019 Challenge's evaluation of submissions


if [ "$#" -ne 3 ]; then 
	echo "usage: bash evaluate_submission.sh <main_dir path> <submission_path> <levenshtein|cosine>"
	echo "eg: bash evaluate_submission.sh  /home/zs2019/ /home/zs2019/submission"
	exit
fi


MAIN_DIR=$1
EVAL_DIR="$MAIN_DIR/tools/eval"
SUBMISSION_DIR=$2/english/
DISTANCE=$3
WAV_TEST_ABX=$MAIN_DIR/databases/english/test/unit_abx
WAV_TEST_BITRATE=$MAIN_DIR/databases/english/test/unit_bitrate
WAV_TEST_OSSIAN=$MAIN_DIR/databases/english/test/parallel_source


source activate eval

### VALIDATE SUBMISSION BEFORE EVALUATION

echo "Validating submission before evaluation"
output=$(bash $HOME/tools/validate.sh $HOME/submission.zip english)
echo $output
if [ ! $output = 'pass' ]; then 
    echo "submission.zip is not valid"
fi

### COMPUTE ABX SCORE

echo "Evaluate ABX"
TMP_DIR=$EVAL_DIR/tmp
mkdir -p $TMP_DIR/abx_npz_files

# create npz files out of onehot embeddings for ABX evaluation
python $EVAL_DIR/scripts/make_abx_files.py $SUBMISSION_DIR/test $TMP_DIR/abx_npz_files || exit 1

TASK_ACROSS="$EVAL_DIR/../info_test/english/by-context-across-speakers.abx"
# Create .features file
python $EVAL_DIR/ABXpy/ABXpy/misc/any2h5features.py $TMP_DIR/abx_npz_files $TMP_DIR/features.features
# Computing distances
if [ $DISTANCE = "levenshtein" ]; then
    abx-distance tmp/features.features $TASK_ACROSS $TMP_DIR/distance_across -d levenshtein
else
    abx-distance tmp/features.features $TASK_ACROSS $TMP_DIR/distance_across -n 1
fi
# Calculating scores
abx-score $TASK_ACROSS $TMP_DIR/distance_across $TMP_DIR/score_across
# Collapsing results in readable format
abx-analyze $TMP_DIR/score_across $TASK_ACROSS $TMP_DIR/analyze_across
# Print average score
python $TMP_DIR/scripts/meanABX.py $TMP_DIR/analyze_across across > abx_score

### COMPUTE BITRATE SCORE
echo "Evaluate Bitrate"
#source activate beer # bitrate.py needs python 3
python $EVAL_DIR/scripts/bitrate.py $SUBMISSION_DIR/test/ $MAIN_DIR/tools/info_test/english/bitrate_filelist.txt > bitrate_score

echo ""
cat bitrate_score
cat abx_score

echo ""
echo "Bitrate score is stored at $EVAL_DIR/bitrate_score"
echo "ABX score is stored at $EVAL_DIR/abx_score"

#!bin/bash

set -e

# equivalent to $(readlink -f $1) in pure bash (compatible with macos)
function realpath {
    pushd $(dirname $1) > /dev/null
    echo $(pwd -P)
    popd > /dev/null
}

function failure { [ ! -z "$1" ] && echo "Error: $1"; exit 1; }

function on_exit() {
    rm -rf $tmpdir;
}

trap on_exit EXIT


# processing is done in temporary location
# to avoid file locks
export tmpdir=$(mktemp -d)


if [ $# != 2 ]; then
    echo "Missing arguments to '$0'"
    echo "Use: "
    echo "source activate beer"
    echo "$0 <absolute path to submission zip> <english|surprise>"
    echo ""
    exit 1
fi

zfile=$1
if [ ! -f "$zfile" ]; then
    echo "File not found: $zfile"
    exit 1
fi

if [ $2 = "english" ]; then
    full_list=$HOME/tools/info_test/english/submission_filelist.txt
    validation_list=$HOME/tools/info_test/english/durations.txt
elif [ $2 = "surprise" ]; then
    full_list=$HOME/tools/info_test/surprise/submission_filelist.txt
    validation_list=$HOME/tools/info_test/surprise/durations.txt
elif [ $2 = "both" ]; then
    cat $HOME/tools/info_test/english/submission_filelist.txt \
        $HOME/tools/info_test/surprise/submission_filelist.txt > \
        $tmpdir/filelist.txt
    cat $HOME/tools/info_test/english/durations.txt \
        $HOME/tools/info_test/surprise/durations.txt > \
        $tmpdir/filelist.txt
    full_list="$tmpdir/filelist.txt"
    validation_list="$tmpdir/durations.txt"
else
    echo "Language to evaluate must be correctly specified ('english', 'surprise', or 'both')"
    exit 1
fi

# checking the zip file integrity
unzip -t "$zfile" > /dev/null || failure "corrupted $zfile"

# check file list
unzip "$zfile" -d "$tmpdir" > /dev/null

# checking if all necessary files were submitted
cat /dev/null > validation.log
for f in $(cat "$full_list"); do
   if [ ! -f "$tmpdir/$f" ]; then
      echo "Missing:" $f >> validation.log
   fi
done

# check if embedding files are correct by using validate.py
python $HOME/misc/read_zrsc2019/bin/validate \
     --dont-complain-about-missing-files "$tmpdir" "$validation_list" >> \
     validation.log

if [ -s validation.log ]; then
   echo "Submission invalid: see validation.log" > /dev/stderr
   exit 1
else
   echo "Validation passed"
   rm -f validation.log
   exit 0
fi


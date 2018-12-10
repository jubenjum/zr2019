#!bin/bash
IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat < "$1"); do
  dur=$(soxi -D $HOME/databases/english/$i)
  filename=$(basename $i)
  filename=${filename%.*}.txt
  echo $filename $dur
done



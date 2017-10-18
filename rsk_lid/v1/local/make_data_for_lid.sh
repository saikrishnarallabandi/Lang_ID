#!/bin/bash

# This script is the first step in building the LID system. It needs to basically look at the data source and create atleast the three files: wav.scp, utt2spk and utt2lang. It needs to put these in the destination folder which it receives as third argument

src=$1
lang=$2
dest=$3

echo "Trying to get the data of " $lang " from " $src " and make in " $dest

# Clear the destination location to avoid creating duplicates
if [ -d "$dest" ]; then
   rm -rf $dest/*
else
  mkdir -p $dest
fi

# Loop over the source directory and update the files at destination
for file in $src/*.wav

 do
   fname=$(basename "$file" .wav)
   echo "Processing " $fname
   echo $fname $file >> $dest/wav.scp
   # I am using tr as I observed that all files have '-' in them separating the speaker. I suppose using IFS is the most optimal way to do this but I am just lazy and am going to stick to this. 
   spk=$(echo $fname | tr "-" " " | cut -d ' ' -f 1)
   echo $fname $spk >> $dest/utt2spk
   echo $fname $lang >> $dest/utt2lang
 done


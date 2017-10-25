
# Source the kaldi path
. path.sh
mfcc_folder=${KALDI_ROOT}/egs/voxforge/s5/mfcc_spanish

rm -r ../data/spanish/cleaned/*
rm -r ../data/spanish/raw/*

mkdir -p ../data/spanish
mkdir -p ../data/spanish/cleaned
mkdir -p ../data/spanish/raw

# Get the mfccs and accomodate in a single file
for file in ${mfcc_folder}/*.ark
do
 fname=$(basename "$file" .ark)
 cat $mfcc_folder/${fname}.scp | while read f
 do
   n=`echo "${f}" | cut -d ' ' -f 1`
   echo $f | copy-feats scp:- ark,t:- > ../data/spanish/raw/${n}.mfcc
   cat ../data/spanish/raw/${n}.mfcc | sed '/\[$/d' | sed 's/]//g' > ../data/spanish/cleaned/${n}.mfcc
 done
done 

# Remove the extra information and get only frames
#cat t_spanish | sed '/\[$/d' | sed 's/]//g' > t_cleaned_spanish.txt

# Put the labels
#cat t_cleaned_spanish.txt | while read line
#do
# echo 1 >> t_labels_spanish
#done
